#!/bin/bash

# name   : BreachHunter
# url    : https://github.com/4m3rr0r/
# author : 4m3rr0r

RED1='\033[5;31m'
RED='\033[1;31m'
GREEN='\033[0;32m'
PURPLE='\033[95m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

api_key="" # your_api_key_here
user_email="" # your_email_here
input=$1
file=$4

# Function to print banner
print_banner() {
    echo -e "${PURPLE}    ____                       __    __  __            __           "
    echo -e "   / __ )________  ____ ______/ /_  / / / /_  ______  / /____  _____"
    echo -e "  / __  / ___/ _ \/ __ \`/ ___/ __ \/ /_/ / / / / __ \/ __/ _ \/ ___/"
    echo -e " / /_/ / /  /  __/ /_/ / /__/ / / / __  / /_/ / / / / /_/  __/ /    "
    echo -e "/_____/_/   \___/\__,_/\___/_/ /_/_/ /_/\__,_/_/ /_/\__/\___/_/     "
    echo -e "${RESET}" | echo -e "${BLUE}                                      [v1.1.0]${RESET}" "${GREEN}[4m3rr0r] \n${RESET}" 
}

# Call the function to print the banner
print_banner

# Check if API key and user email are set
if [[ -z $api_key ]]; then
    echo -e "${RED1}API key is not set${RESET}"
    exit 1
fi

if [[ -z $user_email ]]; then
    echo -e "${RED1}User email is not set ${RESET}"
    exit 1
fi

# Function to make API call
make_api_call() {
    if [[ -z $2 ]]; then
        echo -e "${RED}$1 is not provided${RESET}"
        exit 1
    fi

    # Check if file name is provided
    if [[ -z $file ]]; then
        echo -e "${RED}File name is not provided${RESET}"
        exit 1
    fi

    # Create a directory to store the results
    mkdir -p "$file"

    # Make the API call
    curl -X GET "https://api.dehashed.com/search?query=${1}:${2}" -u "${user_email}:${api_key}" -H 'Accept: application/json' > temp.txt 2>/dev/null

    # Check if curl failed or returned empty response
    if [ $? -ne 0 ] || [ ! -s temp.txt ]; then
        echo -e "${RED}Error: API call failed or returned empty response${RESET}"
        exit 1
    fi

    balance=$(jq -r '.balance' temp.txt 2>/dev/null)
    if [[ "$balance" == "null" ]]; then
        echo -e "${RED}API key or email is invalid${RESET}"
        exit 1
    fi

        echo -e "${BLUE} balance : ${balance} ${RESET}"
        echo ""

    # Extract and process data from API response
    if jq -e '.entries[]' >/dev/null 2>&1 <<< "$(cat temp.txt)"; then
        cat temp.txt | jq -c '.entries[] | {ip_address, username, name, email, hashed_password, hash_type, password, phone, vin, address }' | sed 's/}{/}, {/g' | sed 's/[{""}]//g' 
        # Extract specific fields to separate files
        cat temp.txt | jq -c '.entries[] | {email}' | sed 's/}{/}, {/g' | sed 's/[{""}]//g' | grep -o 'email:[^,]*' | cut -d ':' -f 2 | grep -v '^$' > "$file/email.txt"
        cat temp.txt | jq -c '.entries[] | {password}' | sed 's/}{/}, {/g' | sed 's/[{""}]//g' | grep -o 'password:[^,]*' | cut -d ':' -f 2 | grep -v '^$' > "$file/password.txt"
        cat temp.txt | jq -c '.entries[] | {name}' | sed 's/}{/}, {/g' | sed 's/[{""}]//g' | grep -o 'name:[^,]*' | cut -d ':' -f 2 | grep -v '^$' > "$file/name.txt"
        cat temp.txt | jq -c '.entries[] | {hashed_password}' | sed 's/}{/}, {/g' | sed 's/[{""}]//g' | grep -o 'hashed_password:[^,]*' | cut -d ':' -f 2 | grep -v '^$' > "$file/hashed_password.txt"
        cat temp.txt | jq -c '.entries[] | {phone}' | sed 's/}{/}, {/g' | sed 's/[{""}]//g' | grep -o 'phone:[^,]*' | cut -d ':' -f 2 | grep -v '^$' > "$file/phone.txt"
    else
        echo -e "${RED}Error: Data not found${RESET}"
        rm -rvf $file 2&>/dev/null;
        exit 1
    fi

    rm -f temp.txt
}

# Check input options and execute corresponding API calls
case $input in
    "-h" | "--help")
        echo "Usage: ${0:2} -e demo@example.com -f file_name "
        echo ""
        echo "  -h,  --help             Display this help menu"
        echo "  -v,  --version          Show program's version number and exit"
        echo "  -e   --email            Specify the email"
        echo "  -p   --password         Specify the password"
        echo "  -n   --name             Specify the name"
        echo "  -u   --username         Specify the username"
        echo "  -ip  --ip_address       Specify the ip address"
        echo "  -H   --hashed_password  Specify the hashed password"
        echo "  -ha  --hash_type        Specify the hash type"
        echo "  -vi  --vin              Specify the vin"
        echo "  -a   --address          Specify the address"
        echo "  -ph  --Phone            Specify the phone number"
        ;;
    "-e" | "-E" | "--email")
        make_api_call "email" "$2"
        ;;
    "-p" | "-P" | "--password")
        make_api_call "password" "$2"
        ;;
    "-n" | "-N" | "--name")
        make_api_call "name" "$2"
        ;;
    "-u" | "-U" | "--username")
        make_api_call "username" "$2"
        ;;
    "-ip" | "--ip_address")
        make_api_call "ip_address" "$2"
        ;;
    "-H" | "--hashed_password")
        make_api_call "hashed_password" "$2"
        ;;
    "-ha" | "-Ha" | "--hash_type")
        make_api_call "hash_type" "$2"
        ;;
    "-vi" | "-VI" | "--vin")
        make_api_call "vin" "$2"
        ;;
    "-a" | "-A" | "--address")
        make_api_call "address" "$2"
        ;;
    "-ph" | "-PH" | "--phone")
        make_api_call "phone" "$2"
        ;;
     "-v" | "-V" | "--version")
        echo -e "${YELLOW} Program version 1.1.0 ${RESET}"
        ;;
    *)
        echo -e "${RED}Invalid option: $input ${RESET}"
        echo "Usage: $0 -h or --help for help menu"
        exit 1
        ;;
esac
