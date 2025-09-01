#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

installCorretto() {
  wget -qO - https://apt.corretto.aws/corretto.key \
    | sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" \
    | sudo tee /etc/apt/sources.list.d/corretto.list > /dev/null && \
  sudo apt-get -y update && \
  sudo apt-get -y install java-11-amazon-corretto-jdk
}

createServiceAccount() {
  local user="$1" group="$2"
  if ! getent group "$group" > /dev/null; then
    sudo groupadd -r "$group"
  fi

  if ! id "$user" >/dev/null 2>&1; then
    sudo useradd -M --system -g "$group" "$user"
  fi
}

downloadFile() {
  local url="$1" file="$2" folder="$3"
  if [ ! -e "${folder}/${file}" ]; then
    wget -q --show-progress -P "$folder" "$url/$file"
  fi
}

gpgVerify() {
  local folder="$1" file="$2" checksum_file="$3" algo="$4"
  cd $folder
  if gpg --print-md "$algo" "$file" | diff -q - "$checksum_file" > /dev/null; then
    echo "Checksum matches."
  else
    echo "Checksum mismatch."
    exit 1
  fi
}

createRandomPassword() {
  local pw_len="$1"
  LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c "${pw_len}"
  echo
}

checkFileExists() {
  local file="$1" error_msg="$2"
  if [[ ! -f "$file" ]]; then
    echo "$error_msg" >&2
    exit 1
  fi
}

appendToFile() {
  local file="$1" content="$2"
  echo "$content" | sudo tee -a "$file" > /dev/null
}

getDiskName() {
  local index="$1"
  local dev_prefix="/dev/sd"
  printf "%s%s" "$dev_prefix" $(printf "\\$(printf '%03o' $((98 + $index)))")
}

startService() {
  local service="$1"
  sudo systemctl enable $service
  sudo systemctl start $service
}

# add path for all users
updateProfilePath() {
  local folder="$1" script="$2"
  local profile="/etc/profile.d"

  echo "export PATH=\"\$PATH:${folder}\"" | sudo tee "${profile}/${script}" > /dev/null
  sudo chmod 644 "${profile}/${script}"
}