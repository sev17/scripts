#!/bin/bash
#######################
: <<'END'

NAME
		ldapaddora.sh

SYNOPSIS
		Adds an LDAP entry for use with Oracle LDAP name resolution.

SYNTAX
		ldapaddora.sh [-l] <String> [-a] <String> [-h] <String[]> [-s] <String[]>

DESCRIPTION
		The ldapaddora.sh script adds an ldap entry for LDAP Descriptor using the command-line utility ldapadd.

PARAMETERS
    -l: [Required] LDAP Descriptor

		-a: [Required] ScanAddress or host for non-RAC

		-h: Comma-seperated host(s)

		-s: Comma-seperated SID(s)

		-x: whatif shows what would be executed without running ldap commands

NOTES

		Version History
		v1.0   - Chad Miller - 7/22/2015 - Initial release

		-------------------------- EXAMPLE 1 --------------------------

		ldapaddora.sh -l ora1dev -a ora1-scan -h ora1dbadm01,ora1dbadm02 -s ora1dev1,ora1dev2

		This command adds ora1dev LDAP entries: one for scan address, two for HostName/SID and one for CD.

*****IMPORTANT*********

Setup keytab access for AD account to authenicate to ADAM or AD LDS servers:
1. Run ktutil !!! DO NOT RUN version bundled with OS, use Centrify version !!!

	/usr/share/centrifydc/kerberos/sbin/ktutil

2. ktutil is an interactive command run following ktutil commands:

ktutil: addent -password -p youralias@yourDC.COM -k 1 -e RC4-HMAC
Password for youralias@yourDC.COM: [enter password for username]
ktutil: wkt /Users/youralias/bin/ldap.keytab
ktuitl: q

END

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#echo $SCRIPT_DIR
LDAPSERVERS="yourLDAPserver1xb:17010 yourLDAPserver1xa:17010"
#For Testing
#LDAPSERVERS="yourLDAPserver1xb:17010 yourLDAPserver1xa:17010"
#Change this account to your alias or service account
LDAP_ADMIN="youralias@yourDC.COM"
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
    a)
			scan="${OPTARG}"
			if [[ "${scan}" =~ ^- ]]; then
				echo "missing arg -s <Scan Address>">&2
				exit 1
			fi
			;;
    h)
			hosts=(${OPTARG//,/ })
			if [[ "${hosts[0]}" =~ ^- ]]; then
 			 echo "missing arg -h <hosts>">&2
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
[[ $scan ]] || { echo "missing arg -a <ScanAdress or host for non-RAC>">&2; exit 1; }
#Check all params processed if not, probably -h and -s were specified incorrectly. Use either -h h1,h2 or -h "h1 h2"
shift $(( OPTIND -1 ))
[[ $1 ]] && { echo "Incorrect Syntax" >&2; exit 1; }

if [[ $whatif ]]
then
	echo "Parameters:"
	echo "l: ${ldapdesc}"
	echo "a: ${scan}"
	echo "h: ${hosts[@]}"
	echo "s: ${sids[@]}"
fi

#Create or overwrite new empty ldif file
path="${SCRIPT_DIR}/add.ldif"
echo -n "">"$path"

#1. Add ScanAddress to ldif file. For non-RAC the ScanAdress will be HostName of single node
value=
value=$(cat <<SETVAR
dn: CN=${ldapdesc},CN=OracleContext,DC=yourDCit,DC=com
changetype: add
objectClass: top
objectClass: orclNetService
cn: ${ldapdesc}
orclNetDescString:
 (DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${scan})(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=${ldapdesc}_ad.yourDC.com)))
SETVAR
)

echo "$value" >>"$path"

#2. For each HostName/SID add entry to ldif file
if [[ ${#hosts[@]} -gt 1 && ${#sids[@]} -gt 1 ]]
then
    for (( i=0; i<${#hosts[@]}; i++ ))
    do
value=
value=$(cat <<SETVAR

dn: CN=${sids[$i]},CN=OracleContext,DC=yourDCit,DC=com
changetype: add
objectClass: top
objectClass: orclNetService
cn: ${sids[$i]}
orclNetDescString:
 (DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${hosts[$i]})(PORT=1521)))(CONNECT_DATA=(SID=${sids[$i]})))
SETVAR
)

        echo "$value" >>"$path"
    done
fi

#3. Add Continous Delivery cd_ prefixed LDAP entry to ldif file
if [[ $hosts && $sids ]]
then
	value=
value=$(cat <<SETVAR

dn: CN=cd_${ldapdesc},CN=OracleContext,DC=yourDCit,DC=com
changetype: add
objectClass: top
objectClass: orclNetService
cn: cd_${ldapdesc}
orclNetDescString:
 (DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=${hosts[0]})(PORT=1521)))(CONNECT_DATA=(SID=${sids[0]})))
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
		echo "ldapadd -h ${hostnport[0]} -p ${hostnport[1]} -c -v -S ${SCRIPT_DIR}/ldif_${hostnport[0]}.err -f ${path} 2>&1 | tee -a ${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
	else
		echo -n "">"${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
		#Test authentication using ldapwhoami
		#ldapwhoami -h "${hostnport[0]}" -p "${hostnport[1]}"
		ldapadd -h "${hostnport[0]}" -p "${hostnport[1]}" -c -v -S "${SCRIPT_DIR}/ldif_${hostnport[0]}.err" -f "${path}" 2>&1 | tee -a "${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
		echo "ExitCode: $?"
		echo "Command: ldapadd -h ${hostnport[0]} -p ${hostnport[1]} -c -v -S ${SCRIPT_DIR}/ldif_${hostnport[0]}.err -f ${path} 2>&1 | tee -a ${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
	fi
done

exit 0
