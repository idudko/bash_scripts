declare cmdCounter=1
declare -rx USERLOGIN="$(logname)"
declare -rx USERTTY="$(tty)"
declare -x USERLOGINPID="$(who -mu | awk '{print $6}')"
declare -rx SYSLOGPRIORITY="local1.notice"

set +o functrace
function log2syslog
{
   [[ -z $USERLOGINPID ]] && USERLOGINPID="in_subshell"
   local auditPreString="[${USERLOGIN}/${USERLOGINPID} as ${USER}/$$ on ${USERTTY}]"
   local lastCmdCounter=$(fc -l -1 | cut -f1)
   local lastCmdLogged=$(fc -l -1 | cut -f2 | sed 's/^ *//g')

   if (( "10#"$lastCmdCounter > "10#"$cmdCounter)); then
	if (( "10#"$cmdCounter > 1 )); then
	    logger -p ${SYSLOGPRIORITY} -t bash_audit -i -- "${auditPreString} CWD: ${PWD} COMMAND: ${lastCmdLogged}"
	fi
	cmdCounter=${lastCmdCounter}
	return 0
   else
	return 1
   fi
}
declare -frx +t log2syslog
trap log2syslog DEBUG

