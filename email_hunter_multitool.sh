#!/usr/bin/env bash 

echo "# This is a super simple way to check for email after a given domain. Here's how it works:"
echo "#"
echo "#     - Mail the script executable: chmod +x email_hunter_multitool.sh"
echo "#     - Run the script ./email_hunter_multitool.sh domain.com emails_found.txt"
echo "#     - Enter the path to save results"
echo "#"
echo "# This script uses a set of tools to search for mails given a certain domain and then saves the ouput to a txt file."
echo "# After finding emeils you can chooise id you want to search those email for breached credentials using h8mail."
echo "# Here are the tools that the script is using for the moment. (theHarvester emailHarvester, skymem website, h8mail)."
echo "#"
echo "# Please before running the script, ensure that all the required tools are installed."
echo "#"
echo "#"
#
#              .__....._             _.....__,
#                 .": o :':         ;': o :".
#                 `. `-' .'.       .'. `-' .'
#                   `---'             `---'
#
#         _...----...      ...   ...      ...----..._
#      .-'__..-""'----    `.  `"`  .'    ----'""-..__`-.
#     '.-'   _.--"""'       `-._.-'       '"""--._   `-.`
#     '  .-"'                  :                  `"-.  `
#       '   `.              _.'"'._              .'   `
#             `.       ,.-'"       "'-.,       .'
#               `.                           .'
#                 `-._                   _.-'
#                     `"'--...___...--'"`
#
echo "#   Author: m3ta		Email: m3tahckr@protonmail.com			Version: 1.0"

echo ""
read -n1 -r -p "Press any key to continue..." key
echo ""

## First and only argument
domain_name=$1
file_name=$2

## Setting up colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

## Empty file variable
breached_credentials="breached_credentials.txt"

## Create empty file to save all emails
touch $2
echo "" > $2

## Fire up theHarvester
echo -e "${YELLOW}[\] Searching emails using theHarverster...${ENDCOLOR}"
## theHarvester -d $domain_name -b all | grep "@" > $2
echo -e "${GREEN}[+] theHarvester done... Emails saved on $2${ENDCOLOR}"

## Fire up emailHarvester
echo -e "${YELLOW}[\] Searching emails using emailHarverster...${ENDCOLOR}"
## emailharvester -d $domain_name -l 10 | grep "@" >> $2
echo -e "${GREEN}[+] emailHarvester done... Emails saved on $2${ENDCOLOR}"

## Curling from skymem website
startpage=1
echo -e "${YELLOW}[\] Searching emails on Skymem.info...${ENDCOLOR}"
skymem=$(curl -s http://www.skymem.info/srch?q=$1 | grep '<a href="/domain/' | awk '{print $2}' | cut -c15-41)
no_of_emails=$(curl -s http://www.skymem.info/domain/$skymem$startpage | grep "This is the preview" | awk '{print $6}')
let lastpage=$no_of_emails/5

company_name=${domain%%.*}
for (( i=$startpage; i<$lastpage; i++))
do
    emails=$(curl -s http://www.skymem.info/domain/$skymem$i | grep "$company_name" | grep '<a href="/srch?q=' | sed '1d' | sed -e 's/<[^>]*>//g' | sed -e 's/^[ \t]*//')
    echo "$emails" >> $2
done
echo -e "${GREEN}[+] Skymem.info done... Emails saved on $2${ENDCOLOR}"

result=$(cat $2 | wc -l)
echo -e "${GREEN}[+] ${result} emails has been found${ENDCOLOR}"

read -p "Do you want to view the emails found?: (y/n): " view
if [[ $view == "y" || $view == "Y" || $view == "yes" ]]; then
    cat $2
    echo " "
fi


read -p "Do you want to use the emails found for breached credentials? (y/n): " choice
if [[ $choice == "y" || $choice == "Y" || $choice == "yes" ]]; then

	echo -e "${YELLOW}[\] Searching emails from $2 for breached credentialas...${ENDCOLOR}"
	echo -e "${YELLOW}[\] Searching for beached credentials using h8mail...${ENDCOLOR}"
	h8mail -t $2 > $breached_credentials
	echo -e "${GREEN}[+] h8mail is done... Results saved on breached_credentials.txt"

	read -p "Do you want to view breached emails found? (y/n): "  view
	if [[ $view == "y" || $view == "Y" || $view == "yes" ]]; then
        	echo $breached_credentials
        	echo " "
	fi
fi
