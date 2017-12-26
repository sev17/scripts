#!/bin/sh
ldapsearch -h yourLDAPServer40.rjf.com -p 17010 -E pr=10000/noprompt -D cn=OracleContext -b "dc=yourDC,dc=com" -s sub "(objectCategory=orclNetService)" cn orclNetDescString |
sed -n -e '/^cn:/,/^$/ {
  s/^ *//
  s/ *$//
  s/^cn: //
  s/orclNetDescString: / = /
  p
}' | awk 'BEGIN { FS = "\n"; RS = ""; ORS = "\n\n" }
{
gsub(/\n/, "")
print
}'
