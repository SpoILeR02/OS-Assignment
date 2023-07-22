#!/bin/bash

### GLOBAL VARIABLES ###
declare -r directoryPath="$PWD/data_files"

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
  if [ ! -f "$directoryPath/$1" ]; then
    touch "$directoryPath/$1"
  fi
}

AppendToFile() {
  cat >>"$directoryPath/$1" <<EOF
$2
EOF
}

SearchLineInFile() {
  result=$(grep "$2" "$directoryPath/$1") #| cut -d: -f1
}

PromptInput() {
  read -rp "Please Enter Your Option: " userOption

  if [ "$1" != "others" ]; then
    local validInputs=("A" "B" "C" "D" "E" "Q")
    # Convert to Uppercase using ^^, if require Lowercase use ,,
    while [[ ! "${validInputs[*]}" =~ (^| )"${userOption^^}"($| ) ]]; do
      echo -e "\nInvalid Option. Enter Only [A], [B], [C], [D], [E] OR [Q]!"
      echo -e "Please Try Again!\n"
      read -rp "Please Enter Your Option: " userOption
    done

  else
    # Convert to Uppercase using ^^, if require Lowercase use ,,
    while [ "${userOption^^}" != "Y" ] && [ "${userOption^^}" != "N" ]; do
      echo -e "\nInvalid Option. Enter Only [Y] or [N]!"
      echo -e "Please Try Again!\n"
      read -rp "Please Enter Your Option: " userOption
    done
  fi
}

ProgramHeader() {
  print_centered "=" "="
  print_centered "University Venue Management Menu"
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

  echo
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
  echo

  # TODO: Add Validation for PATRON INPUT
  read -rp $'Patron ID [As per TAR UMT Format]\t: ' patronID
  read -rp $'Patron Full Name [As per NRIC]\t\t: ' patronName
  read -rp $'Contact Number\t\t\t\t: ' patronContact
  read -rp $'Email Address [As per TAR UMT Format]\t: ' patronEmail

  combinedString="$patronID;$patronName;$patronContact;$patronEmail"
  AppendToFile "patron.txt" "$combinedString"

  UserSelection "Register For Another Patron" RegisterPatron
}

# TODO: [B] Search Patron Details
SearchPatron() {
  local patronID
  local subStrings
  ChkFileExist "patron.txt"

  ProgramHeader "Search Patron Details"

  echo
  read -rp $'Please Enter Patron ID [As per TAR UMT Format]: ' patronID
  echo

  SearchLineInFile "patron.txt" "$patronID"

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

  # TODO: Add Validation for PATRON INPUT
  read -rp $'Block Name\t: ' blockName
  read -rp $'Room Number\t: ' roomNumber
  read -rp $'Room Type\t: ' roomType
  read -rp $'Room Capacity\t: ' roomCapacity
  read -rp $'Room Remarks\t: ' roomRemarks
  echo -e "Room Status\t: Available (Default)"

  combinedString="$blockName;$roomNumber;$roomType;$roomCapacity;$roomRemarks"
  AppendToFile "venue.txt" "$combinedString"

  UserSelection "Add Another New Venue" AddVenue
}

# TODO: [D] List Venue Details

# TODO: [] Book Venue
BookVenue() {
  local patronID
  local roomNumber

  ChkFileExist "patron.txt"
  ChkFileExist "venue.txt"
  ChkFileExist "booking.txt"

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
    echo "List Venue"
    ;;

  [E])
    clear
    BookVenue
    ;;

  [Q])
    clear
    ExitProgram
    ;;

  esac
}

StartProgram() {
  clear
  DEFAULT_IFS=$IFS

  if [ ! -d "$directoryPath" ]; then
    mkdir "$directoryPath"
    MainMenu
  else
    MainMenu
  fi
}

StartProgram
##################################
