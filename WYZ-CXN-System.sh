#!/bin/bash

# ==============
# FILE HEADER
# ==============
# AUTHOR 1: WONG YAN ZHI
# AUTHOR 2: CHONG XIN NAN
# DATE    : 22/09/2023
# COURSE  : BACS2093 OPERATING SYSTEM
# PURPOSE : UNIVERSITY VENUE MANAGEMENT SYSTEM
# ==============

### GLOBAL VARIABLES ### [-r = readonly]
declare -r dataPath="$PWD/data_files"   # Define the path to te data_files folder
declare -r receiptsPath="$PWD/receipts" # Define the path to te receipts folder
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

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : File Existence Check
# DESCRIPTION : Check if the file exists, if not then create the file
# PARAMETER   : $1 = File Name (includes file extension)
# PURPOSE     : To ensure the file exists so that may perform search & append
# ==============
ChkFileExist() {
  if [ ! -f "$dataPath/$1" ]; then # -f = file exist#
    touch "$dataPath/$1"
  fi
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : Write into the File
# DESCRIPTION : Append/ Write something (content) into a file
# PARAMETER   : $1 = File Name (includes file extension)
#               $2 = Content to be appended
# PURPOSE     : Use echo to insert a single line onto the required file
# ==============
AppendToFile() {
  echo "$2" >>"$dataPath/$1"
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : Search inside a File
# DESCRIPTION : Search something (content) from a file
# PARAMETER   : $1 = File Name (includes file extension)
#               $2 = keyword to be searched
# PURPOSE     : Use grep to find matching pattern (entire line) inside a file
# ==============
SearchInFile() {
  # result is global variable
  result=$(grep -w "$2" "$dataPath/$1" | sort) # -w = search by words, sort = sort the searched content
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : Ask for User Input
# DESCRIPTION : Prompt the user to enter input
# PARAMETER   : $1 = State of program (either running in Main Menu or Other Modules)
# PURPOSE     : Standardize the input format when ask users to enter options (navigating program)
#               Make it into function to prevent code duplication/ cluttering (reusable)
# ==============
PromptInput() {
  # -r = read raw input, -p = PROMPT without \n before attempting to read
  read -rp "Please Enter Your Option: " userOption # Stored input into global variable 'userOption'

  # if-else statement to check the state of the program
  if [ "$1" != "others" ]; then                 # if the program is running main menu
    local validInputs=("A" "B" "C" "D" "E" "Q") # local variable for validate input purpose
    # Convert to Uppercase using ^^, if require Lowercase use ,,
    # Check if the input is equal to any element in the validInputs array
    while [[ ! "${validInputs[*]}" =~ ${userOption^^} ]]; do
      # If does not fulfill requirement, then prompt user to enter again
      echo -e "\nInvalid Option. Enter Only Single Character - [A], [B], [C], [D], [E] OR [Q]!"
      echo -e "Please Try Again!\n"
      read -rp "Please Enter Your Option: " userOption
    done

  else # if the program is running other modules
    # Convert to Uppercase using ^^, if require Lowercase use ,,
    # Check if the input is equal to Y or N
    while [ "${userOption^^}" != "Y" ] && [ "${userOption^^}" != "N" ]; do
      # If does not fulfill requirement, then prompt user to enter again
      echo -e "\nInvalid Option. Enter Only Single Character - [Y] or [N]!"
      echo -e "Please Try Again!\n"
      read -rp "Please Enter Your Option: " userOption
    done
  fi
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# AUTHOR 2    : CHONG XIN NAN
# TASK        : Print the program header
# DESCRIPTION : Print the program header, centered it by using print_centered function
# PARAMETER   : $1 = Module Name
# PURPOSE     : To be called by each module, to print the header
#               Make it into function to prevent code duplication/ cluttering (reusable)
# ==============
ProgramHeader() {
  print_centered "=" "="
  print_centered "University Venue Management System"
  print_centered "=" "="
  print_centered "$1"
  print_centered "-" "-"
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# AUTHOR 2    : CHONG XIN NAN
# TASK        : Print the program footer
# DESCRIPTION : Print the program footer, centered it by using print_centered function
# PURPOSE     : To be called by each module, to print the footer
#               Make it into function to prevent code duplication/ cluttering (reusable)
# ==============
ProgramFooter() {
  print_centered "-" "-"
  print_centered "System Made by WongYanZhi & ChongXinNan | 2023 - RST3S1G1"
  print_centered "=" "="
  echo # Blank Line, \n
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# AUTHOR 2    : CHONG XIN NAN
# TASK        : Exit the Program
# DESCRIPTION : To be called if the user chose to exit the program in Main Menu
# PURPOSE     : Print some messages to the users, then exit the program
#               Write this as a function to makes things standardize
#               (Main Menu will just be in charged of calling different functions)
# ==============
ExitProgram() {
  ProgramHeader "Exit Program"

  echo # Blank Line, \n
  print_centered "Thank You for using the University Venue Management System"
  print_centered "Hope to see you soon!"
  echo # Blank Line, \n

  ProgramFooter

  exit 0 # Yay Exit the Program!
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : User Selection [Y] or [N]
# DESCRIPTION : Print necessary information before calling PromptInput function
# PARAMETER   : $1 = Module Name
#               $2 = Function Name
# PURPOSE     : To be called by all modules other than Main Menu
#               This is used to check if user want to continue the same module or back to Main Menu
#               Make it into function to prevent code duplication/ cluttering (reusable)
UserSelection() {
  echo # Blank Line, \n
  print_centered "-" "-"
  echo "[Y] $1"
  echo "[N] Return to Main Menu"

  ProgramFooter

  # Call PromptInput function, pass in "others" as string parameter
  PromptInput "others"
  # if-else statement to check if users want to continue the same module
  if [ "${userOption^^}" == "Y" ]; then # if user chose Y = want continue
    clear                               # Clear the screen
    $2 "${@:3}"                         # Call the function, pass in the rest of the parameters if exists
  else                                  # if user chose N = want back to Main Menu
    clear                               # Clear the screen
    MainMenu                            # Call MainMenu function
  fi
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : CHONG XIN NAN
# TASK        : Register Patron
# DESCRIPTION : Used to register a new patron into the system
# PURPOSE     : This entire function is all about registering a new patron
#               It contains code segment which validate the user inputs as well
RegisterPatron() {
  # local variables for storing user inputs
  local patronID
  local patronName
  local patronContact
  local patronEmail
  ChkFileExist "patron.txt" # Call the function to check if "patron.txt" is exist

  ProgramHeader "Patron Registration"

  print_centered "Please Enter Patron's Detail According to the Format Below"
  echo # Blank Line, \n

  # Ensure user input match the format/ pattern
  while true; do                                               # Loop until the user input is valid
    read -rp $'Patron ID [As per TAR UMT Format]\t: ' patronID # read user input and store into patronID variable
    SearchInFile "patron.txt" "^$patronID"                     # Search the entered patronID

    # -e of echo is to enable interpretation of backslash escapes
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

  # local variable to store the combined string
  local combinedString
  combinedString="$patronID;$patronName;$patronContact;$patronEmail" # each substring is separated by a semicolon
  AppendToFile "patron.txt" "$combinedString"                        # Call the function to append the combined string into "patron.txt"

  UserSelection "Register For New Patron" RegisterPatron
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# AUTHOR 2    : CHONG XIN NAN
# TASK        : Identify Patron
# DESCRIPTION : To be called by SearchPatron & PatronValidation
# PARAMETER   : $1 = Module Name
# PURPOSE     : Prompt the user to enter Patron ID, then search if the Patron ID exist in the database
#               It contains code segment which validate the user inputs as well
#               Make it into function to prevent code duplication/ cluttering (reusable)
IdentifyPatron() {
  # local variable for storing user input
  # Ensure user input match the format/ pattern
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

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : CHONG XIN NAN
# TASK        : Search Patron
# DESCRIPTION : To call IdentifyPatron function, then display the patron details if found
# PURPOSE     : Display the petron details if found, else display "No Record Found!"
SearchPatron() {
  # local variable used to store substring of the found line
  local subStrings
  IdentifyPatron "Search Patron Details"

  if [ -z "$result" ]; then
    echo "No Record Found!"
  else
    IFS=";"                          # Internal Field Separator, the system skips the specified delimiter when reading the string
    read -ra subStrings <<<"$result" # Read as raw input, and store into an array
    IFS=$DEFAULT_IFS                 # Default is Space, Tab & New Line

    echo -e "Full Name\t[Auto Display]: ${subStrings[1]}"
    echo -e "Contact Number\t[Auto Display]: ${subStrings[2]}"
    echo -e "Email Address\t[Auto Display]: ${subStrings[3]}"
  fi

  UserSelection "Search For Another Patron" SearchPatron
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : Add New Venue
# DESCRIPTION : To create a new venue into the system
# PURPOSE     : This entire function is about adding a new venue
#               It contains code segment which validate the user inputs as well
AddVenue() {
  # local variables for storing user inputs
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
    # Since the room number is stored as 2nd column in txt file, therefore we modify the search pattern as follows
    # ^ = start of line, [^;] = any character except semicolon, * = more occurrence, ; = semicolon
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

  # Room remarks is just a side note, therefore no validation needed
  read -rp $'Room Remarks\t: ' roomRemarks
  # Room status for a newly created venue shall be Available
  echo -e "Room Status\t: Available (Default)"

  local combinedString
  combinedString="$blockName;$roomNumber;$roomType;$roomCapacity;$roomRemarks"
  AppendToFile "venue.txt" "$combinedString"

  UserSelection "Add Another New Venue" AddVenue
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : List Venue
# DESCRIPTION : Used to list down all the venue details and info which belongs to a specific block
# PARAMETER   : $1 = Module Name
# PURPOSE     : Prompt the user to enter block name, then search in venue txt file to show all the venues
#               It contains code segment which validate the user inputs as well
ListVenue() {
  # local variables for storing user inputs
  local blockName
  local venueArray
  local roomStatus
  local subStrings
  # Listing venue will be using data in 2 different files
  # Therefore, both venue and booking txt files shall be checked if exist
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
    # All venue with identical Block Name is stored in Results
    echo -e "Room Number\tRoom Type\t\tCapacity\tRemarks\t\t\t\tStatus"
    print_centered "-" "-"
    readarray -t venueArray <<<"$result"

    # Check if the venue is booked, if yes then show UNAVAILABLE
    IFS=";"
    # Loop through the array (which would contain multiple lines)
    for line in "${venueArray[@]}"; do
      # Store the contents of a single line into an array
      read -ra subStrings <<<"$line"
      # Loop through the array (which contains multiple substrings)
      for index in "${!subStrings[@]}"; do
        if [ "$index" = 0 ]; then # Don't display Block Name
          continue
        fi
        echo -ne "${subStrings[index]}\t\t" # -n = print without \n, -e = enable interpretation of backslash escapes
      done

      # Check if the venue is booked, if yes then show UNAVAILABLE
      # OS depentent, macOS = darwin and linux = linux-gnu
      # The reason to do so is because both system uses different 'date' system
      if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        # Since the room number is stored as 3rd column in txt file, therefore we modify the search pattern as follows
        # ^ = start of line, [^;] = any character except semicolon, * = more occurrence, ; = semicolon
        # We know that the subString[1] contains room number, therefore we utilize it to search
        # If the room number fits into the search pattern, it then verify if the booking date is tommorow
        # If it is, that would mean the booking has already been done, and the room is now unavailable
        # Store appropriate room status then display it
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

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : Patron Validation
# DESCRIPTION : To verify is the user is a valid patron before allows booking
# PURPOSE     : Display the name if found and allow proceed to next section (booking),
#               else display "Patron ID is not found"
PatronValidation() {
  # 'patronDetailsBooking' is global variable
  # 'subStrings' is local variable
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

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : Extract Booking Time
# DESCRIPTION : The system shall extract the booking time from the search result found from booking.txt
# PURPOSE     : Store the booking time into 2 different arrays, one for Booking From and another for Booking Until
#               Each element was sparated by a semicolon (;)
ExtractBookingTime() {
  chkBookingTimeFromArray=()
  chkBookingTimeUntilArray=()

  while read -r line; do
    # Use awk to extract Booking From (field 5) and Booking Until (field 6) based on the delimiter ';'
    chkBookingTimeFrom=$(awk -F';' '{print $5}' <<<"$line")
    chkBookingTimeUntil=$(awk -F';' '{print $6}' <<<"$line")

    # Add Booking From and Booking Until to their respective arrays
    chkBookingTimeFromArray+=("$chkBookingTimeFrom")
    chkBookingTimeUntilArray+=("$chkBookingTimeUntil")
  done <<<"$result"
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : Check Available For Booking (Ensure no conflict with other booking time)
# DESCRIPTION : The system shall check if the venue is available for booking
# PURPOSE     : Check user input time, then compare with the existing booking time
#               If the user input time is within the existing booking time, then it is invalid
CheckAvailableForBooking() {
  for element in "${!chkBookingTimeFromArray[@]}"; do
    if [[ "$OSTYPE" == "darwin"* ]]; then
      if [ "$2" == true ]; then
        if [[ ! $1 < $(date -j -v-30M -f "%H:%M" "${chkBookingTimeFromArray[element]}" +%H:%M) && $1 < "${chkBookingTimeUntilArray[element]}" ]]; then
          invalidBookingFlags=true
          break
        else
          invalidBookingFlags=false
        fi
      else
        if [[ ! $1 < "${chkBookingTimeFromArray[element]}" && $1 < "${chkBookingTimeUntilArray[element]}" ]]; then
          invalidBookingFlags=true
          break
        else
          invalidBookingFlags=false
        fi
      fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      if [ "$2" == true ]; then
        if [[ ! $1 < $(date -d "${chkBookingTimeFromArray[element]} 30 minutes ago" +%H:%M) && $1 < "${chkBookingTimeUntilArray[element]}" ]]; then
          invalidBookingFlags=true
          break
        else
          invalidBookingFlags=false
        fi
      else
        if [[ ! $1 < "${chkBookingTimeFromArray[element]}" && $1 < "${chkBookingTimeUntilArray[element]}" ]]; then
          invalidBookingFlags=true
          break
        else
          invalidBookingFlags=false
        fi
      fi
    fi
  done
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : Book Venue
# DESCRIPTION : Allow user to book a venue after passes patron validation
# PURPOSE     : This entire function is all about booking a venue
#               It contains code segment which validate the user inputs as well
BookVenue() {
  # local variables for storing user inputs & calculation purpose
  local roomNumber
  local roomStatus
  local bookingDate
  local bookingTimeFrom
  local bookingTimeTo
  local bookingPurpose
  local calcStartMinutes
  local calcEndMinutes
  # Booking venue will be using data in 2 different files
  # Therefore, both venue and booking txt files shall be checked if exist
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

  # Seach for the specific venue
  SearchInFile "venue.txt" "^[^;]*;$roomNumber"

  if [ -z "$result" ]; then
    echo "Invalid Room Number! Room Number is not found!"
    UserSelection "Retry Booking" BookVenue
  else
    IFS=";"
    read -ra subStrings <<<"$result"
    IFS=$DEFAULT_IFS

    # Display the venue details
    echo -e "Room Type\t[Auto Display]: ${subStrings[2]}"
    echo -e "Capacity\t[Auto Display]: ${subStrings[3]}"
    echo -e "Remarks\t\t[Auto Display]: ${subStrings[4]}"

    # Check if the venue is booked, if yes then show UNAVAILABLE
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      SearchInFile "booking.txt" "^[^;]*;[^;]*;$roomNumber;$(date -v+1d '+%m/%d/%Y')"

      if [ -z "$result" ]; then
        roomStatus="Available"
      else
        roomStatus="Unavailable From"
        ExtractBookingTime
      fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # GNU/Linux
      SearchInFile "booking.txt" "^[^;]*;[^;]*;$roomNumber;$(date -d "tomorrow" '+%m/%d/%Y')"

      if [ -z "$result" ]; then
        roomStatus="Available"
      else
        roomStatus="Unavailable From"
        ExtractBookingTime
      fi
    fi

    echo -e "Status\t\t[Auto Display]: $roomStatus"
    for index in "${!chkBookingTimeFromArray[@]}"; do
      echo -ne "\t\t\t\t${chkBookingTimeFromArray[index]}" # -n = print without \n, -e = enable interpretation of backslash escapes
      echo " - ${chkBookingTimeUntilArray[index]}"
    done

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
      else
        # [date -d] works for GNU/Linux Systems,
        # [date -j] (BSD) works for macOS (darwin).
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
      CheckAvailableForBooking "$bookingTimeFrom" true

      if [[ -z $bookingTimeFrom ]]; then
        echo -e "\nInvalid input. Booking Time From cannot be EMPTY!\n"
      elif [[ ! $bookingTimeFrom =~ ^[0-9]{2}:[0-5][0-9]$ ]]; then
        echo -e "\nInvalid input. Please enter the Booking Time From in the correct FORMAT."
        echo -e "[FORMAT]: HH:MM, i.e 14:00\n"
      elif [[ $invalidBookingFlags = true ]]; then
        echo -e "\nInvalid input. The booking time entered is either already booked, or conflict with other booking time!"
        echo -e "It is possible that the selected booking time added up 30 minutes (minimum booking period),"
        echo -e "will clash with other booking time."
        echo -e "Please recheck the timeslot, and select another available time.\n"
      elif [[ $bookingTimeFrom < "08:00" || $bookingTimeFrom > "19:30" ]]; then
        # The reason to put 730pm is to reserve a 30 minutes of booking time
        echo -e "\nInvalid input. Booking Time From can only in between 0800hrs (8.00am) to 1930hrs (7.30pm)!\n"
      else
        # tr -d ':' = delete all the colons in the string
        # $() that covers the tr command = execute in sub shell
        # 10# = prefixes with 10# (base-10), it specify the string should be intepreted as base-10 (decimal) number
        #       Ensure the number is treated as decimal even it gas leading zero
        # $(()) = treat as arithmetic expression
        calcStartMinutes=$((10#$(tr -d ':' <<<"$bookingTimeFrom")))
        break
      fi
    done

    while true; do
      read -rp $'Booking Until\t\t[HH:MM]\t\t: ' bookingTimeTo
      CheckAvailableForBooking "$bookingTimeTo" false

      if [[ -z $bookingTimeTo ]]; then
        echo -e "\nInvalid input. Booking Time From cannot be EMPTY!\n"
      elif [[ ! $bookingTimeTo =~ ^[0-9]{2}:[0-5][0-9]$ ]]; then
        echo -e "\nInvalid input. Please enter the Booking Time From in the correct FORMAT."
        echo -e "[FORMAT]: HH:MM, i.e 15:30\n"
      elif [[ $invalidBookingFlags = true ]]; then
        echo -e "\nInvalid input. The booking time entered is either already booked, or conflict with other booking time!"
        echo -e "Please recheck the timeslot, and select another time.\n"
      elif [[ $bookingTimeTo < "08:30" || $bookingTimeTo > "20:00" ]]; then
        echo -e "\nInvalid input. Booking Time Until can only in between 0830hrs (8.30am) to 2000hrs (8.00pm)!\n"
      elif [[ $bookingTimeTo < $bookingTimeFrom ]]; then
        echo -e "\nInvalid input. Booking Time Until cannot be earlier than Booking Time From!\n"
      else
        # tr -d ':' = delete all the colons in the string
        # $() that covers the tr command = execute in sub shell
        # 10# = prefixes with 10# (base-10), it specify the string should be intepreted as base-10 (decimal) number
        #       Ensure the number is treated as decimal even it gas leading zero
        # $(()) = treat as arithmetic expression
        calcEndMinutes=$((10#$(tr -d ':' <<<"$bookingTimeTo")))
        # Check if the booking duration is at least 30 minutes
        if [[ $((calcEndMinutes - calcStartMinutes)) -lt 30 ]]; then
          echo -e "\nInvalid input. A booking must be at least 30 minutes!\n"
        else
          break
        fi
      fi
    done
    # Booking purpose is just a side note, therefore no validation needed
    read -rp $'Booking Purpose\t\t\t\t: ' bookingPurpose

    UserSelection "Save & Generate the Booking Slip" "GenerateBookingSlip" "$roomNumber" "$bookingDate" "$bookingTimeFrom" "$bookingTimeTo" "$bookingPurpose"
  fi
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# TASK        : Generate Booking Slip (Receipt)
# DESCRIPTION : Generate the booking slip once the user decided to save the booking
# PARAMETER   : Explained in-line
# PURPOSE     : To generate a booking slip and store it in local storage
#               To print out the booking slip on screen to the user
GenerateBookingSlip() {
  # local variables
  local currentDateTime
  local combinedString
  local generatedReceiptFile

  # 'currentDateTime' store the current date and time, in the format of DD/MM/YYYY HH:MM:SS
  currentDateTime=$(date "+%d/%m/%Y %H:%M:%S")
  # 'combinedString' store the combined string, which later will be appended into booking.txt
  # patronDetailsBooking[0] = Patron ID, patronDetailsBooking[1] = Patron Name
  # $1 = Room Number, $2 = Booking Date, $3 = Booking From, $4 = Booking Until, $5 = Booking Purpose
  combinedString="${patronDetailsBooking[0]};${patronDetailsBooking[1]};$1;$2;$3;$4;$5"
  # 'generatedReceiptFile' store the path of the generated receipt file
  # The file name is in the format of PatronID_RoomNumber_currentDay currenTime.txt
  # Example[1]: 8121_B001A_07-28-2023 133934
  # Example[2]: 23WMR08121_B001A_07-28-2023 133934
  # 133934 = 13:39:34, 24 hours format (HHMMSS)
  generatedReceiptFile="$receiptsPath/${patronDetailsBooking[0]}_${1}_$(date "+%m-%d-%Y %H%M%S").txt"
  # Call the function to append the combined string into booking.txt
  AppendToFile "booking.txt" "$combinedString"
  # Use cat to write multiple lines into the txt file
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
  cat "$generatedReceiptFile" # Use cat to print out the content of the txt file

  UserSelection "Register For Another Booking" MainMenu
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# AUTHOR 2    : CHONG XIN NAN
# TASK        : Main Menu
# DESCRIPTION : Main Menu of the program
# PURPOSE     : Used to display the main menu of the program
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

  PromptInput "main" # Call PromptInput function, pass in "main" as string parameter
  # Convert to Uppercase using ^^, if require Lowercase use ,,
  case "${userOption^^}" in # Check the value of userOption variable using switch-case
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
    ;;

  esac
}

# ==============
# TASK HEADER
# ==============
# AUTHOR 1    : WONG YAN ZHI
# AUTHOR 2    : CHONG XIN NAN
# TASK        : Start Program
# DESCRIPTION : The first code segment to be run when the program is executed
# PURPOSE     : To setup the folder structure, then call MainMenu function
StartProgram() {
  # DEFAULT_IFS is global variable
  clear        # clear is used to flush up the terminal screen
  tput setab 7 # Set background color to white
  tput setaf 0 # Set font color to black

  DEFAULT_IFS=$IFS # The default IFS is Space, Tab & New Line

  if [ ! -d "$dataPath" ]; then # Check if the data folder is exist
    # if it is not, then create these folder
    mkdir "$dataPath"
    mkdir "$receiptsPath"
    MainMenu
  else
    # Otherwise, run Main Menu directly
    MainMenu
  fi
}

StartProgram
##################################
