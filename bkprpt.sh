#BSD/Mac OSX
find ~/bin -name "*.txt" -o -name "*.sh" -exec  stat -q -f "%m %z %N" {} +  |
gawk 'BEGIN { OFS = "," } { print int((systime() - $1)/86400), strftime("%m-%d-%Y", $1), $2, $3 }'

#RHEL
stat -c "%Y %s %n" ~/* | awk 'BEGIN { OFS = "," } { print int((systime() - $1)/86400), strftime("%m-%d-%Y", $1), $2, $3 }'

find /nfs/rman -name "*.bkp" -o -name "*.dbf" -exec  stat -c "%Y %s %n" {} +  |
awk 'BEGIN { OFS = "," } { print int((systime() - $1)/86400), strftime("%m-%d-%Y", $1), $2, $3 }' >> ~/rman.csv

find /nfs/dpz -name "*.dmp" -o -name "*.dmp.gz" -exec  stat -c "%Y %s %n" {} +  |
awk 'BEGIN { OFS = "," } { print int((systime() - $1)/86400), strftime("%m-%d-%Y", $1), $2, $3 }' >> ~/dpz.csv


#WIP
#OSX
find ~/bin -type f -exec stat -q -f "%m %z %N" {} + | gawk 'BEGIN { OFS = "," } { print ENVIRON["HOSTNAME"], int((systime() - $1)/86400), strftime("%m-%d-%Y", $1), $2, int($3 * 512), $4 }' >> $HOME/bin/logs/rman_usage_details.txt

#RHEL 
find /nfs/rman -type f -exec stat -c "%Y %s %n" {} + | awk 'BEGIN { OFS = "," } { print ENVIRON["HOSTNAME"], int((systime() - $1)/86400), strftime("%m-%d-%Y", $1), $2, $3 }' >> ~/rman_usage_details.txt
 
ssh $HOST "find /nfs/rman \( -name *.bkp -o -name *.dbf \) -exec stat -c \"%Y %s %n\" {} + | awk ''{ print \"${HOST}\"\",\"int((systime() - \$1)/86400)\",\"strftime(\"%m-%d-%Y\", \$1)\",\"\$2\",\"\$3*512\",\"\$4 }''" >> $HOME/bin/logs/rman_usage_details.txt
 