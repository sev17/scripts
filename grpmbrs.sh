#!/bin/sh 
ldapsearch -H ldap://yourdc.com:389 -o ldif-wrap=no -E pr=10000/noprompt  -b "OU=Security,OU=Groups,dc=yourdc,dc=com" -s sub "(&(objectCategory=group)(CN=yourGroupName))" member -LLL |
 sed -n -e '/^dn:/,/^$/ {
	s/^dn: .*//
	s/member: //
	p
}' | grep -e CN= | tr \\n \\0 | xargs -0 -I{} ldapsearch -H ldap://yourdc.com:389 -b "{}" -s sub "(objectClass=user)" sAMAccountName -LLL | 
sed -n -e '/sAMAccountName: /,/\S*/ {
	s/sAMAccountName: //
	p
}' | grep .  > ./grpmbrs.txt