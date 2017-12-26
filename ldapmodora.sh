#!/bin/bash
#######################
: <<'END'

NAME
		ldapmodora.sh

SYNOPSIS
		Modifes an LDAP entry for use with Oracle LDAP name resolution.

SYNTAX
		ldapmodora.sh [-l] <String>

DESCRIPTION
		The ldapmodora.sh script modifies the orclNetDescString fixing missing PORT NUMBER using the command-line utility ldapmodify.

PARAMETERS
    -l: [Required] LDAP Descriptor

	-x: whatif shows what would be executed without running ldap commands

NOTES

		Version History
		v1.0   - Chad Miller - 11/18/2015 - Initial release

		-------------------------- EXAMPLE 1 --------------------------

		ldapmodora.sh -l oud2test

		This command modifies oud2test LDAP entry adding PORT=1521 where PORT=NULL

END

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#echo $SCRIPT_DIR
LDAPSERVER="yourLDAP40aplxa.yourDC.com:1389"
#For Testing
#LDAPSERVER="yourLDAP40aplxa.yourDC.com:1389"
LDAP_ADMIN="cn=oracledba"
LDAP_PASSWDFILE="${SCRIPT_DIR}/.oudpwd"

#######################
#Verify LDAP password file has been created for specified LDAP ADMIN
if [[ ! -e $LDAP_PASSWDFILE ]]; then
	echo "Please create LDAP password file ${LDAP_PASSWDFILE} for LDAP ADMIN account ${LDAP_ADMIN}.">&2
	exit 1
fi

#######################
if [[ $# -eq 0 ]]  # Must have command-line args to run script.
then
  echo "Please invoke this script with one or more command-line arguments.">&2
  exit 1
fi

#######################
while getopts ":l:x" opt; do
	case $opt in
    l)
			ldapdesc="${OPTARG}"
			if [[ "${ldapdesc}" =~ ^- ]]; then
				echo "missing arg -l <LDAP Descriptor>">&2
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
#Check all params processed
shift $(( OPTIND -1 ))
[[ $1 ]] && { echo "Incorrect Syntax" >&2; exit 1; }

if [[ $whatif ]]
then
	echo "Parameters:"
	echo "l: ${ldapdesc}"
fi

#######################
#Create or overwrite new empty ldif file
path="${SCRIPT_DIR}/modify.ldif"
echo -n "">"$path"

#1. Get orclNetDescString for given ldapdesc
searchout=$(ldapsearch -H ldap://${LDAPSERVER} -x -D ${LDAP_ADMIN} -y ${LDAP_PASSWDFILE}  -b "cn=${ldapdesc},cn=OracleContext,dc=yourDC,dc=com" -s sub "(objectClass=orclDBServer)" orclNetDescString -LLL)
if [[ $? -ne 0 ]]; then
	echo "ldapsearch Failed to return results.">&2
	echo "#######################"
	echo "searchout: ${searchout}"
	echo "#######################"
	exit 1
fi

if [[ $whatif ]]
then
	echo "#######################"
	echo "searchout: ${searchout}"
	echo "#######################"
fi

netstring=$(echo "${searchout}" | awk 'BEGIN { FS = "\n"; RS = ""; OFS = "" } FNR == 2 { gsub(/orclNetDescString: /,""); gsub(/[[:blank:]]/,""); gsub(/PORT=null/,"PORT=1521"); print $3, $4 }')

if [[ $whatif ]]
then
	echo "netstring: ${netstring}"
	echo "#######################"
fi

#######################
#Verify orclNetDescString
echo "${netstring}" | grep -q "DESCRIPTION"
if [[ $? -ne 0 ]]; then
	echo "ldap search Failed to retrieve orclNetDescString.">&2
	exit 1
fi

#######################
#Add modify section to ldif file
value=
value=$(cat <<SETVAR
dn: CN=${ldapdesc},CN=OracleContext,DC=yourDC,DC=com
changetype: modify
replace: orclNetDescString
orclNetDescString: ${netstring}
-
SETVAR
)

echo "$value" >>"$path"

#######################
#Run ldapmodify
hostnport=(${LDAPSERVER//:/ })
if [[ $whatif ]]
then
	echo "ldapmodify -h ${hostnport[0]} -p ${hostnport[1]} -x -D ${LDAP_ADMIN} -y ${LDAP_PASSWDFILE} -c -v -S ${SCRIPT_DIR}/ldif_${hostnport[0]}.err -f ${path} 2>&1 | tee -a ${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
else
	echo -n "">"${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
	#Test authentication using ldapwhoami
	#ldapwhoami -h "${hostnport[0]}" -p "${hostnport[1]} -x -D ${LDAP_ADMIN} -y ${LDAP_PASSWDFILE}"
	ldapmodify -h "${hostnport[0]}" -p "${hostnport[1]}" -x -D "${LDAP_ADMIN}" -y "${LDAP_PASSWDFILE}" -c -v -S "${SCRIPT_DIR}/ldif_${hostnport[0]}.err" -f "${path}" 2>&1 | tee -a "${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
	echo "ExitCode: $?"
	echo "Command: ldapmodify -h ${hostnport[0]} -p ${hostnport[1]} -x -D ${LDAP_ADMIN} -y ${LDAP_PASSWDFILE} -c -v -S ${SCRIPT_DIR}/ldif_${hostnport[0]}.err -f ${path} 2>&1 | tee -a ${SCRIPT_DIR}/ldif_${hostnport[0]}.log"
fi

exit 0
