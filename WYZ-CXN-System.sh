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
    #return
  }

  declare -i filler_len="$(((TERM_COLS - str_len) / 2))"
  [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
  filler=""

  local counter=0
  while [[ $counter -lt $filler_len ]]; do
    filler="${filler}${ch}"
    ((counter += 1))
  done

  echo -n "$filler$1$filler"
  [[ $(((TERM_COLS - str_len) % 2)) -ne 0 ]] && echo -n "${ch}"
  echo
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
  result=$(grep -w "$2" "$dataPath/$1" | sort) #| cut -d: -f1
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
    $2 "${@:3}"
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
      echo -e "\nInvalid input. Patron ID cannot be EMPTY!\n"
    elif [[ ! $patronID =~ ^[0-9]{4}$ && ! $patronID =~ ^[0-9]{2}[A-Z]{3}[0-9]{5}$ ]]; then
      echo -e "\nInvalid input. Please enter the Patron ID in the correct FORMAT"
      echo -e "[FORMAT 1]: XXXX\t[4 digits]"
      echo -e "[FORMAT 2]: XXAAAXXXXX\t[2 digits + 3 uppercase alphabets + 5 digits]\n"
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
      echo -e "\nInvalid input. Name cannot be EMPTY!\n"
    elif [[ ! $patronName =~ ^[a-zA-Z[:space:]]+$ ]]; then
      echo -e "\nInvalid input. Name should only contain ALPHABETS!\n"
    else
      break
    fi
  done

  # Ensure contact number met the pattern XXX-XXXXXXX [10 digits] OR XXX-XXXXXXXX [11 digits]
  while true; do
    read -rp $'Contact Number\t\t\t\t: ' patronContact

    if [[ -z "$patronContact" ]]; then
      echo -e "\nInvalid input. Contact number cannot be EMPTY.\n"
    # Check if the input matches the phone number pattern
    elif [[ ! "$patronContact" =~ ^[0-9]{10,11}$ && ! "$patronContact" =~ ^[0-9]{3}-[0-9]{7,8}$ ]]; then
      echo -e "\nInvalid input. Please enter the phone number in the correct FORMAT."
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
      echo -e "\nInvalid input. Please Email address cannot be EMPTY.\n"
    # Check if the email matches the specified patterns
    elif [[ ! "$patronEmail" =~ ^.+@student.tarc.edu.my$ && ! "$patronEmail" =~ ^.+@tarc.edu.my$ ]]; then
      echo -e "\nInvalid input. Please enter the Email Address in the correct FORMAT."
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
      echo -e "\nInvalid input. Patron ID cannot be EMPTY!\n"
    elif [[ ! $patronID =~ ^[0-9]{4}$ && ! $patronID =~ ^[0-9]{2}[A-Z]{3}[0-9]{5}$ ]]; then
      echo -e "\nInvalid input. Please enter the Patron ID in the correct FORMAT"
      echo -e "[FORMAT 1]: XXXX\t[4 digits]"
      echo -e "[FORMAT 2]: XXAAAXXXXX\t[2 digits + 3 uppercase alphabets + 5 digits]\n"
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

    echo -e "Full Name\t[Auto Display]: ${subStrings[1]}"
    echo -e "Contact Number\t[Auto Display]: ${subStrings[2]}"
    echo -e "Email Address\t[Auto Display]: ${subStrings[3]}"
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

  # Ensure only one or two character was entered as input
  while true; do
    read -rp $'Block Name\t: ' blockName

    if [[ -z $blockName ]]; then
      echo -e "\nInvalid input. Block Name cannot be EMPTY!\n"
    elif [[ ! $blockName =~ ^[a-zA-Z]{1,2}$ ]]; then
      echo -e "\nInvalid input. Block Name must be ONE or TWO alphabets!\n"
    else
      break
    fi
  done

  # Ensure the room number starts with the block name, and only accept maximum 4 alphanumeric characters
  while true; do
    read -rp $'Room Number\t: ' roomNumber
    SearchInFile "venue.txt" "^[^;]*;$roomNumber"

    if [[ -z $roomNumber ]]; then
      echo -e "\nInvalid input. Room Number cannot be empty!\n"
    elif [[ ! $roomNumber =~ ^${blockName}[[:alnum:]]{3,4}$ ]]; then
      echo -e "\nInvalid input. Room Number must starts with Block Name and followed by THREE or FOUR ALPHANUMERIC CHARACTER!\n"
    elif [[ -n $result ]]; then # No duplicate of data (Patron ID) is allowed
      echo -e "\nInvalid input. Room Number entered was found in database, NO DUPLICATION of Room Number is allowed!\n"
    else
      break
    fi
  done

  # Ensure room type only contain alphabets and space
  while true; do
    read -rp $'Room Type\t: ' roomType

    if [[ -z $roomType ]]; then
      echo -e "\nInvalid input. Name cannot be EMPTY!\n"
    elif [[ ! $roomType =~ ^[a-zA-Z[:space:]]+$ ]]; then
      echo -e "\nInvalid input. Name should only contain ALPHABETS!\n"
    else
      break
    fi
  done

  # Ensure room capacity only accept digits as input
  while true; do
    read -rp $'Room Capacity\t: ' roomCapacity

    if [[ -z $roomCapacity ]]; then
      echo -e "\nInvalid input. Room Capacity cannot be EMPTY!\n"
    elif [[ ! $roomCapacity =~ ^[0-9]+$ ]]; then
      echo -e "\nInvalid input. Room Capacity should only contain DIGITS!\n"
    else
      break
    fi
  done

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
  local roomStatus
  local subStrings
  ChkFileExist "venue.txt"
  ChkFileExist "booking.txt"

  ProgramHeader "List Venue Details"

  echo # Blank Line, \n
  # Ensure only one or two character was entered as input
  while true; do
    read -rp $'Please Enter Block Name: ' blockName

    if [[ -z $blockName ]]; then
      echo -e "\nInvalid input. Block Name cannot be EMPTY!\n"
    elif [[ ! $blockName =~ ^[a-zA-Z]{1,2}$ ]]; then
      echo -e "\nInvalid input. Block Name must be ONE or TWO alphabets!\n"
    else
      break
    fi
  done

  echo # Blank Line, \n
  print_centered "-" "-"
  # Force match the line starts with the given blockName
  SearchInFile "venue.txt" "^$blockName"

  if [ -z "$result" ]; then
    echo "No Record Found!"
  else
    echo -e "Room Number\tRoom Type\t\tCapacity\tRemarks\t\t\t\tStatus"
    print_centered "-" "-"
    readarray -t venueArray <<<"$result"

    # Check if the venue is booked, if yes then show UNAVAILABLE
    IFS=";"
    for line in "${venueArray[@]}"; do
      read -ra subStrings <<<"$line"

      for index in "${!subStrings[@]}"; do
        if [ "$index" = 0 ]; then # Don't display Block Name
          continue
        fi
        echo -ne "${subStrings[index]}\t\t"
      done

      if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        SearchInFile "booking.txt" "^[^;]*;[^;]*;${subStrings[1]};$(date -v+1d '+%m/%d/%Y')"

        if [ -z "$result" ]; then
          roomStatus="Available"
        else
          roomStatus="Unavailable"
        fi
      elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # GNU/Linux
        SearchInFile "booking.txt" "^[^;]*;[^;]*;${subStrings[1]};$(date -d "tomorrow" '+%m/%d/%Y')"

        if [ -z "$result" ]; then
          roomStatus="Available"
        else
          roomStatus="Unavailable"
        fi
      fi

      echo $roomStatus
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
  local roomStatus
  local bookingDate
  local bookingTimeFrom
  local bookingTimeTo
  local bookingPurpose
  local calcStartMinutes
  local calcEndMinutes
  ChkFileExist "venue.txt"
  ChkFileExist "booking.txt"

  ProgramHeader "Booking Venue"

  echo # Blank Line, \n
  # Validate room number
  while true; do
    read -rp $'Please Enter Room Number: ' roomNumber

    if [[ -z $roomNumber ]]; then
      echo -e "\nInvalid input. Room Number cannot be empty!\n"
    elif [[ ! $roomNumber =~ ^[[:alpha:]]{1,2}[[:alnum:]]{3,4}$ ]]; then
      echo -e "\nInvalid input. Please enter the room number in the correct FORMAT."
      echo "Block Name [1 OR 2 Alphabets] + Room Number [3 OR 4 Alphanumeric Characters]"
      echo -e "i.e B100A\n"
    else
      break
    fi
  done

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

    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      SearchInFile "booking.txt" "^[^;]*;[^;]*;$roomNumber;$(date -v+1d '+%m/%d/%Y')"

      if [ -z "$result" ]; then
        roomStatus="Available"
      else
        roomStatus="Unavailable"
      fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # GNU/Linux
      SearchInFile "booking.txt" "^[^;]*;[^;]*;$roomNumber;$(date -d "tomorrow" '+%m/%d/%Y')"

      if [ -z "$result" ]; then
        roomStatus="Available"
      else
        roomStatus="Unavailable"
      fi
    fi

    echo -e "Status\t\t[Auto Display]: $roomStatus"

    if [[ $roomStatus == "Unavailable" ]]; then
      echo # Blank Line, \n
      print_centered "-" "-"
      echo "Unfortunately, the venue [$roomNumber] has been booked for tomorrow."
      echo "Please select another venue."
      UserSelection "Retry Booking" BookVenue
    else
      echo # Blank Line, \n
      print_centered "-" "-"
      echo -e "Notes:\tThe booking hours shall be from 0800hrs (8.00am) to 2000hrs (8.00pm) only."
      echo -e "\tThe booking duration shall be at least 30 minutes per booking."

      echo # Blank Line, \n
      print_centered "-" "-"
      print_centered "Please Enter Booking Details According to the Format Below"
      echo # Blank Line, \n

      # Validate Data, ensure the date is in the correct format & is tomorrow
      while true; do
        read -rp $'Booking Date\t\t[MM/DD/YYYY]\t: ' bookingDate

        if [[ -z $bookingDate ]]; then
          echo -e "\nInvalid input. Booking Date cannot be EMPTY!\n"
        elif [[ ! $bookingDate =~ ^[0-1][0-9]/[0-3][0-9]/[0-9]{4}$ ]]; then
          echo -e "\nInvalid input. Please enter the Booking Date in the correct FORMAT."
          echo -e "[FORMAT]: MM/DD/YYYY, i.e 06/29/2023\n"
        # Instead of using [date -d] which works for GNU/Linux Systems,
        # Consider using [date -j] (BSD) which works for macOS and Linux Systems.
        else
          if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if [[ "$(date -j -f '%m/%d/%Y' "$bookingDate" '+%m/%d/%Y')" < "$(date -v+1d '+%m/%d/%Y')" ]]; then
              echo -e "\nInvalid input. Booking Date can only be TOMORROW!\n"
            else
              break
            fi
          elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # GNU/Linux
            if [[ "$(date -d "$bookingDate" '+%m/%d/%Y')" < "$(date -d "tomorrow" '+%m/%d/%Y')" ]]; then
              echo -e "\nInvalid input. Booking Date can only be TOMORROW!\n"
            else
              break
            fi
          fi
        fi
      done

      # Validate Data, ensure the time is in the correct format & is within the range
      while true; do
        read -rp $'Booking From\t\t[HH:MM]\t\t: ' bookingTimeFrom

        if [[ -z $bookingTimeFrom ]]; then
          echo -e "\nInvalid input. Booking Time From cannot be EMPTY!\n"
        elif [[ ! $bookingTimeFrom =~ ^[0-9]{2}:[0-5][0-9]$ ]]; then
          echo -e "\nInvalid input. Please enter the Booking Time From in the correct FORMAT."
          echo -e "[FORMAT]: HH:MM, i.e 14:00\n"
        elif [[ $bookingTimeFrom < "08:00" || $bookingTimeFrom > "19:30" ]]; then
          echo -e "\nInvalid input. Booking Time From can only in between 0800hrs (8.00am) to 1930hrs (7.30pm)!\n"
        else
          calcStartMinutes=$((10#$(tr -d ':' <<<"$bookingTimeFrom")))
          break
        fi
      done

      while true; do
        read -rp $'Booking Until\t\t[HH:MM]\t\t: ' bookingTimeTo

        if [[ -z $bookingTimeTo ]]; then
          echo -e "\nInvalid input. Booking Time From cannot be EMPTY!\n"
        elif [[ ! $bookingTimeTo =~ ^[0-9]{2}:[0-5][0-9]$ ]]; then
          echo -e "\nInvalid input. Please enter the Booking Time From in the correct FORMAT."
          echo -e "[FORMAT]: HH:MM, i.e 15:30\n"
        elif [[ $bookingTimeTo < "08:30" || $bookingTimeTo > "20:00" ]]; then
          echo -e "\nInvalid input. Booking Time Until can only in between 0830hrs (8.30am) to 2000hrs (8.00pm)!\n"
        elif [[ $bookingTimeTo < $bookingTimeFrom ]]; then
          echo -e "\nInvalid input. Booking Time Until cannot be earlier than Booking Time From!\n"
        else
          calcEndMinutes=$((10#$(tr -d ':' <<<"$bookingTimeTo")))
          if [[ $((calcEndMinutes - calcStartMinutes)) -lt 30 ]]; then
            echo -e "\nInvalid input. A booking must be at least 30 minutes!\n"
          else
            break
          fi
        fi
      done

      read -rp $'Booking Purpose\t\t\t\t: ' bookingPurpose

      UserSelection "Save & Generate the Booking Slip" "GenerateBookingSlip" "$roomNumber" "$bookingDate" "$bookingTimeFrom" "$bookingTimeTo" "$bookingPurpose"
    fi
  fi
}

GenerateBookingSlip() {
  local currentDateTime
  local combinedString
  local generatedReceiptFile

  currentDateTime=$(date "+%d/%m/%Y %H:%M:%S")
  combinedString="${patronDetailsBooking[0]};${patronDetailsBooking[1]};$1;$2;$3;$4;$5"
  generatedReceiptFile="$receiptsPath/${patronDetailsBooking[0]}_${1}_$(date "+%m-%d-%Y %H%M%S").txt"
  AppendToFile "booking.txt" "$combinedString"

  cat >>"$generatedReceiptFile" <<EOF

                            Venue Booking Slip

Patron ID: ${patronDetailsBooking[0]}                                Patron Name: ${patronDetailsBooking[1]}

Room Number: $1

Booking Date: $2

Booking From: $3                                  Booking Until: $4

Booking Purpose: $5

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
