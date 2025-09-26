#!/bin/bash

# name   : BreachHunter v2.0
# url    : https://github.com/4m3rr0r/BreachHunter.git
# author : 4m3rr0r

RED1='\033[5;31m'
RED='\033[1;31m'
GREEN='\033[0;32m'
PURPLE='\033[95m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

API_KEY=""
API_URL="https://api.dehashed.com/v2/search"

# Initialize variables
input=""
search_value=""
output_dir=""
verbose=false
timestamp=$(date +"%Y%m%d_%H%M%S")

# Function to print banner
print_banner() {
    echo -e "${PURPLE}    ____                       __    __  __            __           "
    echo -e "   / __ )________  ____ ______/ /_  / / / /_  ______  / /____  _____"
    echo -e "  / __  / ___/ _ \/ __ \`/ ___/ __ \/ /_/ / / / / __ \/ __/ _ \/ ___/"
    echo -e " / /_/ / /  /  __/ /_/ / /__/ / / / __  / /_/ / / / / /_/  __/ /    "
    echo -e "/_____/_/   \___/\__,_/\___/_/ /_/_/ /_/\__,_/_/ /_/\__/\___/_/     "
    echo -e "${RESET}" | echo -e "${BLUE}                                      [v2.0.0]${RESET}" "${GREEN}[4m3rr0r] \n${RESET}" 
}

# Function to check dependencies
check_dependencies() {
    local deps=("curl" "jq")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${RED}Error: $dep is not installed${RESET}"
            exit 1
        fi
    done
}

# Function to check API credits (simple version)
check_api_credits() {
    local response=$(curl -s -X POST "$API_URL" \
        -H "Dehashed-Api-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"query":"test","size":1}' 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to connect to API${RESET}"
        exit 1
    fi
    
    local error=$(echo "$response" | jq -r '.error' 2>/dev/null)
    if [[ "$error" != "null" && -n "$error" ]]; then
        echo -e "${RED}API Error: $error${RESET}"
        exit 1
    fi
    
    local balance=$(echo "$response" | jq -r '.balance' 2>/dev/null)
    if [[ "$balance" == "null" ]]; then
        echo -e "${RED}Invalid API key or insufficient credits${RESET}"
        exit 1
    fi
    
    echo $balance
}

# Fast JSON processing function with ALL fields
process_json_to_files() {
    local json_file="$1"
    local output_dir="$2"
    local field="$3"
    local value="$4"
    
    # Create output directory
    mkdir -p "$output_dir"
    
    # Extract ALL available fields from JSON
    jq -r '.entries[] | .email[]? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/emails.txt"
    jq -r '.entries[] | .password[]? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/passwords.txt"
    jq -r '.entries[] | .name[]? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/names.txt"
    jq -r '.entries[] | .hashed_password[]? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/hashed_passwords.txt"
    jq -r '.entries[] | .username[]? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/usernames.txt"
    jq -r '.entries[] | .ip_address[]? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/ip_addresses.txt"
    jq -r '.entries[] | .phone[]? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/phones.txt"
    jq -r '.entries[] | .address[]? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/addresses.txt"
    jq -r '.entries[] | .vin[]? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/vins.txt"
    jq -r '.entries[] | .license_plate[]? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/license_plates.txt"
    jq -r '.entries[] | .cryptocurrency_address[]? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/cryptocurrency_addresses.txt"
    jq -r '.entries[] | .database_name? // empty' "$json_file" 2>/dev/null | grep -v '^$' | sort -u > "$output_dir/sources.txt"
    
    # Create comprehensive summary
    local total=$(jq -r '.total' "$json_file" 2>/dev/null)
    cat > "$output_dir/search_summary.txt" << EOF
BreachHunter Search Summary
===========================
Search Type: $field
Search Value: $value
Timestamp: $(date)
Total Results: ${total:-0}

Files Created:
- emails.txt: $(wc -l < "$output_dir/emails.txt" 2>/dev/null || echo 0) unique emails
- passwords.txt: $(wc -l < "$output_dir/passwords.txt" 2>/dev/null || echo 0) unique passwords
- names.txt: $(wc -l < "$output_dir/names.txt" 2>/dev/null || echo 0) unique names
- usernames.txt: $(wc -l < "$output_dir/usernames.txt" 2>/dev/null || echo 0) unique usernames
- ip_addresses.txt: $(wc -l < "$output_dir/ip_addresses.txt" 2>/dev/null || echo 0) unique IPs
- phones.txt: $(wc -l < "$output_dir/phones.txt" 2>/dev/null || echo 0) unique phones
- addresses.txt: $(wc -l < "$output_dir/addresses.txt" 2>/dev/null || echo 0) unique addresses
- vins.txt: $(wc -l < "$output_dir/vins.txt" 2>/dev/null || echo 0) unique VINs
- license_plates.txt: $(wc -l < "$output_dir/license_plates.txt" 2>/dev/null || echo 0) unique plates
- cryptocurrency_addresses.txt: $(wc -l < "$output_dir/cryptocurrency_addresses.txt" 2>/dev/null || echo 0) unique addresses
- hashed_passwords.txt: $(wc -l < "$output_dir/hashed_passwords.txt" 2>/dev/null || echo 0) unique hashes
- sources.txt: $(wc -l < "$output_dir/sources.txt" 2>/dev/null || echo 0) unique sources
EOF
}

# Function to display ALL results from JSON file (NO TRUNCATION)
display_all_results_from_json() {
    local json_file="$1"
    local field="$2"
    local value="$3"
    local output="$4"
    
    local total=$(jq -r '.total' "$json_file" 2>/dev/null)
    local took=$(jq -r '.took' "$json_file" 2>/dev/null)
    
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${CYAN}│                    BREACH RESULTS                      │${RESET}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${RESET}"
    echo -e "${WHITE}Search: ${GREEN}$field: $value${RESET}"
    echo -e "${WHITE}Results: ${YELLOW}$total${WHITE} | Time: ${YELLOW}$took${RESET}"
    echo -e "${WHITE}Saved to: ${BLUE}$output${RESET}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${RESET}"
    echo ""
    
    if [[ "$total" -eq 0 ]] || [[ "$total" == "null" ]]; then
        echo -e "${YELLOW}No breach results found for your search.${RESET}"
        echo ""
        return
    fi
    
    # Display ALL results (no limit)
    local count=0
    jq -c '.entries[]' "$json_file" 2>/dev/null | while IFS= read -r entry; do
        if [[ -n "$entry" ]]; then
            ((count++))
            echo -e "${BLUE}╔═════════════════════════════════════════════════════╗${RESET}"
            
            # Extract ALL fields efficiently (NO TRUNCATION)
            local email=$(echo "$entry" | jq -r '.email[0]? // empty')
            local username=$(echo "$entry" | jq -r '.username[0]? // empty')
            local password=$(echo "$entry" | jq -r '.password[0]? // empty')
            local hashed_password=$(echo "$entry" | jq -r '.hashed_password[0]? // empty')
            local name=$(echo "$entry" | jq -r '.name[0]? // empty')
            local ip=$(echo "$entry" | jq -r '.ip_address[0]? // empty')
            local phone=$(echo "$entry" | jq -r '.phone[0]? // empty')
            local address=$(echo "$entry" | jq -r '.address[0]? // empty')
            local vin=$(echo "$entry" | jq -r '.vin[0]? // empty')
            local license_plate=$(echo "$entry" | jq -r '.license_plate[0]? // empty')
            local crypto=$(echo "$entry" | jq -r '.cryptocurrency_address[0]? // empty')
            local database=$(echo "$entry" | jq -r '.database_name? // empty')
            
            [[ -n "$email" ]] && echo -e "${BLUE}║ ${WHITE}Email:${RESET} ${GREEN}$email${RESET}"
            [[ -n "$username" ]] && echo -e "${BLUE}║ ${WHITE}Username:${RESET} ${YELLOW}$username${RESET}"
            [[ -n "$name" ]] && echo -e "${BLUE}║ ${WHITE}Name:${RESET} ${CYAN}$name${RESET}"
            [[ -n "$password" ]] && echo -e "${BLUE}║ ${WHITE}Password:${RESET} ${RED}$password${RESET}"
            [[ -n "$hashed_password" ]] && echo -e "${BLUE}║ ${WHITE}Hash:${RESET} ${PURPLE}$hashed_password${RESET}"
            [[ -n "$ip" ]] && echo -e "${BLUE}║ ${WHITE}IP:${RESET} ${GREEN}$ip${RESET}"
            [[ -n "$phone" ]] && echo -e "${BLUE}║ ${WHITE}Phone:${RESET} ${YELLOW}$phone${RESET}"
            [[ -n "$address" ]] && echo -e "${BLUE}║ ${WHITE}Address:${RESET} ${CYAN}$address${RESET}"
            [[ -n "$vin" ]] && echo -e "${BLUE}║ ${WHITE}VIN:${RESET} ${WHITE}$vin${RESET}"
            [[ -n "$license_plate" ]] && echo -e "${BLUE}║ ${WHITE}License:${RESET} ${WHITE}$license_plate${RESET}"
            [[ -n "$crypto" ]] && echo -e "${BLUE}║ ${WHITE}Crypto:${RESET} ${BLUE}$crypto${RESET}"
            [[ -n "$database" ]] && echo -e "${BLUE}║ ${WHITE}Source:${RESET} ${WHITE}$database${RESET}"
            
            echo -e "${BLUE}╚═════════════════════════════════════════════════════╝${RESET}"
            echo ""
        fi
    done
    
    echo -e "${GREEN}Displayed all $count results${RESET}"
    echo ""
}

# Main search function (OPTIMIZED)
perform_search() {
    local field=$1
    local value=$2
    local custom_output=$3
    local display=$4  # true/false for verbose display

    # Validate input
    if [[ -z "$value" ]]; then
        echo -e "${RED}Error: Search value is required${RESET}"
        exit 1
    fi

    # Calculate cost
    local cost=1
    [[ "$field" == "domain" ]] && cost=2
    
    # Check credits
    echo -e "${YELLOW}Checking API credits...${RESET}"
    local current_credits=$(check_api_credits)
    
    if [[ "$current_credits" -lt "$cost" ]]; then
        echo -e "${RED}Insufficient credits! Need $cost credit(s), have $current_credits${RESET}"
        exit 1
    fi

    # Generate output directory
    local safe_value=$(echo "$value" | tr -cd '[:alnum:]._-')
    local output_dir="${custom_output:-"breach_results/${field}_${safe_value}_$timestamp"}"
    
    echo -e "${YELLOW}Searching ${field}: $value (Cost: ${cost} credit)${RESET}"
    echo -e "${BLUE}Output: $output_dir${RESET}"
    echo ""

    # Create temp file for JSON response
    local temp_json=$(mktemp)
    
    # Make API call
    local response=$(curl -s -X POST "$API_URL" \
        -H "Dehashed-Api-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"query\":\"$field:$value\", \"size\": 100, \"page\": 1, \"de_dupe\": true}")
    
    # Check for errors
    local error=$(echo "$response" | jq -r '.error' 2>/dev/null)
    if [[ "$error" != "null" && -n "$error" ]]; then
        echo -e "${RED}API Error: $error${RESET}"
        rm -f "$temp_json"
        exit 1
    fi

    # Save raw response to temp file
    echo "$response" > "$temp_json"
    
    # Extract new balance
    local new_balance=$(echo "$response" | jq -r '.balance' 2>/dev/null)
    
    local total=$(echo "$response" | jq -r '.total' 2>/dev/null)
    local took=$(echo "$response" | jq -r '.took' 2>/dev/null)
    
    echo -e "${GREEN}Search completed in $took | Results: $total | Credits left: $new_balance${RESET}"
    echo ""

    if [[ "$total" -eq 0 ]]; then
        echo -e "${YELLOW}No results found${RESET}"
        rm -f "$temp_json"
        rm -rf "$output_dir"
        return
    fi

    # FAST PROCESSING: Save JSON first, then extract
    mkdir -p "$output_dir"
    cp "$temp_json" "$output_dir/raw_response.json"
    
    # Process JSON to text files (FAST)
    process_json_to_files "$temp_json" "$output_dir" "$field" "$value"
    
    echo -e "${GREEN}Results saved to: $output_dir/${RESET}"
    
    # Display if verbose mode (SHOW ALL RESULTS)
    if [[ "$display" == "true" ]]; then
        echo ""
        display_all_results_from_json "$temp_json" "$field" "$value" "$output_dir"
    fi
    
    # Cleanup temp file
    rm -f "$temp_json"
}

# FREE Password hash search function
password_hash_search_free() {
    local hash_value=$1

    if [[ -z "$hash_value" ]]; then
        echo -e "${RED}Hash value is required${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}Checking password hash (FREE)${RESET}"
    echo -e "${GREEN}This search does not use any credits${RESET}"
    echo ""
    
    local response=$(curl -s -X POST "https://api.dehashed.com/v2/search-password" \
        -H "Dehashed-Api-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"sha256_hashed_password\": \"$hash_value\"}")

    local results=$(echo "$response" | jq -r '.results_found' 2>/dev/null)
    
    if [[ "$results" -gt 0 ]]; then
        echo -e "${RED}CRITICAL: Password found in $results breach(es)!${RESET}"
        echo -e "${RED}DO NOT USE THIS PASSWORD - IT'S COMPROMISED!${RESET}"
    else
        echo -e "${GREEN}Password not found in known breaches${RESET}"
        echo -e "${GREEN}This password appears to be safe based on current breach data${RESET}"
    fi
}

# Parse arguments efficiently
parse_arguments() {
    case "$1" in
        "-v"|"--verbose")
            verbose=true
            input="$2"
            search_value="$3"
            output_dir="$4"
            ;;
        *)
            verbose=false
            input="$1"
            search_value="$2" 
            output_dir="$3"
            ;;
    esac
}

# ===== MAIN EXECUTION =====
print_banner
check_dependencies

# Handle help menu (NO API CALLS)
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    echo "Usage: $0 [-v] OPTION VALUE [OUTPUT_DIR]"
    echo ""
    echo "BASIC SEARCHES (1 credit):"
    echo "  -e,  --email             Search by email address"
    echo "  -n,  --name              Search by full name" 
    echo "  -u,  --username          Search by username"
    echo "  -p,  --password          Search by plaintext password"
    echo "  -ip, --ip-address        Search by IP address"
    echo "  -tel,--phone             Search by phone number"
    echo "  -a,  --address           Search by physical address"
    
    echo ""
    echo "ADVANCED SEARCHES (1 credit):"
    echo "  -vin, --vin              Search by Vehicle Identification Number"
    echo "  -lp,  --license-plate    Search by license plate"
    echo "  -crypto, --crypto-addr   Search by cryptocurrency address"
    echo "  -H,   --hashed-pwd       Search by hashed password"
    
    echo ""
    echo "DOMAIN SEARCH (2 credits):"
    echo "  -d,  --domain            Search by domain (returns all related data)"
    
    echo ""
    echo "FREE SEARCHES (0 credits):"
    echo "  -ph, --password-hash     Check if password hash is in breaches (FREE)"
    
    echo ""
    echo "INFORMATION (0 credits):"
    echo "  -h,  --help              Show this help menu"
    echo "  -v,  --verbose           Display ALL results + auto-save files"
    echo "  -s,  --status            Check current credits"
    echo "  -V,  --version           Show version information"
    
    echo ""
    echo "EXAMPLES:"
    echo "  $0 -v -e target@example.com              # Verbose email search (shows all results)"
    echo "  $0 -d example.com                        # Domain search"
    echo "  $0 -ph 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"
    echo "  $0 -vin 1HGCM82633A123456               # VIN search"
    echo "  $0 -lp ABC123                           # License plate search"
    echo ""
    exit 0
fi

# Parse arguments
parse_arguments "$1" "$2" "$3" "$4"

# Execute based on input
case "$input" in
    "-v"|"--version"|"-V")
        echo -e "${YELLOW}BreachHunter v2.0 - Complete & Optimized${RESET}"
        echo -e "${BLUE}Includes all search fields: VIN, License Plates, Crypto Addresses${RESET}"
        echo -e "${BLUE}Shows FULL results in verbose mode (no truncation)${RESET}"
        ;;
    "-s"|"--status")
        echo -e "${YELLOW}Checking API status...${RESET}"
        credits=$(check_api_credits)
        echo -e "${GREEN}API Status: OK${RESET}"
        echo -e "${BLUE}Available Credits: $credits${RESET}"
        ;;
        
    # Basic searches (1 credit)
    "-e"|"--email")
        perform_search "email" "$search_value" "$output_dir" "$verbose"
        ;;
    "-p"|"--password") 
        perform_search "password" "$search_value" "$output_dir" "$verbose"
        ;;
    "-n"|"--name")
        perform_search "name" "$search_value" "$output_dir" "$verbose"
        ;;
    "-u"|"--username")
        perform_search "username" "$search_value" "$output_dir" "$verbose"
        ;;
    "-ip"|"--ip-address")
        perform_search "ip_address" "$search_value" "$output_dir" "$verbose"
        ;;
    "-tel"|"--phone")
        perform_search "phone" "$search_value" "$output_dir" "$verbose"
        ;;
    "-a"|"--address")
        perform_search "address" "$search_value" "$output_dir" "$verbose"
        ;;
        
    # Advanced searches (1 credit)  
    "-vin"|"--vin")
        perform_search "vin" "$search_value" "$output_dir" "$verbose"
        ;;
    "-lp"|"--license-plate")
        perform_search "license_plate" "$search_value" "$output_dir" "$verbose"
        ;;
    "-crypto"|"--crypto-addr")
        perform_search "cryptocurrency_address" "$search_value" "$output_dir" "$verbose"
        ;;
    "-H"|"--hashed-pwd")
        perform_search "hashed_password" "$search_value" "$output_dir" "$verbose"
        ;;
        
    # Domain search (2 credits)
    "-d"|"--domain")
        perform_search "domain" "$search_value" "$output_dir" "$verbose"
        ;;
        
    # FREE searches (0 credits)
    "-ph"|"--password-hash")
        password_hash_search_free "$search_value"
        ;;
        
    *)
        echo -e "${RED}Error: Invalid option '$input'${RESET}"
        echo "Use $0 -h for help"
        exit 1
        ;;
esac
