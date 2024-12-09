#!/bin/bash
'''
Just a list of things i usually run when starting a new machine. 
    ____ ___  ________  ___   _______  __
  / ___//   |/_  __/ / / / | / /  _/ |/ /
  \__ \/ /| | / / / / / /  |/ // / |   / 
 ___/ / ___ |/ / / /_/ / /|  // / /   |  
/____/_/ _|_/_/  \____/_/ |_/___//_/|_|  
| |     / /   | / ___/                   
| | /| / / /| | \__ \                    
| |/ |/ / ___ |___/ /                    
|__/|__/_/__|_/____/  ______             
   / / / / ____/ __ \/ ____/             
  / /_/ / __/ / /_/ / __/                
 / __  / /___/ _, _/ /___                
/_/ /_/_____/_/ |_/_____/                
                               
'''


header() {
  echo -e "\n\e[1;34m[+] $1\e[0m"
}

error_handler() {
  echo -e "\e[1;31m[!] I'M SORRY MS. JACKSON: ERR HERE - $1\e[0m"
}

if [ "$EUID" -ne 0 ]; then
  echo "RUN AS ROOT (USE SUDO)."
  exit 1
fi

header "CHANGE DEFAULT PASSWORD"
read -p "CHANGE DEFAULT PASSWORD? [y/N]: " CHANGE_PASS
if [[ "$CHANGE_PASS" =~ ^[Yy]$ ]]; then
  echo -e "\e[1;33mENTER A NEW PASSWORD FOR $(whoami):\e[0m"
  passwd || error_handler "FAILED TO CHANGE PASSWORD"
fi

header "ENSURING SSH SERVER IS RUNNING"
read -p "INSTALL AND START SSH SERVER? [y/N]: " SSH_INSTALL
if [[ "$SSH_INSTALL" =~ ^[Yy]$ ]]; then
  apt update && apt install -y openssh-server || error_handler "SSH INSTALL FAILED"
  systemctl enable ssh || error_handler "FAILED TO ENABLE SSH"
  systemctl start ssh || error_handler "FAILED TO START SSH"
  if systemctl is-active --quiet ssh; then
    echo "SSH SERVER IS RUNNING."
  else
    error_handler "SSH SERVER IS NOT RUNNING"
  fi
fi

header "UPDATING SYSTEM"
read -p "UPDATE AND UPGRADE SYSTEM? [y/N]: " UPDATE_SYSTEM
if [[ "$UPDATE_SYSTEM" =~ ^[Yy]$ ]]; then
  apt update && apt upgrade -y || error_handler "FAILED TO UPDATE SYSTEM"
fi

header "INSTALLING DEFAULT TOOLS"
read -p "INSTALL DEFAULT KALI TOOLS? [y/N]: " INSTALL_TOOLS
if [[ "$INSTALL_TOOLS" =~ ^[Yy]$ ]]; then
  apt install -y kali-linux-default || error_handler "FAILED TO INSTALL DEFAULT TOOLS"
fi

header "CREATING DIRECTORY STRUCTURE"
read -p "CREATE ~/Development STRUCTURE? [y/N]: " CREATE_DIRS
if [[ "$CREATE_DIRS" =~ ^[Yy]$ ]]; then
  mkdir -p ~/Development/Public ~/Development/Private || error_handler "FAILED TO CREATE DIRECTORIES"
  echo "DIRECTORIES CREATED: ~/Development/Public ~/Development/Private."
fi

header "UPDATING METASPLOIT DB"
read -p "UPDATE METASPLOIT DATABASE? [y/N]: " UPDATE_MSF
if [[ "$UPDATE_MSF" =~ ^[Yy]$ ]]; then
  msfdb init || error_handler "FAILED TO INIT METASPLOIT DB"
  msfconsole -q -x "db_rebuild_cache; exit" || error_handler "FAILED TO REBUILD METASPLOIT CACHE"
fi

header "UPDATING SEARCHSPLOIT DB"
read -p "UPDATE SEARCHSPLOIT DATABASE? [y/N]: " UPDATE_SEARCHSPLOIT
if [[ "$UPDATE_SEARCHSPLOIT" =~ ^[Yy]$ ]]; then
  searchsploit --update || error_handler "FAILED TO UPDATE SEARCHSPLOIT DB"
fi

header "CLONING SCRIPTS TO ~/Development/Public"
read -p "CLONE SCRIPTS FROM GITHUB? [y/N]: " CLONE_SCRIPTS
if [[ "$CLONE_SCRIPTS" =~ ^[Yy]$ ]]; then
  cd ~/Development/Public || error_handler "FAILED TO NAVIGATE TO ~/Development/Public"
  git clone https://github.com/carlospolop/PEASS-ng.git || error_handler "FAILED TO CLONE PEASS-ng"
  git clone https://github.com/rebootuser/LinEnum.git || error_handler "FAILED TO CLONE LinEnum"
  git clone https://github.com/mzet-/linux-exploit-suggester.git || error_handler "FAILED TO CLONE LINUX EXPLOIT SUGGESTER"
  git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git || error_handler "FAILED TO CLONE WINDOWS EXPLOIT SUGGESTER"
  git clone https://github.com/danielmiessler/SecLists.git || error_handler "FAILED TO CLONE SECLISTS"
  git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git || error_handler "FAILED TO CLONE PAYLOADSALLTHETHINGS"
  git clone https://github.com/Tib3rius/AutoRecon.git || error_handler "FAILED TO CLONE AUTORECON"
  git clone https://github.com/samratashok/nishang.git || error_handler "FAILED TO CLONE NISHANG"
fi

header "INSTALLING CRACKMAPEXEC"
read -p "INSTALL CRACKMAPEXEC? [y/N]: " INSTALL_CME
if [[ "$INSTALL_CME" =~ ^[Yy]$ ]]; then
  pip3 install crackmapexec || error_handler "FAILED TO INSTALL CRACKMAPEXEC"
fi

header "INSTALLING EVIL-WINRM"
read -p "INSTALL EVIL-WINRM? [y/N]: " INSTALL_WINRM
if [[ "$INSTALL_WINRM" =~ ^[Yy]$ ]]; then
  gem install evil-winrm || error_handler "FAILED TO INSTALL EVIL-WINRM"
fi

header "CLONING EXTRA TOOLS"
read -p "CLONE EXTRA TOOLS FROM GITHUB? [y/N]: " CLONE_EXTRA
if [[ "$CLONE_EXTRA" =~ ^[Yy]$ ]]; then
  git clone https://github.com/evait-security/kali-linux-cheatsheets.git || error_handler "FAILED TO CLONE KALI CHEATSHEETS"
  git clone https://github.com/Anon-Exploiter/SUID3NUM.git || error_handler "FAILED TO CLONE SUID3NUM"
fi

header "CLEANING SYSTEM"
read -p "PERFORM SYSTEM CLEANUP? [y/N]: " CLEANUP
if [[ "$CLEANUP" =~ ^[Yy]$ ]]; then
  apt autoremove -y && apt clean || error_handler "FAILED TO CLEAN SYSTEM"
fi

header "SETUP COMPLETE - DISPLAYING SYSTEM INFO"
neofetch
