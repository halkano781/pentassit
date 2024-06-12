# pentassit

## Overview
The Pentassit Tool is a command-line script designed to assist newcomers in performing reconnaissance, content discovery, vulnerability analysis, and limited exploitation in network security assessments. It provides a convenient compilation of various tools integrated into a single script for ease of use. Also it helps proffesionals save on time

## Features
- **Reconnaissance**: Ping IP addresses, perform port scanning with Nmap.
- **Content Discovery**: Grab banners, discover subdirectories, and enumerate subdomains.
- **Vulnerability Analysis**: Assess vulnerabilities using RapidScan and check for SMB vulnerabilities. others coming
- **Exploitation**: Limited functionality to exploit vulnerabilities with Metasploit.

## Usage
1. **Clone Repository**: Clone this repository to your local machine using `git clone`.
2. **Navigate to Directory**: Change into the directory where the script is located.
3. **Install Dependencies**: Ensure all required dependencies are installed (see Dependencies section below).
4. **Run Script**: Execute the script and follow the prompts to choose desired actions.

## Dependencies
- **Nmap**: Network scanning tool for host discovery and port scanning.
- **Curl**: Command-line tool for transferring data with URLs.
- **Python 3**: Programming language used for scripting.
- **dirsearch**: Web path scanner for content discovery ([GitHub](https://github.com/maurosoria/dirsearch)).
- **sublist3r**: Subdomain enumeration tool ([GitHub](https://github.com/aboul3la/Sublist3r)).
- **LinkFinder**: find javascript endpoint and outputs in html

## Contribution
Contributions to this project are welcome! If you encounter any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request.

## Disclaimer
This tool is provided for educational purposes only. The author assumes no liability for the misuse of this tool or any damages resulting from its use.
