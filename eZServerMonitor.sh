#!/bin/bash
 
# **************************************************** #
#                                                      #
#                eZ Server Monitor `sh                 #
#                                                      #
#             ***************************              #
#                                                      #
#     @name eZ Server Monitor `sh                      #
#     @author ShevAbam                                 #
#     @website ezservermonitor.com                     #
#     @created 30 nov. 2017                            #
#     @version 2.3                                     #
#                                                      #
# **************************************************** #
 
 
# ************************************************************ #
# *                        [ CONFIG ]                        * #
# ************************************************************ #
 
# Disk usage - Show or hide virtual mountpoints (tmpfs)
DISK_SHOW_TMPFS=false
 
# Service who returns WAN IP
GET_WAN_IP="https://www.ezservermonitor.com/myip"
 
# Hosts to ping
PING_HOSTS=("google.com" "facebook.com" "yahoo.com")
 
# Services port number to check
# syntax :
#   SERVICES_NAME[port_number]="label"
#   SERVICES_HOST[port_number]="localhost"
SERVICES_NAME[21]="FTP Server"
SERVICES_HOST[21]="localhost"
 
SERVICES_NAME[22]="SSH"
SERVICES_HOST[22]="localhost"
 
SERVICES_NAME[80]="Web Server"
SERVICES_HOST[80]="localhost"
 
SERVICES_NAME[3306]="Database"
SERVICES_HOST[3306]="localhost"
 
# Temperatures blocks (true for enable)
TEMP_ENABLED=false

# Text color : RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE
THEME_TEXT=GREEN

# Title color : WHITE_ON_GREY, WHITE_ON_RED, WHITE_ON_GREEN, WHITE_ON_BLUE, WHITE_ON_MAGENTA, WHITE_ON_CYAN, BLACK_ON_YELLOW
THEME_TITLE=WHITE_ON_GREEN
 
 
# ********************************************************** #
# *                        [ VARS ]                        * #
# ********************************************************** #
 
# Constants -- DON'T TOUCH !!
ESM_NAME="eZ Server Monitor \`sh"
ESM_VERSION="2.3"
ESM_AUTHOR="ShevAbam"
ESM_CREATED="30 nov. 2017"
ESM_URL="https://www.ezservermonitor.com"
 
# Colors
NC="\e[0m"
RED="\e[31;40m"
GREEN="\e[32;40m"
YELLOW="\e[33;40m"
BLUE="\e[34;40m"
MAGENTA="\e[35;40m"
CYAN="\e[36;40m"
WHITE="\e[37;40m"
 
# Styles
BOLD="\e[1m"
RESET="\e[0m"
WHITE_ON_GREY="\e[100;97m"
WHITE_ON_RED="\e[41;37m"
WHITE_ON_GREEN="\e[42;37m"
WHITE_ON_BLUE="\e[104;37m"
WHITE_ON_MAGENTA="\e[45;37m"
WHITE_ON_CYAN="\e[46;37m"
BLACK_ON_YELLOW="\e[103;30m"
 
 
# *************************************************************** #
# *                        [ FUNCTIONS ]                        * #
# *************************************************************** #
 
function makeTitle()
{
    echo -e "${BOLD}${!THEME_TITLE}  $1  ${RESET}"
}
 
# Function : system
function system()
{
    OS=`uname -s`
  
    [[ -e "/usr/bin/lsb_release" ]] && DISTRO=`/usr/bin/lsb_release -ds` || [[ -e "/etc/system-release" ]] && DISTRO=`cat /etc/system-release` || DISTRO=`find /etc/*-release -type f -exec cat {} \; | grep NAME | tail -n 1 | cut -d= -f2 | tr -d '"'`
  
    HOSTNAME=`hostname`
    KERNEL_INFO=`/bin/uname -r`
   
    UPTIME=`cat /proc/uptime`
    UPTIME=${UPTIME%%.*}
    UPTIME_MINUTES=$(( UPTIME / 60 % 60 ))
    UPTIME_HOURS=$(( UPTIME / 60 / 60 % 24 ))
    UPTIME_DAYS=$(( UPTIME / 60 / 60 / 24 ))
 
    LAST_BOOT_DATE=`who -b | awk '{print $3}'`
    LAST_BOOT_TIME=`who -b | awk '{print $4}'`
 
    USERS_NB=`who | wc -l`
 
    CURRENT_DATE=`/bin/date '+%F %T'`
 
    makeTitle "System"
 
    echo -e "${!THEME_TEXT}  Hostname\t   ${WHITE}$HOSTNAME"
    echo -e "${!THEME_TEXT}  OS\t\t   ${WHITE}$OS $DISTRO"
    echo -e "${!THEME_TEXT}  Kernel\t   ${WHITE}$KERNEL_INFO"
    echo -e "${!THEME_TEXT}  Uptime\t   ${WHITE}$UPTIME_DAYS day(s), $UPTIME_HOURS hours(s), $UPTIME_MINUTES minute(s)"
    echo -e "${!THEME_TEXT}  Last boot\t   ${WHITE}$LAST_BOOT_DATE $LAST_BOOT_TIME"
    echo -e "${!THEME_TEXT}  Current user(s)  ${WHITE}$USERS_NB connected"
    echo -e "${!THEME_TEXT}  Server datetime  ${WHITE}$CURRENT_DATE"
}
 
# Function : load average
function load_average()
{
    PROCESS_NB=`ps -e h | wc -l`
    PROCESS_RUN=`ps r h | wc -l`
 
    CPU_NB=`cat /proc/cpuinfo | grep "^processor" | wc -l`
 
    LOAD_1=`cat /proc/loadavg | awk '{print $1}'`
    # LOAD_1_PERCENT=`echo $LOAD_1 | awk '{print 100 * $1}'`
    LOAD_1_PERCENT=`echo $(($(echo $LOAD_1 | awk '{print 100 * $1}') / $CPU_NB))`
    [[ $LOAD_1_PERCENT -ge 100 ]] && LOAD_1_PERCENT=100
 
    [[ $LOAD_1_PERCENT -ge 75 ]] && LOAD_1_COLOR=${RED} || [ $LOAD_1_PERCENT -ge 50 ] && LOAD_1_COLOR=${YELLOW} || LOAD_1_COLOR=${WHITE}

 
    LOAD_2=`cat /proc/loadavg | awk '{print $2}'`
    # LOAD_2_PERCENT=`echo $LOAD_2 | awk '{print 100 * $1}'`
    LOAD_2_PERCENT=`echo $(($(echo $LOAD_2 | awk '{print 100 * $1}') / $CPU_NB))`
    [[ $LOAD_2_PERCENT -ge 100 ]] && LOAD_2_PERCENT=100
 
    [[ $LOAD_2_PERCENT -ge 75 ]] && LOAD_2_COLOR=${RED} || [[ $LOAD_2_PERCENT -ge 50 ]] && LOAD_2_COLOR=${YELLOW} || LOAD_2_COLOR=${WHITE}
 
    LOAD_3=`cat /proc/loadavg | awk '{print $3}'`
    # LOAD_3_PERCENT=`echo $LOAD_3 | awk '{print 100 * $1}'`
    LOAD_3_PERCENT=`echo $(($(echo $LOAD_3 | awk '{print 100 * $1}') / $CPU_NB))`
    [[ $LOAD_3_PERCENT -ge 100 ]] && LOAD_3_PERCENT=100
 
    [[ $LOAD_3_PERCENT -ge 75 ]] && LOAD_3_COLOR=${RED} || [[ $LOAD_3_PERCENT -ge 50 ]] && LOAD_3_COLOR=${YELLOW} && LOAD_3_COLOR=${WHITE}
 
    echo
    makeTitle "Load Average"
    echo -e "${!THEME_TEXT}  Since 1 minute     $LOAD_1_COLOR $LOAD_1_PERCENT% ($LOAD_1)"
    echo -e "${!THEME_TEXT}  Since 5 minutes    $LOAD_2_COLOR $LOAD_2_PERCENT% ($LOAD_2)"
    echo -e "${!THEME_TEXT}  Since 15 minutes   $LOAD_3_COLOR $LOAD_3_PERCENT% ($LOAD_3)"
    echo -e "${!THEME_TEXT}  Processes\t      ${WHITE}$PROCESS_NB process, including $PROCESS_RUN running"
}
 
# Function : CPU
function cpu()
{
    CPU_NB=`cat /proc/cpuinfo | grep -i "^processor" | wc -l`
    CPU_INFO=`cat /proc/cpuinfo | grep -i "^model name" | awk -F": " '{print $2}' | head -1 | sed 's/ \+/ /g'`
    
    CPU_FREQ=`cat /proc/cpuinfo | grep -i "^cpu MHz" | awk -F": " '{print $2}' | head -1`

    [[ -z $CPU_FREQ ]] && CPU_FREQ=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq` && CPU_FREQ=$(( $CPU_FREQ / 1000 ))
    
    CPU_CACHE=`cat /proc/cpuinfo | grep -i "^cache size" | awk -F": " '{print $2}' | head -1`
    CPU_BOGOMIPS=`cat /proc/cpuinfo | grep -i "^bogomips" | awk -F": " '{print $2}' | head -1`
 
    echo
    makeTitle "CPU"
 
    [[ $CPU_NB -gt 1 ]] && echo -e "${!THEME_TEXT}  Number\t ${WHITE}$CPU_NB"
    echo -e "${!THEME_TEXT}  Model\t\t ${WHITE}$CPU_INFO"
    echo -e "${!THEME_TEXT}  Frequency\t ${WHITE}$CPU_FREQ MHz"
    echo -e "${!THEME_TEXT}  Cache L2\t ${WHITE}$CPU_CACHE"
    echo -e "${!THEME_TEXT}  Bogomips\t ${WHITE}$CPU_BOGOMIPS"
}
 
# Function : memory
function memory()
{
    MEM_TOTAL=`grep MemTotal /proc/meminfo | awk '{print $2}'`
    MEM_TOTAL=$(( $MEM_TOTAL / 1024 ))

    MEM_FREE=`grep MemFree /proc/meminfo | awk '{print $2}'`
    MEM_BUFFERS=`grep Buffers /proc/meminfo | awk '{print $2}'`
    MEM_CACHED=`grep Cached /proc/meminfo | awk '{print $2}' | head -1`

    MEM_FREE=$(( $MEM_FREE + $MEM_BUFFERS + $MEM_CACHED ))
    MEM_FREE=$(( $MEM_FREE / 1024 ))
 
    echo
    makeTitle "Memory"
    echo -e "${!THEME_TEXT}  RAM\t\t${WHITE}$MEM_FREE Mb free of $MEM_TOTAL Mb"
}
 
# Function : network
function network()
{
    [[ -e /sbin/ifconfig ]] && INTERFACES=`/sbin/ifconfig |awk -F '[/  |: ]' '{print $1}' |sed -e '/^$/d'` || INTERFACES=`/sbin/ip a | sed '/^[0-9]\:/!d' | cut -d ":" -f 2 | cut -d " " -f 2`
 
    [[ -e "/usr/bin/curl" ]] && IP_WAN=`curl -s ${GET_WAN_IP}` || IP_WAN=`wget ${GET_WAN_IP} -O - -o /dev/null`

    echo
    makeTitle "Network"
 
    for INTERFACE in $INTERFACES
    do
        IP_LAN=`/sbin/ip -f inet -o addr show ${INTERFACE} | cut -d\  -f 7 | cut -d/ -f 1`
        echo -e "${!THEME_TEXT}  IP LAN (${INTERFACE})\t ${WHITE}$IP_LAN"
    done
 
    echo -e "${!THEME_TEXT}  IP WAN\t ${WHITE}$IP_WAN"
}
 
# Function : ping
function ping()
{
    echo
    makeTitle "Ping"
 
    for HOST in ${PING_HOSTS[@]}
    do
        PING=`/bin/ping -qc 1 $HOST | awk -F/ '/^(rtt|round-trip)/ { print $5 }'`
 
        echo -e "${!THEME_TEXT}  ${HOST}\t ${WHITE}$PING ms"
    done
}
 
# Function : Disk space  (top 5)
function disk_space()
{
    HDD_TOP=`df -h | head -1 | sed s/^/"  "/`
    #HDD_DATA=`df -hl | grep -v "^Filesystem" | grep -v "^Sys. de fich." | sort -k5r | head -5 | sed s/^/"  "/`
    # HDD_DATA=`df -hl | sed "1 d" | grep -v "^Filesystem" | grep -v "^Sys. de fich." | sort | head -5 | sed s/^/"  "/`
 
 # Added P for POSIX compatibility to tackle an issue raised.
    [[ ${DISK_SHOW_TMPFS} = true ]] && HDD_DATA=`df -hlP | sed "1 d" | grep -iv "^Filesystem|Sys." | sort | head -5 | sed s/^/"  "/` || HDD_DATA=`df -hlP | sed "1 d" | grep -iv "^Filesystem|Sys." | grep -vE "^tmpfs|udev" | sort | head -5 | sed s/^/"  "/`
 
    echo
    makeTitle "Disk space (top 5)"
    echo -e "${!THEME_TEXT}$HDD_TOP"
    echo -e "${WHITE}$HDD_DATA"
}
 
# Function : services
function services()
{
    echo
    makeTitle "Services"
 
    for PORT in "${!SERVICES_NAME[@]}"
    do
        NAME=${SERVICES_NAME[$PORT]}
        HOST=${SERVICES_HOST[$PORT]}
 
        CHECK=`(exec 3<>/dev/tcp/$HOST/$PORT) &>/dev/null; echo $?`
 
        [[ $CHECK = 0 ]] && CHECK_LABEL=${WHITE}ONLINE || CHECK_LABEL=${RED}OFFLINE

        echo -e "${!THEME_TEXT}  $NAME ($PORT) : ${CHECK_LABEL}"
    done
}
 
# Function : hard drive temperatures
function hdd_temperatures()
{
    if [ ${TEMP_ENABLED} = true ] ; then
        echo
        makeTitle "Hard drive Temperatures"
 
        DISKS=`ls /sys/block/ | grep -E -i '^(s|h)d'`
       
        # If hddtemp is installed
        if [ -e "/usr/sbin/hddtemp" ] ; then
 
            for DISK in $DISKS
            do
                TEMP_DISK=`hddtemp -n /dev/$DISK`"°C"
               
                echo -e "  ${!THEME_TEXT}/dev/$DISK\t${WHITE}$TEMP_DISK"
            done
        else
            echo -e "${WHITE}\nPlease, install hddtemp${WHITE}"
        fi
    fi
}
 
# Function : system temperatures
function system_temperatures()
{
    if [ ${TEMP_ENABLED} = true ] ; then
        echo
        makeTitle "System Temperatures"

        # If lm-sensors is installed
        if [ -e "/usr/bin/sensors" ] ; then
            TEMP_CPU=`/usr/bin/sensors | grep -E "^(CPU Temp|Core 0)" | cut -d '+' -f2 | cut -d '.' -f1`"°C"
            TEMP_MB=`/usr/bin/sensors | grep -E "^(Sys Temp|Board Temp)" | cut -d '+' -f2 | cut -d '(' -f1`
        
            echo -e "  ${!THEME_TEXT}CPU          ${WHITE}$TEMP_CPU"
            echo -e "  ${!THEME_TEXT}Motherboard  ${WHITE}$TEMP_MB"
        # Raspberry Pi
        elif [ -f "/sys/class/thermal/thermal_zone0/temp" ] ; then
            TEMP_CPU=`cat /sys/class/thermal/thermal_zone0/temp`
            TEMP_CPU=$(( $TEMP_CPU / 1000 ))
           
            echo -e "  ${!THEME_TEXT}CPU          ${WHITE}$TEMP_CPU°C"

        else
            echo -e "${WHITE}\nPlease, install lm-sensors${WHITE}"
        fi
    fi
}
 
# Function : showAll
function showAll()
{
    system
    load_average
    cpu
    memory
    network
    ping
    disk_space
    services
    hdd_temperatures
    system_temperatures
}
 
# Function : showVersion
function showVersion()
{
  echo "$ESM_VERSION"
}
 
# Function : showHelp
function showHelp()
{
  echo
  echo "-------"
  echo -e "Name    : $ESM_NAME\nVersion : $ESM_VERSION\nAuthor  : $ESM_AUTHOR\nCreated : $ESM_CREATED"
  echo
  echo -e "$ESM_NAME is originally a PHP project allows you to display system's information of a Unix machine.\nThis is the bash version."
  echo
  echo -e "[USAGE]\n"
  echo -e "  -h, -u, --help, --usage    print this help message \n"
  echo -e "  -v, --version              print program version\n"
  echo -e "  -C, --clear                clear console\n                             Must be inserted before any argument\n"
  echo -e "  -s, --system               system information (OS and distro ; kernel ; hostname ; uptime ; users connected; last boot; datetime)\n"
  echo -e "  -e, --services             checks port number\n"
  echo -e "  -n, --network              network information (IP LAN ; IP WAN)\n"
  echo -e "  -p, --ping                 pings several hosts\n                             Can be configured in the file\n"
  echo -e "  -c, --cpu                  processor information (model ; frequency ; cache ; bogomips)\n"
  echo -e "  -m, --memory               RAM information (free and total)\n"
  echo -e "  -l, --load                 system load ; processus\n"
  echo -e "  -t, --temperatures         print CPU, system and HDD temperatures\n                             Can be configured in the file\n"
  echo -e "  -d, --disk                 disk space (top 5) ; sorted by alpha\n"
  echo -e "  -a, --all                  print all data\n"
  echo; echo;
  echo -e "More information on : $ESM_URL"
  echo "-------"
  echo
}
 
 
# *************************************************************** #
# *                       [ LET'S GO !! ]                       * #
# *************************************************************** #
 
if [ $# -ge 1 ] ; then
   
    while getopts "Csenpcmltdavhu-:" option
    do
        case $option in
            h | u) showHelp; exit ;;
            v) showVersion; exit;;
            C) clear ;;
            s) system ;;
            n) network ;;
            p) ping ;;
            c) cpu ;;
            m) memory ;;
            l) load_average ;;
            t) hdd_temperatures; system_temperatures ;;
            d) disk_space ;;
            e) services ;;
            a) showAll ;;
            -) case $OPTARG in
                  help | usage) showHelp; exit ;;
                  version) showVersion; exit ;;
                  all) showAll; exit ;;
                  clear) clear ;;
                  system) system ;;
                  services) services ;;
                  load) load_average ;;
                  cpu) cpu ;;
                  memory) memory ;;
                  network) network ;;
                  ping) ping ;;
                  disk) disk_space ;;
                  temperatures) hdd_temperatures; system_temperatures ;;
                  *) exit ;;
               esac ;;
            ?) echo "Option -$OPTARG inconnue"; exit ;;
            *) exit ;;
        esac
    done
   
else
    #showAll
    showHelp;
    exit;
fi
 
echo -e "${RESET}"
