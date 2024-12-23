#!/bin/bash

RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}-FixerMac- | By S3RGI09${RESET}"
echo -e "${GREEN}v3.3 stable${RESET}"

if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run this script with superuser permissions (sudo).${RESET}"
    exit 1
fi

function create_report {
    echo -e "${ORANGE}Creating error report...${RESET}"
    echo "# Error Report - $(date)" > report.md
    echo "$1" >> report.md
    echo -e "${GREEN}The report has been created in 'report.md'.${RESET}"
}

function check_errors {
    echo -e "${ORANGE}Starting system check...${RESET}"
    
    echo -e "${ORANGE}Checking file system errors...${RESET}"
    if ! diskutil verifyVolume / > /dev/null; then
        echo -e "${RED}Error: Corrupt file system.${RESET}"
        create_report "Error in file system verification."
    fi

    echo -e "${ORANGE}Checking kernel extensions...${RESET}"
    if kextstat | grep -v com.apple > /dev/null; then
        echo -e "${ORANGE}Found unofficial kernel extensions. Checking their status...${RESET}"
        kextstat | grep -v com.apple | while read -r kext; do
            if ! kextstat | grep -q "$kext"; then
                echo -e "${RED}Error: The kext $kext is not loading correctly.${RESET}"
                create_report "Error: The kext $kext is not loading correctly."
            fi
        done
    else
        echo -e "${GREEN}No unofficial kernel extensions found.${RESET}"
    fi

    echo -e "${ORANGE}Checking system logs...${RESET}"
    if log show --predicate 'eventMessage contains "error"' --info --last 1h | grep -q "error"; then
        echo -e "${RED}Found errors in the system logs.${RESET}"
        create_report "Errors found in system logs."
    fi

    echo -e "${ORANGE}Checking disk space...${RESET}"
    free_space=$(diskutil info / | grep "Free Space" | awk '{print $3}' | tr -d '()')
    if [[ "$free_space" =~ ^[0-9]+$ ]] && [ "$free_space" -lt 100000000 ]; then
        echo -e "${RED}Error: Low disk space.${RESET}"
        create_report "Error: Insufficient disk space ($free_space bytes)."
    fi

    echo -e "${ORANGE}Checking system time...${RESET}"
    system_time=$(date +%s)
    ntp_time=$(date -u +%s -d @$(curl -s --head http://time.apple.com | grep -i ^date: | sed 's/Date: //'))

    if [ "$system_time" -ne "$ntp_time" ]; then
        echo -e "${RED}Error: System time is incorrect.${RESET}"
        create_report "Error: System time is incorrect."
    else
        echo -e "${GREEN}System time is correct.${RESET}"
    fi
}

function fix_errors {
    echo -e "${ORANGE}Fixing detected errors...${RESET}"
    
    echo -e "${ORANGE}1. Repairing the file system with 'diskutil repairVolume'.${RESET}"
    read -p "Do you want to continue with this operation? (y/n): " confirm_diskutil
    if [[ "$confirm_diskutil" == "y" ]]; then
        if ! diskutil repairVolume / > /dev/null; then
            echo -e "${RED}Error: Could not repair the file system.${RESET}"
            create_report "Error while attempting to repair the file system."
        else
            echo -e "${GREEN}File system successfully repaired.${RESET}"
        fi
    else
        echo -e "${ORANGE}File system repair skipped.${RESET}"
    fi

    echo -e "${ORANGE}2. Rebuilding the kernel cache with 'kextcache'.${RESET}"
    read -p "Do you want to continue with this operation? (y/n): " confirm_kextcache
    if [[ "$confirm_kextcache" == "y" ]]; then
        if ! kextcache -i / > /dev/null; then
            echo -e "${RED}Error: Could not rebuild the kernel cache.${RESET}"
            create_report "Error while rebuilding the kernel cache."
        else
            echo -e "${GREEN}Kernel cache successfully rebuilt.${RESET}"
        fi
    else
        echo -e "${ORANGE}Kernel cache rebuild skipped.${RESET}"
    fi

    echo -e "${ORANGE}3. Clearing the system cache.${RESET}"
    read -p "Do you want to clear the system cache? (y/n): " confirm_cache
    if [[ "$confirm_cache" == "y" ]]; then
        echo -e "${YELLOW}WARNING: This action will delete temporary files that could cause issues if in use.${RESET}"
        read -p "Are you sure you want to continue? (y/n): " double_confirm_cache
        if [[ "$double_confirm_cache" == "y" ]]; then
            if ! sudo rm -rf /Library/Caches/* /System/Library/Caches/* /var/folders/* > /dev/null; then
                echo -e "${RED}Error: Could not clear the system cache.${RESET}"
                create_report "Error while attempting to clear the system cache."
            else
                echo -e "${GREEN}System cache cleared successfully.${RESET}"
            fi
        else
            echo -e "${ORANGE}Cache clearing canceled.${RESET}"
        fi
    else
        echo -e "${ORANGE}Cache clearing skipped.${RESET}"
    fi

    echo -e "${ORANGE}4. Adjusting the system time with NTP.${RESET}"
    read -p "Do you want to adjust the system time? (y/n): " confirm_time_adjustment
    if [[ "$confirm_time_adjustment" == "y" ]]; then
        sudo systemsetup -setnetworktimeserver time.apple.com
        sudo systemsetup -setusingnetworktime on
        echo -e "${GREEN}System time successfully adjusted.${RESET}"
    else
        echo -e "${ORANGE}Time adjustment skipped.${RESET}"
    fi
}

check_errors

read -p "Do you want to attempt to fix the detected errors? (y/n): " fix
if [[ "$fix" == "y" ]]; then
    fix_errors
    echo -e "${GREEN}Correction process completed.${RESET}"
else
    echo -e "${ORANGE}No corrections made.${RESET}"
fi

if [ -f report.md ]; then
    echo -e "${GREEN}An error report has been generated: 'report.md'. Check the file for more details.${RESET}"
fi
