# Domain_OSINT

This Domain Reconnaissance Tool is a Bash script designed to collect and analyze information on a specified domain. The script uses a variety of open-source tools to accomplish its tasks, including Assetfinder, Gowitness and nuclei. By inputting a target domain, the script conducts the following tasks:

1. Gathers WHOIS information, providing general details about the domain ownership and registration.
2. Discovers subdomains and lists them using Subfinder and Assetfinder tools.
3. Filters the found subdomains and checks if they are alive (HTTP/HTTPS accessible) using Httprobe.
4. Takes screenshots of the alive subdomains' webpages using Gowitness.
5. Extracts SSL/TLS certificate details and server information using OpenSSL's s_client module.
6. Retrieves MX records and lists the responsible mail servers using the "dig" command.
7. Analyzes SPF and DMARC records using "dig" to retrieve TXT records and filtering the relevant information.
8. Launches a nuclei scan on the target domain.
