#!/bin/bash
#######################
: <<'END'

NAME
		ldapdeleteora.sh

SYNOPSIS
		Deletes an LDAP entry for use with Oracle LDAP name resolution.

SYNTAX
		ldapdeleteora.sh [-l] <String>

DESCRIPTION
		The ldapdeleteora.sh script deletes an ldap entry for LDAP Descriptor using the command-line utility ldapdelete.

PARAMETERS
    -l: [Required] LDAP Descriptor

		-s: Comma-seperated SID(s)

		-x: whatif shows what would be executed without running ldap commands

NOTES

		Version History
		v1.0   - Chad Miller - 7/23/2015 - Initial release

		-------------------------- EXAMPLE 1 --------------------------

		ldapdeleteora.sh -l ora1dev -s ora1dev1,ora1dev2

		This command deletes ora1dev LDAP entries.

*****IMPORTANT*********

Setup keytab access for AD account to authenicate to ADAM or AD LDS servers:
1. Run ktutil !!! DO NOT RUN version bundled with OS, use Centrify version !!!

	/usr/share/centrifydc/kerberos/sbin/ktutil

2. ktutil is an interactive command run following ktutil commands:

ktutil: addent -password -p youralias@RJF.COM -k 1 -e RC4-HMAC
Password for youralias@RJF.COM: [enter password for username]
ktutil: wkt /Users/youralias/bin/ldap.keytab
ktuitl: q

END

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#echo $SCRIPT_DIR
LDAPSERVERS="yourLDAPserver1xb:17010 yourLDAPserver1xa:17010"
#For Testing
#LDAPSERVERS="yourLDAPserver1xb:17010 yourLDAPserver1xa:17010"
#Change this account to your alias or service account
LDAP_ADMIN="youralias@RJF.COM"
LDAP_KEYTAB="${SCRIPT_DIR}/ldap.keytab"

#######################
#Verify LDAP keytab has been created for specified LDAP ADMIN
/usr/share/centrifydc/kerberos/bin/klist -k "${LDAP_KEYTAB}" | grep -q "${LDAP_ADMIN}"
if [[ ! $? ]]; then
	echo "Please create LDAP keytab file for LDAP ADMIN account.">&2
	exit 1
fi

#######################
if [[ $# -eq 0 ]]  # Must have command-line args to run script.
then
  echo "Please invoke this script with one or more command-line arguments.">&2
  exit 1
fi

#######################
while getopts ":l:a:h:s:x" opt; do
	case $opt in
    l)
			ldapdesc="${OPTARG}"
			if [[ "${ldapdesc}" =~ ^- ]]; then
				echo "missing arg -l <LDAP Descriptor>">&2
				exit 1
			fi
			;;
		s)
			 sids=(${OPTARG//,/ })
			 if [[ "${sids[0]}" =~ ^- ]]; then
				 echo "missing arg -s <SIDs>">&2
				 exit 1
			 fi
			 ;;
		x)
			whatif=true
			;;
		\?)
	    echo "Invalid option: -${OPTARG}">&2
			exit 1
			;;
    :)
			echo "Option -${OPTARG} is missing an argument">&2
      exit 1
			;;
  esac
done

#######################
#Check Mandatory Parameters
[[ $ldapdesc ]] || { echo "missing arg -l <LDAP Descriptor>">&2; exit 1; }
#Check all params processed if not, probably -h and -s were specified incorrectly. Use either -h h1,h2 or -h "h1 h2"
shift $(( OPTIND -1 ))
[[ $1 ]] && { echo "Incorrect Syntax" >&2; exit 1; }

if [[ $whatif ]]
then
	echo "Parameters:"
	echo "l: ${ldapdesc}"
	echo "s: ${sids[@]}"
fi

#Create or overwrite new empty ldif file
path="${SCRIPT_DIR}/delete.ldif"
echo -n "">"$path"

#1. Add ScanAddress to ldif file. For non-RAC the ScanAdress will be HostName of single node
value=
value=$(cat <<SETVAR
dn: CN=${ldapdesc},CN=OracleContext,DC=yourDC,DC=com
changetype: delete
SETVAR
)

echo "$value" >>"$path"

#2. For each SID add entry to ldif file
if [[ ${#sids[@]} -gt 1 ]]
then
    for (( i=0; i<${#sids[@]}; i++ ))
    do
value=
value=$(cat <<SETVAR

dn: CN=${sids[$i]},CN=OracleContext,DC=yourDC,DC=com
changetype: delete
SETVAR
)

        echo "$value" >>"$path"
    done
fi

#3. Add Continous Delivery cd_ prefixed LDAP entry to ldif file
if [[ $sids ]]
then
	value=
value=$(cat <<SETVAR

dn: CN=cd_${ldapdesc},CN=OracleContext,DC=yourDC,DC=com
changetype: delete
SETVAR
)

	echo "$value" >>"$path"
fi

#Get kerberos ticket via kinit will be used for ldap authenication
kinit -k -t "${LDAP_KEYTAB}" "${LDAP_ADMIN}"
if [[ ! $? ]]; then
	echo "kerberos authenication error: kinit -k -t ${LDAP_KEYTAB} ${LDAP_ADMIN}">&2
	exit 1
fi

for ldapserver in $LDAPSERVERS; do
	hostnport=(${ldapserver//:/ })
	if [[ $whatif ]]
	then
		echo "ldapmodify -h ${hostnport[0]} -p ${hostnport[1]} -c -f ${path} 2>&1 | tee -a  ${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
	else
		echo -n "">"${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
		#Test authentication using ldapwhoami
		#ldapwhoami -h "${hostnport[0]}" -p "${hostnport[1]}"
		ldapmodify -h "${hostnport[0]}" -p "${hostnport[1]}" -c -f "${path}" 2>&1 | tee -a "${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
		echo "ExitCode: $?"
		echo "Command: ldapmodify -h ${hostnport[0]} -p ${hostnport[1]} -c -f ${path} 2>&1 | tee -a ${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
	fi
done

exit 0
