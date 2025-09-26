# BreachHunter v2.0.0

**BreachHunter** is a Bash utility that automates data-breach lookups using the Dehashed API.  
It extracts and organizes breach data into easily consumable files and can display full, untruncated results in verbose mode.


---

## Features

- Search by: **email, username, name, password, ip, phone, address, vin, license plate, cryptocurrency address, hashed password, domain**.
- Domain searches return broader results (costs more credits).
- Free password-hash lookup that does not consume API credits.
- Saves results into structured output directories (`emails.txt`, `passwords.txt`, ...).
- Generates a searchable `raw_response.json` and a `search_summary.txt`.
- Verbose mode shows **all** breach entries with no truncation.

---

## Requirements

Install on Debian/Ubuntu:
```bash
sudo apt update && sudo apt install -y curl jq
```

---

## Installation

```bash
git clone https://github.com/4m3rr0r/BreachHunter.git
cd BreachHunter
chmod +x BreachHunter.sh
```

Open the script and set your API key:

```bash
API_KEY="your_dehashed_api_key_here"
```


---

## Usage

```bash
./BreachHunter.sh [-v] OPTION VALUE [OUTPUT_DIR]
```

### Common options

**Basic searches (1 credit)**  
- `-e, --email` — Search by email address  
- `-n, --name` — Search by full name  
- `-u, --username` — Search by username  
- `-p, --password` — Search by plaintext password  
- `-ip, --ip-address` — Search by IP address  
- `-tel, --phone` — Search by phone number  
- `-a, --address` — Search by physical address

**Advanced searches (1 credit)**  
- `-vin, --vin` — Vehicle Identification Number  
- `-lp, --license-plate` — License plate  
- `-crypto, --crypto-addr` — Cryptocurrency address  
- `-H, --hashed-pwd` — Hashed password

**Domain search (2 credits)**  
- `-d, --domain` — Search by domain (returns related results)

**Free searches (0 credits)**  
- `-ph, --password-hash` — Check if a password hash is in breach data (free)

**Other**  
- `-s, --status` — Check API credits / status  
- `-v, --verbose` — Show full results in terminal (no truncation)  
- `-h, --help` — Show help menu  
- `-V, --version` — Show version info

---

## Examples

Verbose email search (shows all results + saves files):
```bash
./BreachHunter.sh -v -e target@example.com
```

Domain search:
```bash
./BreachHunter.sh -d example.com
```

Free password-hash check:
```bash
./BreachHunter.sh -ph 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8
```

VIN search:
```bash
./BreachHunter.sh -vin 1HGCM82633A123456
```

---

## Output

Search results are saved to a timestamped output directory, for example:

```
breach_results/email_target_20250926_153000/
├─ raw_response.json
├─ search_summary.txt
├─ emails.txt
├─ passwords.txt
├─ names.txt
├─ usernames.txt
├─ ip_addresses.txt
├─ phones.txt
├─ addresses.txt
├─ vins.txt
├─ license_plates.txt
├─ cryptocurrency_addresses.txt
├─ hashed_passwords.txt
└─ sources.txt
```

`search_summary.txt` contains a short summary with counts for each extracted file.

