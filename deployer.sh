#!/bin/bash

version='1.1.0' # Software version
versionDate='2025-05-16 18:10' # Software version date

defaultDeployerScript=deployer.sh

# Reset
Color_Off='\033[0m' # Text Reset

# Regular Colors
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Blue='\033[0;34m'   # Blue
White='\033[0;37m'  # White

deployerPath=${PWD}'/'
config=

############################################################
# Help                                                     #
############################################################
Help() {
  # Display Help
  echo -e "${Green}____________________${Color_Off}"
  echo -e "${Green}FastDeployer ${Color_Off} version ${Yellow}${version}${Color_Off} ${versionDate}"
  echo
  echo -e "${Yellow}Usage:${Color_Off}"
  echo "  [command config] | [options]"
  echo
  echo -e "  ${Yellow}command:${Color_Off}"
  echo -e "    ${Green}deploy${Color_Off}  Deploy."
  # echo -e "  ${Green}upgrade${Color_Off} Upgrade."
  echo
  echo -e "  ${Yellow}config:${Color_Off}"
  echo -e "    ${Green}[path]${Color_Off} Path to configuration file (see "deployer.conf.example")."
  echo
  echo -e "  ${Yellow}options:${Color_Off}"
  echo -e "    ${Green}-h, --help${Color_Off}      Print this Help."
  # echo -e "    ${Green}-v, --verbose${Color_Off}   Verbose mode."
  echo -e "    ${Green}-V, --version${Color_Off}   Display this application version and exit."
  echo
}

############################################################
# Init                                                     #
############################################################
function Init() {
  echo
  echo -e "Deployer directory: ${Blue}$deployerPath${Color_Off}"
}

############################################################
# GetConfigParam                                           #
############################################################
function GetConfigParam() {
  name=$1

  if [ -r "${config}" ]; then
    while IFS="=" read -r key value ; do
      if [ "$key" != '' ]; then
        if [ "${key:0:1}" != "#" ]; then
          if [ "${key}" == $name ]; then
            echo $value
          fi
        fi
      fi
    done < "$config"

    echo ''
  else
    echo ''
  fi
}

############################################################
# Env                                                      #
############################################################
function Env() {
  # Set environments
  local env=$(GetConfigParam env)
  echo -e Set environments from ${Green}$env${Color_Off}
  source $env
}

############################################################
# Run                                                   #
############################################################
function Run() {
  Init
  Env
  Modules
}

############################################################
# RunCommand                                                   #
############################################################
function RunCommand() {
  echo "Current directory ${PWD}"
  case "$command" in
    deploy)
      # deploy
      if [ -r "${defaultDeployerScript}" ]; then
        bash ${defaultDeployerScript}
      else
        echo -e "${Red}"File ${defaultDeployerScript} not found in folder ${PWD}"${Color_Off}"
        exit 2;
      fi
      if [ -r "${defaultUpgradeScript}" ]; then
        bash ${defaultUpgradeScript}
      fi
      ;;
    *)
    break
    ;;
  esac
}

############################################################
# Modules                                                  #
############################################################
function Modules() {
  local modules=$(GetConfigParam modules)

  modules_counter=0
  if [ "$modules" != '' ]; then
    # Module $modules
    if [ "${modules: -5}" == ".list" ]; then
      echo -e "Modules list is ${Blue}"${modules}"${Color_Off}:"
      while IFS= read -r line ; do
        if [ "$line" != '' ]; then
          if [ "${line:0:1}" != "#" ]; then
            echo -e "  Module in list: ${Blue}"$line"${Color_Off}"
            Module ${line}
            ((modules_counter++))
          fi
        fi
      done < "$modules"
    else
      Module ${modules}
      ((modules_counter++))
    fi

  fi
  if [ $modules_counter == 0 ]; then
    echo -e "${Red}"Modules not found!"${Color_Off}"
    exit 1;
  fi
}

function Module() {
  module=$1
  echo -e "Module: ${Blue}"$module"${Color_Off}"
  if [[ -d "$module" ]]; then
    echo -e "  path is ${Blue}"$module"${Color_Off}"
    cd "$module"
  else
    echo -e " path is ${Blue}"$modulesPath/$line"${Color_Off}"
    cd $modulesPath
    cd $module
  fi
  RunCommand
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

command=
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      # display Help
      Help
      exit 0
      ;;
    -V|--version)
      # display version
      echo ${version}
      exit 0
      ;;
    deploy)
      # deploy
      command=deploy
      break
      ;;
    *)
    break
    ;;
  esac
done

config=''
if [ "$command" == '' ]; then
  Help
  exit 0
else
    shift
    for arg in "$@"
    do
      if [ "$arg" != '' ]; then
        config=$arg
        break
      fi
    done
fi

Run
