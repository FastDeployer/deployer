#!/bin/bash

version='1.0.0' # Software version
versionDate='2024-11-17 11:18' # Software version date

defaultDeployerScript=deployer.sh
defaultUpgradeScript=upgrade.sh

# Reset
Color_Off='\033[0m' # Text Reset

# Regular Colors
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Blue='\033[0;34m'   # Blue
White='\033[0;37m'  # White

workPath=${PWD}'/'
modulesPath=

############################################################
# Help                                                     #
############################################################
Help() {
  # Display Help
  echo -e "${Green}____________________${Color_Off}"
  echo -e "${Green}FastDeployer ${Color_Off} version ${Yellow}${version}${Color_Off} ${versionDate}"
  echo
  echo -e "${Yellow}Usage:${Color_Off}"
  echo "  command [modules] [options]"
  echo
  echo -e "${Yellow}Available commands:${Color_Off}"
  echo -e "  ${Green}deploy${Color_Off}  Deploy."
  # echo -e "  ${Green}upgrade${Color_Off} Upgrade."
  echo
  echo -e "${Yellow}Modules:${Color_Off}"
  echo -e "  ${Green}Path(s) or list(s)${Color_Off} Path(s) or *.list" to modules.
  echo
  echo -e "${Yellow}Options:${Color_Off}"
  echo -e "  ${Green}-h, --help${Color_Off}      Print this Help."
  # echo -e "  ${Green}-v, --verbose${Color_Off}   Verbose mode."
  echo -e "  ${Green}-V, --version${Color_Off}   Display this application version and exit."
  echo
}

############################################################
# Env                                                      #
############################################################
Env() {
  echo
  echo -e "Working directory: ${Blue}$workPath${Color_Off}"
  echo -e "Modules directory: ${Blue}$modulesPath${Color_Off}"
  echo
  # Set environments
  echo -e Set environments from ${Green}$workPath'.env'${Color_Off}
  source $workPath'.env'
  modulesPath=${DEPLOYER_DEFAULT_MODULES_PATH}
}

############################################################
# Run                                                   #
############################################################
Run() {
  Env
  Modules
}

############################################################
# RunCommand                                                   #
############################################################
RunCommand() {
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
    upgrade)
      # upgrade
      if [ -r "${defaultUpgradeScript}" ]; then
        bash ${defaultUpgradeScript}
      else
        echo -e "${Red}"File ${defaultUpgradeScript} not found in folder ${PWD}"${Color_Off}"
        exit 3;
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
Modules() {
  modules_counter=0
  if [ "$modules" != '' ]; then
    # Module $modules
    for ((i = 0 ; i < counter ; i++ ));
    do
      module=${modules[$i]}
      if [ "${module: -5}" == ".list" ]; then
        echo -e "Modules list is ${Blue}"${module}"${Color_Off}:"
        while read line ; do
          if [ "$line" != '' ]; then
            if [ "${line:0:1}" != "#" ]; then
              echo -e "  Module in list: ${Blue}"$line"${Color_Off}"
              Module ${line}
              ((modules_counter++))
            fi
          fi
        done < "$module"
      else
        Module ${module}
        ((modules_counter++))
      fi
    done
  fi
  if [ $modules_counter == 0 ]; then
    echo -e "${Red}"Modules not found!"${Color_Off}"
    exit 1;
  fi
}

Module() {
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
    upgrade)
      # upgrade
      command=upgrade
      break
      ;;
    *)
    break
    ;;
  esac
done

counter=0
modules=()
if [ "$command" == '' ]; then
  Help
  exit 0
else
    shift
    for arg in "$@"
    do
      if [ "$arg" != '' ]; then
        modules[$counter]=$arg
        ((counter++))
      fi
    done
fi

Run
