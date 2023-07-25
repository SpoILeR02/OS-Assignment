#!/bin/bash

### GLOBAL VARIABLES ###
declare -r dataPath="$PWD/data_files"
declare -r receiptsPath="$PWD/receipts"

### GLOBAL ENDS HERE ###

### FORMATTING PURPOSE ###
print_centered() {
  [[ $# == 0 ]] && return 1

  declare -i -r TERM_COLS="$(tput cols)"
  declare -i -r str_len="${#1}"
  [[ $str_len -ge $TERM_COLS ]] && {
    echo "$1"
  }

  declare -i filler_len="$(((TERM_COLS - str_len) / 2))"
  [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
  filler=""
  for ((i = 0; i < filler_len; i++)); do
    filler="${filler}${ch}"
  done

  printf "%s%s%s" "$filler" "$1" "$filler"
  [[ $(((TERM_COLS - str_len) % 2)) -ne 0 ]] && printf "%s" "${ch}"
  printf "\n"
}

### FORMATTING ENDS HERE ###

### ENTIRE PROGRAM STARTS HERE ###
ChkFileExist() {
  if [ ! -f "$dataPath/$1" ]; then
    touch "$dataPath/$1"
  fi
}

AppendToFile() {
  echo "$2" >>"$dataPath/$1"
}

SearchInFile() {
  # result is global variable
  result=$(grep -w "$2" "$dataPath/$1") #| cut -d: -f1
}

PromptInput() {
  read -rp "Please Enter Your Option: " userOption

  if [ "$1" != "others" ]; then
    local validInputs=("A" "B" "C" "D" "E" "Q")
    # Convert to Uppercase using ^^, if require Lowercase use ,,
    while [[ ! "${validInputs[*]}" =~ (^| )"${userOption^^}"($| ) ]]; do
      echo -e "\nInvalid Option. Enter Only Single Character - [A], [B], [C], [D], [E] OR [Q]!"
      echo -e "Please Try Again!\n"
      read -rp "Please Enter Your Option: " userOption
    done

  else
    # Convert to Uppercase using ^^, if require Lowercase use ,,
    while [ "${userOption^^}" != "Y" ] && [ "${userOption^^}" != "N" ]; do
      echo -e "\nInvalid Option. Enter Only Single Character - [Y] or [N]!"
      echo -e "Please Try Again!\n"
      read -rp "Please Enter Your Option: " userOption
    done
  fi
}

ProgramHeader() {
  print_centered "=" "="
  print_centered "University Venue Management System"
  print_centered "=" "="
  print_centered "$1"
  print_centered "-" "-"
}

ProgramFooter() {
  print_centered "-" "-"
  print_centered "System Made by WongYanZhi & ChongXinNan | 2023 - RST3S1G1"
  print_centered "=" "="
  echo # Blank Line, \n
}

ExitProgram() {
  ProgramHeader "Exit Program"

  echo # Blank Line, \n
  print_centered "Thank You for using the University Venue Management System"
  print_centered "Hope to see you soon!"
  echo # Blank Line, \n

  ProgramFooter
}

UserSelection() {
  echo # Blank Line, \n
  print_centered "-" "-"
  echo "[Y] $1"
  echo "[N] Return to Main Menu"

  ProgramFooter

  PromptInput "others"
  if [ "${userOption^^}" == "Y" ]; then
    clear
    $2
  else
    clear
    MainMenu
  fi
}

RegisterPatron() {
  local patronID
  local patronName
  local patronContact
  local patronEmail
  ChkFileExist "patron.txt"

  ProgramHeader "Patron Registration"

  print_centered "Please Enter Patron's Detail According to the Format Below"
  echo # Blank Line, \n

  # Ensure only 4 or 7 digits are entered as input
  while true; do
    read -rp $'Patron ID [As per TAR UMT Format]\t: ' patronID
    SearchInFile "patron.txt" "^$patronID" # Search the entered patronID

    if [[ -z $patronID ]]; then
      echo -e "\nInvalid input. Patron ID cannot be empty!\n"
    elif [[ ! $patronID =~ ^[0-9]{4}$ && ! $patronID =~ ^[0-9]{7}$ ]]; then
      echo -e "\nInvalid input. Patron ID must be 4 or 7 digits!\n"
    elif [[ -n $result ]]; then # No duplicate of data (Patron ID) is allowed
      echo -e "\nInvalid input. Patron ID entered was found in database, NO DUPLICATION of Patron ID is allowed!\n"
    else
      break
    fi
  done

  # Ensure name only contain alphabets and space
  while true; do
    read -rp $'Patron Full Name [As per NRIC]\t\t: ' patronName

    if [[ -z $patronName ]]; then
      echo -e "\nInvalid input. Name cannot be empty!\n"
    elif [[ ! $patronName =~ ^[a-zA-Z[:space:]]+$ ]]; then
      echo -e "\nInvalid input. Name should not contain characters other than alphabets!\n"
    else
      break
    fi
  done

  # Ensure contact number met the pattern XXX-XXXXXXX [10 digits] OR XXX-XXXXXXXX [11 digits]
  while true; do
    read -rp $'Contact Number\t\t\t\t: ' patronContact

    if [[ -z "$patronContact" ]]; then
      echo -e "\nInvalid input. Contact number cannot be empty.\n"
    # Check if the input matches the phone number pattern
    elif [[ ! "$patronContact" =~ ^[0-9]{10,11}$ && ! "$patronContact" =~ ^[0-9]{3}-[0-9]{7,8}$ ]]; then
      echo -e "\nInvalid input. Please enter the phone number in the correct format."
      echo "[FORMAT 1]: XXX-XXXXXXX [10 digits/ 11 digits]"
      echo -e "[FORMAT 2]: XXXXXXXXXXX [10 digits/ 11 digits]\n"
    else
      # If the user entered only numerics and the number of digits is 10 or 11,
      # add a dash after the third digit
      if [[ "${patronContact:3:1}" != "-" ]]; then
        patronContact="${patronContact:0:3}-${patronContact:3}"
      fi
      break
    fi
  done

  # Ensure Email Address met the pattern *@tarc.edu.my OR *@student.tarc.edu.my
  while true; do
    read -rp $'Email Address [As per TAR UMT Format]\t: ' patronEmail
    # Check if the input is empty
    if [[ -z "$patronEmail" ]]; then
      echo -e "\nInvalid input. Please Email address cannot be empty.\n"
    # Check if the email matches the specified patterns
    elif [[ ! "$patronEmail" =~ ^.+@student.tarc.edu.my$ && ! "$patronEmail" =~ ^.+@tarc.edu.my$ ]]; then
      echo -e "\nInvalid input. Please enter the Email Address in the correct format."
      echo -e "[FORMAT 1]: *@tarc.edu.my\t\t[For Staff]"
      echo -e "[FORMAT 2]: *@student.tarc.edu.my\t[For Student]\n"
    else
      break
    fi
  done

  local combinedString
  combinedString="$patronID;$patronName;$patronContact;$patronEmail"
  AppendToFile "patron.txt" "$combinedString"

  UserSelection "Register For New Patron" RegisterPatron
}

# A Function to be used in SearchPatron & PatronValidation
IdentifyPatron() {
  local patronID
  ChkFileExist "patron.txt"

  ProgramHeader "$1"

  echo # Blank Line, \n
  # Ensure only 4 or 7 digits are entered as input
  while true; do
    read -rp $'Please Enter Patron ID [As per TAR UMT Format]: ' patronID

    if [[ -z $patronID ]]; then
      echo -e "\nInvalid input. Patron ID cannot be empty!\n"
    elif [[ ! $patronID =~ ^[0-9]{4}$ && ! $patronID =~ ^[0-9]{7}$ ]]; then
      echo -e "\nInvalid input. Patron ID must be 4 or 7 digits!\n"
    else
      break
    fi
  done

  echo # Blank Line, \n
  print_centered "-" "-"
  # Force match the line starts with the given Patron ID
  SearchInFile "patron.txt" "^$patronID"
}

SearchPatron() {
  local subStrings

  IdentifyPatron "Search Patron Details"

  if [ -z "$result" ]; then
    echo "No Record Found!"
  else
    IFS=";"
    read -ra subStrings <<<"$result"
    IFS=$DEFAULT_IFS

    echo -e "Full Name\t[Auto Display]: ${subStrings[0]}"
    echo -e "Contact Number\t[Auto Display]: ${subStrings[1]}"
    echo -e "Email Address\t[Auto Display]: ${subStrings[2]}"
  fi

  UserSelection "Search For Another Patron" SearchPatron
}

AddVenue() {
  local blockName
  local roomNumber
  local roomType
  local roomCapacity
  local roomRemarks
  ChkFileExist "venue.txt"

  ProgramHeader "Add New Venue"

  print_centered "Please Enter Venue's Detail According to the Format Below"
  echo

  # TODO: Add Validation for VENUE INPUT [Register Venue]
  read -rp $'Block Name\t: ' blockName
  read -rp $'Room Number\t: ' roomNumber
  read -rp $'Room Type\t: ' roomType
  read -rp $'Room Capacity\t: ' roomCapacity
  read -rp $'Room Remarks\t: ' roomRemarks
  echo -e "Room Status\t: Available (Default)"

  local combinedString
  combinedString="$blockName;$roomNumber;$roomType;$roomCapacity;$roomRemarks"
  AppendToFile "venue.txt" "$combinedString"

  UserSelection "Add Another New Venue" AddVenue
}

ListVenue() {
  local blockName
  local venueArray
  local subStrings
  ChkFileExist "venue.txt"
  ChkFileExist "booking.txt"

  ProgramHeader "List Venue Details"

  # TODO: Add Validation for BLOCK NAME INPUT [SEARCH Venue]
  echo # Blank Line, \n
  read -rp $'Please Enter Block Name: ' blockName
  echo # Blank Line, \n

  print_centered "-" "-"
  # Force match the line starts with the given blockName
  SearchInFile "venue.txt" "^$blockName"

  if [ -z "$result" ]; then
    echo "No Record Found!"
  else
    # TODO: Add Read value from booking.txt to display status
    echo -e "Room Number\tRoom Type\t\tCapacity\tRemarks\t\t\t\tStatus"
    print_centered "-" "-"
    readarray -t venueArray <<<"$result"

    # TODO: Check if the venue is booked, if yes then show UNAVAILABLE
    IFS=";"
    for line in "${venueArray[@]}"; do
      read -ra subStrings <<<"$line"

      for index in "${!subStrings[@]}"; do
        if [ "$index" = 0 ]; then # Don't display Block Name
          continue
        fi
        echo -ne "${subStrings[index]}\t\t"
      done

      echo "Available" #Temperorily Hardcoded
    done

    IFS=$DEFAULT_IFS
  fi

  UserSelection "Search For Another Block Venue" ListVenue
}

PatronValidation() {
  # patronDetailsBooking is global variable
  local subStrings

  IdentifyPatron "Patron Details Validation"

  if [ -z "$result" ]; then
    echo "Validation Failed! Patron ID is not found!"
    UserSelection "Retry Patron Validation" PatronValidation
  else
    IFS=";"
    read -ra subStrings <<<"$result"
    IFS=$DEFAULT_IFS

    patronDetailsBooking=("${subStrings[0]}" "${subStrings[1]}")
    echo -e "Patron Name [Auto Display]: ${subStrings[1]}"
    UserSelection "Proceed to Book Venue" BookVenue
  fi
}

BookVenue() {
  local roomNumber
  ChkFileExist "venue.txt"
  ChkFileExist "booking.txt"

  ProgramHeader "Booking Venue"

  # TODO: Add Validation for ROOM NUMBER INPUT [Book Venue]
  echo # Blank Line, \n
  read -rp $'Please Enter Room Number: ' roomNumber
  echo # Blank Line, \n

  print_centered "-" "-"

  SearchInFile "venue.txt" "^[^;]*;$roomNumber"

  if [ -z "$result" ]; then
    echo "Invalid Room Number! Room Number is not found!"
    UserSelection "Retry Booking" BookVenue
  else
    IFS=";"
    read -ra subStrings <<<"$result"
    IFS=$DEFAULT_IFS

    echo -e "Room Type\t[Auto Display]: ${subStrings[2]}"
    echo -e "Capacity\t[Auto Display]: ${subStrings[3]}"
    echo -e "Remarks\t\t[Auto Display]: ${subStrings[4]}"
    # TODO: Add IF-ELSE to check status from booking.txt
    echo -e "Status\t\t[Auto Display]: Available (Temp Hardcoded)"

    echo # Blank Line, \n
    print_centered "-" "-"
    echo -e "Notes:\tThe booking hours shall be from 0800hrs (8.00am) to 2000hrs (8.00pm) only."
    echo -e "\tThe booking duration shall be at least 30 minutes per booking."

    echo # Blank Line, \n
    print_centered "-" "-"
    print_centered "Please Enter Booking Details According to the Format Below"

    # TODO: Add Validation for BOOKING DETAILS INPUT [Book Venue]
    # Variables below are global variables
    echo # Blank Line, \n
    read -rp $'Booking Date\t\t[DD/MM/YYYY]\t: ' bookingDate
    read -rp $'Booking From\t\t[HH:MM]\t\t: ' bookingTimeFrom
    read -rp $'Booking Until\t\t[HH:MM]\t\t: ' bookingTimeTo
    read -rp $'Booking Purpose\t\t\t\t: ' bookingPurpose

    UserSelection "Save & Generate the Booking Slip" "GenerateBookingSlip"
  fi
}

GenerateBookingSlip() {
  local currentDateTime
  local combinedString
  local generatedReceiptFile

  currentDateTime=$(date "+%d/%m/%Y %H:%M:%S")
  combinedString="${patronDetailsBooking[0]};${patronDetailsBooking[1]};$roomNumber;$bookingDate;$bookingTimeFrom;$bookingTimeTo;$bookingPurpose"
  generatedReceiptFile="$receiptsPath/${patronDetailsBooking[0]}_${roomNumber}_$(date "+%d-%m-%Y %H%M%S").txt"
  AppendToFile "booking.txt" "$combinedString"

  cat >>"$generatedReceiptFile" <<EOF

                            Venue Booking Slip

Patron ID: ${patronDetailsBooking[0]}                                    Patron Name: ${patronDetailsBooking[1]}

Room Number: $roomNumber

Booking Date: $bookingDate

Booking From: $bookingTimeFrom                                  Booking Until: $bookingTimeTo

Booking Purpose: $bookingPurpose

    This is a system generated booking slip with no signature required.

                      Printed on $currentDateTime
EOF

  ProgramHeader "Generated Booking Slip"
  cat "$generatedReceiptFile"

  UserSelection "Register For Another Booking" MainMenu
}

MainMenu() {
  ProgramHeader "Main Menu"

  echo "A - Register New Patron"
  echo "B - Search Patron Details"
  echo "C - Add New Venue"
  echo "D - List Venue"
  echo "E - Book Venue"

  echo # Blank Line, \n
  print_centered "-" "-"
  echo "Q - Exit Program"

  ProgramFooter

  PromptInput "main"
  # Convert to Uppercase using ^^, if require Lowercase use ,,
  case "${userOption^^}" in
  [A])
    clear
    RegisterPatron
    ;;

  [B])
    clear
    SearchPatron
    ;;

  [C])
    clear
    AddVenue
    ;;

  [D])
    clear
    ListVenue
    ;;

  [E])
    clear
    PatronValidation
    ;;

  [Q])
    clear
    ExitProgram
    exit 0
    ;;

  esac
}

StartProgram() {
  # DEFAULT_IFS is global variable
  clear
  DEFAULT_IFS=$IFS

  if [ ! -d "$dataPath" ]; then
    mkdir "$dataPath"
    mkdir "$receiptsPath"
    MainMenu
  else
    MainMenu
  fi
}

StartProgram
##################################
