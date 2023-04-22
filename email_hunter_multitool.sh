#!/usr/bin/env bash


## First and only argument
domain_name=$1

## Setting up colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

## Empty file variable
new_file="emails_found.txt"
breached_credentials="breached_credentials.txt"

## Create empty file to save all emails
touch $new_file
cat "" > $new_file

## Fire up theHarvester
echo -e "${YELLOW}[\] Searching emails using theHarverster...${ENDCOLOR}"
## theHarvester -d $domain_name -b all | grep "@" > $new_file
echo -e "${GREEN}[+] theHarvester done... Emails saved on emails_found.txt${ENDCOLOR}"

## Fire up emailHarvester
echo -e "${YELLOW}[\] Searching emails using emailHarverster...${ENDCOLOR}"
## emailharvester -d $domain_name -l 10 | grep "@" >> $new_file
echo -e "${GREEN}[+] emailHarvester done... Emails saved on emails_found.txt${ENDCOLOR}"

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
    echo "$emails" >> $new_file
done
echo -e "${GREEN}[+] Skymem.info done... Emails saved on emails_found.txt${ENDCOLOR}"

result=$(cat $new_file | wc -l)
echo -e "${GREEN}[+] ${result} emails has been found${ENDCOLOR}"

read -p "Do you want to view the emails found?: (y/n): " view
if [[ $view == "y" || $view == "Y" || $view == "yes" ]]; then
    cat $new_file
    echo " "
fi


read -p "Do you want to use the emails found for breached credentials? (y/n): " choice
if [[ $choice == "y" || $choice == "Y" || $choice == "yes" ]]; then

	echo -e "${YELLOW}[\] Searching emails from emails_found.txt for breached credentialas...${ENDCOLOR}"
	echo -e "${YELLOW}[\] Searching for beached credentials using h8mail...${ENDCOLOR}"
	h8mail -t $new_file > $breached_credentials
	echo -e "${GREEN}[+] h8mail is done... Results saved on breached_credentials.txt"

	read -p "Do you want to view breached emails found? (y/n): "  view
	if [[ $view == "y" || $view == "Y" || $view == "yes" ]]; then
        	echo $breached_credentials
        	echo " "
	fi
fi
