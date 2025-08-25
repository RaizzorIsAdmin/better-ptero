#!/bin/bash

set -e

######################################################################################
#                                                                                    #
#   Welcome to Automatic Pterodactyl Installer!                                      #
#   Thank you for choosing Better-Ptero <3                                           #
#                                                                                    #
#   Copyright (C) 2024 - 2025, Made by djraizzxr, <admin@magmacloud.host>            #
#                                                                                    #
#   This program is free software: you can redistribute it and/or modify             #
#   it under the terms of the GNU General Public License as published by             #
#   the Free Software Foundation, either version 3 of the License, or                #
#   (at your option) any later version.                                              #
#                                                                                    #
# This script is not associated with the official Pterodactyl Project.               #
# https://pterodactyl.io                                                             #
#                                                                                    #
######################################################################################

export GITHUB_SOURCE="v0.12.3"
export SCRIPT_RELEASE="v0.12.3"
export GITHUB_BASE_URL="https://raw.githubusercontent.com/RaizzorIsAdmin/better-ptero/main/install.sh"

LOG_PATH="/var/log/better-ptero/pterodactyl-installer.log"

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* Sorry, but Curl is required in order for this script to work."
  echo "* Please, install it manually. Use apt update && apt install curl -y"
  exit 1
fi

execute() {
  echo -e "\n\n* better-ptero $(date) \n\n" >>$LOG_PATH

  [[ "$1" == *"canary"* ]] && export GITHUB_SOURCE="master" && export SCRIPT_RELEASE="canary"
  update_lib_source
  run_ui "${1//_canary/}" |& tee -a $LOG_PATH

  if [[ -n $2 ]]; then
    echo -e -n "* Installation of $1 successfully completed! Want to proceed to $2 installation? (y/N): "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ [Yy] ]]; then
      execute "$2"
    else
      error "Installation $2 cancelled."
      exit 1
    fi
  fi
}

welcome ""

done=false
while [ "$done" == false ]; do
  options=(
    "Install Pterodactyl Panel"
    "Install Pterodactyl Wings"
    "Install both [0] and [1] on the same machine (wings script runs after panel)"
    # "Uninstall panel or wings\n"

    "Install both [3] and [4] on the same machine (Wings script runs after panel)"
    "Uninstall panel or wings with canary version of the script"
  )

  actions=(
    "panel"
    "wings"
    "panel;wings"
    # "uninstall"

    "panel_canary"
    "wings_canary"
    "panel_canary;wings_canary"
    "uninstall_canary"
  )

  output "What would you like to do?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]} - 1)): "
  read -r action

  [ -z "$action" ] && error "Input is required!" && continue

  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option! Please, choose the correct answer!"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && IFS=";" read -r i1 i2 <<<"${actions[$action]}" && execute "$i1" "$i2"
done

# Remove lib.sh, so next time the script is run the, newest version is downloaded.
rm -rf /tmp/lib.sh
