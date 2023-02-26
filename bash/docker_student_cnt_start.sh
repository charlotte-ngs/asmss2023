#!/bin/bash
#' ---
#' title: Docker Student Container Start
#' date:  2023-02-26 08:58:37
#' author: Peter von Rohr<peter.vonrohr@qualitasag.ch>
#' ---
#' ## Purpose
#' Seamless start of single docker container for a given student
#'
#' ## Description
#' Start single docker container for a single student
#'
#' ## Details
#' Take inputs via cmd line args and run docker start
#'
#' ## Example
#' ./docker_student_cnt_start.sh -u <student_user_name> -w <student_passwd> -v <home_dir> -p <rstudio_port>
#'
#' ## Set Directives
#' General behavior of the script is driven by the following settings
#+ bash-env-setting, eval=FALSE
set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  #  hence pipe fails if one command in pipe fails


#' ## Global Constants
#' ### Paths to shell tools
#+ shell-tools, eval=FALSE
ECHO=/bin/echo                             # PATH to echo                            #
DATE=/bin/date                             # PATH to date                            #
MKDIR=/bin/mkdir                           # PATH to mkdir                           #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #
SERVER=`hostname`                          # put hostname of server in variable      #

#' ### Directories
#' Installation directory of this script
#+ script-directories, eval=FALSE
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #
PROJDIR=$($DIRNAME $INSTALLDIR)


#' ### Files
#' This section stores the name of this script and the
#' hostname in a variable. Both variables are important for logfiles to be able to
#' trace back which output was produced by which script and on which server.
#+ script-files, eval=FALSE
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
SCRSTEM=$(echo $SCRIPT | sed -e "s/\.sh//")



#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT  -i <image_name> -u <student_user_name> -w <student_passwd> -v <home_dir> -p <rstudio_port> -h -z"
  $ECHO "  where "
  $ECHO "        -i. --             container image name ..."
  $ECHO "        -u  --             student user name ..."
  $ECHO "        -w  --             student password ..."
  $ECHO "        -v  --             student home directory on host ..."
  $ECHO "        -p  --             rstudio port on host ..."
  $ECHO "        -h  --  (optional) show usage message ..."
  $ECHO "        -z  --  (optional) produce verbose output"
  $ECHO ""
  exit 1
}

#' ### Start Message
#' The following function produces a start message showing the time
#' when the script started and on which server it was started.
#+ start-msg-fun, eval=FALSE
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

#' ### End Message
#' This function produces a message denoting the end of the script including
#' the time when the script ended. This is important to check whether a script
#' did run successfully to its end.
#+ end-msg-fun, eval=FALSE
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

#' ### Log Message
#' Log messages formatted similarly to log4r are produced.
#+ log-msg-fun, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

#' ### Check Docker Container
#' Check whether docker container is running
#+ check-docker-cnt-running-fun
check_docker_cnt_running () {
  if [[ $(docker ps -a | grep ${USERNAME}_rstudio | wc -l) -gt 0 ]];then
    log_msg check_docker_cnt_running " * Docker container ${USERNAME}_rstudio already running ... "
    exit 1
  fi
}


#' ## Main Body of Script
#' The main body of the script starts here with a start script message.
#+ start-msg, eval=FALSE
start_msg

#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
USERNAME=''
PASSWD=''
DOCKERIMAGE=''
HOMEDIR=''
RSTPORT=10087
VERBOSE='false'
while getopts ":i:p:u:v:w:hz" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    i)
      DOCKERIMAGE=$OPTARG
      ;;
    p)
      RSTPORT=$OPTARG
      ;;
    u)
      USERNAME=$OPTARG
      ;;
    v)
      HOMEDIR=$OPTARG
      ;;
    w)
      PASSWD=$OPTARG
      ;;
    z)
      VERBOSE='true'
      ;;
    :)
      usage "-$OPTARG requires an argument"
      ;;
    ?)
      usage "Invalid command line argument (-$OPTARG) found"
      ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

#' ## Checks for Command Line Arguments
#' The following statements are used to check whether required arguments
#' have been assigned with a non-empty value
#+ argument-test, eval=FALSE
if test "$DOCKERIMAGE" == ""; then
  usage "-i <docker_image> not defined"
fi
if test "$RSTPORT" == ""; then
  usage "-p <rstudio_port> not defined"
fi
if test "$USERNAME" == ""; then
  usage "-u <user_name> not defined"
fi
if test "$HOMEDIR" == ""; then
  usage "-v <home_dir> not defined"
fi
if test "$PASSWD" == ""; then
  usage "-w <pass_wd> not defined"
fi


#' ## Check Docker Container Running
#' Check whether docker container is already running
#+ check-docker-cnt-running
check_docker_cnt_running


#' ## Start Docker Container
#' Docker container started with given parameters
#+ start-docker-cnt
if [[ $VERBOSE == 'true' ]];then 
  log_msg $SCRIPT " * Running docker container with:"
  log_msg $SCRIPT "   ==> Port: $RSTPORT ... "
  log_msg $SCRIPT "   ==> Home dir: $HOMEDIR ..."
  log_msg $SCRIPT "   ==> User: $USERNAME ..."
  log_msg $SCRIPT "   ==> Dockerimage: $$DOCKERIMAGE ..."
fi
docker run -d --rm -p $RSTPORT:8787 -e PASSWORD=$PASSWD -v ${HOMEDIR}:/home/rstudio --name ${USERNAME}_rstudio $DOCKERIMAGE

if [[ $VERBOSE == 'true' ]];then log_msg $SCRIPT " * Change mod of ${HOMEDIR} ...";fi
sudo chmod -R 777 ${HOMEDIR}

# firewall
if [ `sudo ufw status | grep "$RSTPORT/tcp" | grep ALLOW | wc -l` -eq 0 ]
then
  if [[ $VERBOSE == 'true' ]];then log_msg $SCRIPT " * ufw allow port:  $RSTPORT ...";fi
  sudo ufw allow $RSTPORT/tcp
fi


#' ## End of Script
#' This is the end of the script with an end-of-script message.
#+ end-msg, eval=FALSE
end_msg

