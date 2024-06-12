#!/bin/bash

# Function to get input from the user
get_ip_address() {
    read -p "Please enter the IP address: " ip_address
}

get_url() {
    read -p "Please enter the URL (or press Enter to skip): " url
    if [[ -z "$url" ]]; then
        url="http://$ip_address"
    fi
}
get_target_directory() {
    while [[ -z "$target_directory" ]]; do
        read -p "Please enter the target directory name: " target_directory
        if [[ -z "$target_directory" ]]; then
            echo "Target directory name cannot be empty. Please try again."
        else
            mkdir -p "$target_directory"
        fi
    done
}


run_command() {
    local command="$1"
    eval "$command"
}

ping_ip() {
    echo "Pinging $ip_address..."
    run_command "ping -c 4 $ip_address | tee $target_directory/ping_results.txt"
}

scan_ip() {
    echo "Scanning $ip_address with nmap..."
    run_command "nmap --min-rate=10000 -sCV $ip_address -oN $target_directory/nmap_results.txt"
}

scan_ip_no_ping() {
    echo "Scanning $ip_address with nmap (TCP SYN scan, no ping)..."
    run_command "nmap -sS -Pn $ip_address -oN $target_directory/nmap_results.txt"
}

banner_grabbing() {
    echo "Grabbing banner from $ip_address..."
    echo "Using Netcat..."
    run_command "nc -vz $ip_address 80 | tee $target_directory/nc_banner.txt"
    echo "Using Telnet..."
    run_command "echo -e '\n\n' | telnet $ip_address 80 | tee $target_directory/telnet_banner.txt"
    echo "Using Curl..."
    run_command "curl -I $ip_address | tee $target_directory/curl_banner.txt"
}

subdirectory_discovery() {
    echo "Discovering subdirectories for $url..."
    run_command "dirsearch -u $url -o $target_directory/dirsearch_results.txt"
}

subdomain_discovery() {
    local domain="$url"
    domain="${domain#http://}"
    domain="${domain#https://}"
    echo "Discovering subdomains for $domain..."
    run_command "sublist3r -d $domain -o $target_directory/subdomains.txt"
}

vulnerability_assessment_rapidscan() {
    echo "Performing vulnerability assessment on $ip_address with RapidScan (limited to 6 minutes)..."
    run_command "timeout 360 python3 /home/halkano/Tools/rapidscan/rapidscan.py $ip_address > $target_directory/rapidscan_results.txt"
}

js_endpoint_discovery() {
    echo "Collecting JavaScript endpoints for $url..."
    run_command "python3 /home/halkano/Tools/LinkFinder/linkfinder.py  -i $url -o cli | tee $target_directory/js_endpoints.html"
}

run_nuclei() {
    echo "Running Nuclei to assess vulnerabilities..."
    run_command "/home/halkano/Downloads/nuclei_3.2.8_linux_amd64/nuclei -u $url -severity unknown,low,medium,high,critical -o $target_directory/nuclei_results.txt"
}

update_hosts_file() {
    echo "Updating /etc/hosts file with discovered domain names..."
    # Extract domains from nmap_results.txt
    local domains=$(grep -oP '(?<=http://)[\w\.-]+\.[a-zA-Z]{2,6}' $target_directory/nmap_results.txt)
    for domain in $domains; do
        echo "Adding $domain to /etc/hosts"
        if ! grep -q "$domain" /etc/hosts; then
            echo "$ip_address $domain" | sudo tee -a /etc/hosts
        else
            echo "$domain already exists in /etc/hosts"
        fi
    done
}

check_tools() {
    echo "Checking for required tools..."
    local required_tools=("nmap" "curl" "nc" "telnet" "dirsearch" "sublist3r" "python3")
    local tool_status_file="$target_directory/tool_status.txt"
    > "$tool_status_file" # Create or clear the file

    for tool in "${required_tools[@]}"; do
        if command -v $tool &> /dev/null; then
            echo "$tool is installed" | tee -a "$tool_status_file"
        else
            echo "$tool is not installed. Installing..." | tee -a "$tool_status_file"
            if [[ $tool == "python3" ]]; then
                sudo apt-get install -y python3 | tee -a "$tool_status_file"
            else
                sudo apt-get install -y $tool | tee -a "$tool_status_file"
            fi
        fi
    done
}

main() {
    check_tools
    get_ip_address
    get_url
    get_target_directory

    while true; do
        echo -e "\nNetwork Automation Tool"
        echo "1) Ping IP address"
        echo "2) Scan IP address with nmap"
        echo "3) Scan IP address with nmap (no ping)"
        echo "4) Banner grabbing"
        echo "5) Subdirectory discovery"
        echo "6) Subdomain discovery"
        echo "7) Vulnerability assessment with RapidScan (limited to 6 minutes)"
        echo "8) asset discovery"
        echo "9) run nuclei for vuln severity"
        echo "10) Update /etc/hosts with domain names found in Nmap scan"
        echo "11) Exit"

        read -p "Enter your choice: " choice

        case $choice in
            1)
                ping_ip
                ;;
            2)
                scan_ip
                ;;
            3)
                scan_ip_no_ping
                ;;
            4)
                banner_grabbing
                ;;
            5)
                subdirectory_discovery
                ;;
            6)
                subdomain_discovery
                ;;
            7)
                vulnerability_assessment_rapidscan
                ;;
            8)
                js_endpoint_discovery
                ;;
            9) 
                run_nuclei
                ;;
            10)
                update_hosts_file
                ;;
            11)
                echo "Exiting..."
                break
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}

main
