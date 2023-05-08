#!/bin/bash

# Define options
options=("React w/Chakra UI, NodeJS, Express, Knex, and Postgres" "React with Chakra UI" "NodeJS API, with Express, Knex, and Postgres" "Electron app with Chakra UI")

# Initialize selected option
selected_option=0

# Set ANSI color codes
normal="\033[0m"
green="\033[0;32m"

# Clear screen and hide cursor
tput clear
tput civis

# Display options and prompt user for selection
while true; do
  # Move cursor to top of screen
  tput cup 0 0

  # Output options
  for i in "${!options[@]}"; do
    if ((i == selected_option)); then
      printf " ${green}> ${options[i]}${normal}\n"
    else
      printf "   %s\n" "${options[i]}"
    fi
  done

  # Read user input
  read -rsn1 input
  if [[ $input == "" ]]; then
    break
  elif [[ $input == $'\x1b' ]]; then
    read -rsn2 -t 1 input
    if [[ $input == "[A" && $selected_option -gt 0 ]]; then
      ((selected_option--))
    elif [[ $input == "[B" && $selected_option -lt $(( ${#options[@]} - 1 )) ]]; then
      ((selected_option++))
    fi
  fi
done

# Clear screen and show cursor
tput clear
tput cnorm

# Execute selected option
case $selected_option in
  0)
    # Express Server with Knex and Postgres
    echo "Creating your stack of choice..."
    read -p "Enter project name: " project_name
    source mullets-stack-full.sh "$project_name"
    ;;
  1)
    # React with Chakra UI
    echo "Creating React with Chakra UI..."
    # Insert command for creating a React app with Chakra UI here
    ;;
  2)
    # NodeJS API
    echo "Creating Node Server..."
    # Insert command for creating an nodejs app here
    ;;
  3)
    # Electron app with Chakra UI
    echo "Creating Electron app with Chakra UI..."
    read -p "Enter project name: " project_name
    source mullets-stack-electron.sh "$project_name"
    # Insert command for creating an Electron app with Chakra UI here
    ;;
  *)
    # Invalid option
    echo "Invalid option."
    ;;
esac
