#!/bin/bash

# Install required tools:
# 1. openssl: Already installed on most systems, otherwise install the 'openssl' package using your system's package manager.
# 2. dig: sudo apt-get install dnsutils (Debian/Ubuntu) / sudo yum install bind-utils (RHEL/CentOS/Fedora) / sudo pacman -S bind-tools (Arch Linux)
# 3. nuclei: Download the latest release from https://github.com/projectdiscovery/nuclei/releases and follow the installation guide.
# 4. subfinder: Download the latest release from https://github.com/projectdiscovery/subfinder/releases and
# 7. gowitness: Download the latest release from https://github.com/sensepost/gowitness/releases and follow the installation guide.
# Usage Guide: follow the installation guide.
# 5. assetfinder: Download and install using 'go get -u github.com/tomnomnom/assetfinder'
# 6. httprobe: Download and install using 'go get -u github.com/tomnomnom/httprobe'
# 7. gowitness: Download the latest release from https://github.com/sensepost/gowitness/releases and follow the installation guide.
# Usage Guide:
# Execute the script with the domain as an argument: ./script.sh example.com

domain=$1
RED="\033[1;31m"
RESET="\033[0m"

info_path=$domain/info
subdomain_path=$domain/subdomains
screenshot_path=$domain/screenshots

function run_openssl() {
    echo -e "${RED} [+] Running openssl s_client...${RESET}"
    openssl s_client -connect $domain:443 -servername $domain > $info_path/openssl.txt
}

function get_mx_records() {
    echo -e "${RED} [+] Getting MX records...${RESET}"
    dig MX $domain +short > $info_path/mx.txt
}

function analyze_spf_dmarc() {
    echo -e "${RED} [+] Analyzing SPF records...${RESET}"
    dig TXT $domain +short | grep "v=spf1" > $info_path/spf.txt

    echo -e "${RED} [+] Analyzing DMARC records...${RESET}"
    dig TXT _dmarc.$domain +short | grep "v=DMARC1" > $info_path/dmarc.txt
}

function run_nuclei() {
    echo -e "${RED} [+] Running nuclei...${RESET}"
    nuclei -u $domain -o $info_path/nuclei.txt
}

if [ ! -d "$domain" ];then
    mkdir $domain
fi

if [ ! -d "$info_path" ];then
    mkdir $info_path
fi

if [ ! -d "$subdomain_path" ];then
    mkdir $subdomain_path
fi

if [ ! -d "$screenshot_path" ];then
    mkdir $screenshot_path
fi

echo -e "${RED} [+] Checking who it is...${RESET}"
whois $1 > $info_path/whois.txt

echo -e "${RED} [+] Launching subfinder...${RESET}"
subfinder -d $domain > $subdomain_path/found.txt

echo -e "${RED} [+] Running assetfinder...${RESET}"
assetfinder $domain | grep $domain >> $subdomain_path/found.txt

echo -e "${RED} [+] Checking what's alive...${RESET}"
cat $subdomain_path/found.txt | grep $domain | sort -u | httprobe -p http:80 -p http:8080 -p https:443 | tee -a $subdomain_path/alive.txt

echo -e "${RED} [+] Screenshots...${RESET}"
gowitness file -f $subdomain_path/alive.txt -P $screenshot_path/

# Run the additional functions
run_openssl
get_mx_records
analyze_spf_dmarc
run_nuclei
