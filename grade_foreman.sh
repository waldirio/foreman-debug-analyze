#!/bin/bash

#
# Created ....: 03/04/2016
# Purpose ....: Do a parse in a foreman-debug log, to show a review about the log file.
# Developer ..: Waldirio M Pinheiro <waldirio@redhat.com>
# Changelog ..:
#               Waiting ... :)
#


# Vars

XPTO="/tmp/XPTO"

menu()
{
while :
do
  clear
  checkStatusDir
  echo "#######################################################"
  echo "# FOREMAN DEBUG                                       #"
  echo "# SYSMGMT                                             #"
  echo "#                                                     #"
  echo "# 1. Define the foreman-debug file path               #"
  echo "# 2. Extract to /tmp/XPTO - $statusDir"
  echo "# 3. Grade (Check some parameters)                    #"
  echo "#                                                     #"
  echo "# 0. Exit                                             #"
  echo "#######################################################"
  echo -e "Option: \c"
  read opc

  case $opc in
    1) definePathFile;;
    2) extractToStage;;
    3) gradeEnv;;
    0) exit ;;
    *) echo "Wrong ..., type another one"; sleep 3;; 
  esac

done
}

checkStatusDir()
{
  if [ -d $XPTO ]; then
    statusDir="There is                  #"
  else
    statusDir="Need load foreman-debug   #"
  fi
}

definePathFile()
{
  echo -e "Type the full path of foreman-debug file: \c"
  read pathFile
  echo "Path is .... $pathFile"
  sleep 2
}

extractToStage()
{
  echo "Creating directory /tmp/XPTO"
  mkdir $XPTO

  echo "Extracting foreman-debug to /tmp/XPTO, waiting ...."
  tar Jxf $pathFile -C $XPTO
  echo "Extracted!"
  sleep 2
}

gradeEnv()
{
  dirName=$(ls -1 $XPTO)
  satVersion=$(cat $XPTO/$dirName/satellite_version |grep VER|cut -d = -f2 | sed -e 's/"//g' | sed -e 's/ //g')  
  puppetVersion=$(cat $XPTO/$dirName/version_puppet |grep ^[0-9])  
  rubyVersion=$(cat $XPTO/$dirName/version_ruby |grep ^ruby|sed -e 's/ruby //g')  
  memTotal=$(cat $XPTO/$dirName/meminfo |grep MemTotal| awk '{print $2}')  
  qtCPU=$(cat $XPTO/$dirName/cpuinfo |grep process| wc -l)  
  cpuModel=$(cat $XPTO/$dirName/cpuinfo |grep "model name"|sort -u|cut -d: -f2|sed -e 's/^ //g')  
  entriesForeman=$(cat $XPTO/$dirName/var/log/foreman/production.log |awk '{print $1, $3}'|grep ^[2] |awk '{print $2}'|sort|uniq -c)
  pingLocalhost=$(cat $XPTO/$dirName/ping_localhost |head -n 4)
  pingHostname=$(cat $XPTO/$dirName/ping_hostname |head -n 4)
  pingHostnameFull=$(cat $XPTO/$dirName/ping_hostname_full |head -n 4)
  networkInterfaces=$(cat $XPTO/$dirName/ip_a|grep inet)

  echo
  echo "#### Grade ####"
  echo "Satellite Version .................: $satVersion"
  echo "Puppet Version .........i..........: $puppetVersion"
  echo "Ruby Version ......................: $rubyVersion"
  echo "Memory Size .......................: $memTotal kB"
  echo "CPU Model .........................: $cpuModel" 
  echo "Entries in Foreman log ............: 
$entriesForeman" 
  echo
  echo "Network Interfaces ................:
$networkInterfaces"
  echo
  echo "Ping Localhost ....................:
$pingLocalhost"
  echo
  echo "Ping Hostname .....................:
$pingHostname"
  echo
  echo "Ping Hostname Full ................:
$pingHostnameFull"
  echo


  echo 
  echo "Press any key to continue"
  read xpto
}



# Main

menu
