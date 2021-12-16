## If your SVC have a lot of hosts,and most of them are automatically created by powervc
## Powervc automatically created is generally degraded state
## In these degraded hosts,may be have many node_logged_in_count is singular
## Copy and paste them to the command line to run 
## Only used SVC's lshost command, no superuser user required
## The SVC version tested is V7.8,no awk or gawk,so mostly use sed command
## The output uses a comma separator
## Recommended to copy the output to a csv file or Direct output to csv file
## And use excel to optimize the format

echo 'Host Name,WWPN,node_logged_in_count,WWPN,node_logged_in_count,\
    WWPN,node_logged_in_count,WWPN,node_logged_in_count,'
for id in `lshost -nohdr -delim : -filtervalue status=degraded |\
    sed 's/:.*//g'`
do
  for count in `lshost $id |\
    sed -n 's/node_logged_in_count //p' |sed -n '/0/!p'|uniq`
  do 
    if [ $(($count%2)) -ne 0 ]
    then 
      lshost -delim , $id |\
      sed -n '/^name\|^WWPN\|^node_/p'|\
      sed '/^WWPN/{N;s/\n/,/}'|\
      sed -n '/node_logged_in_count,0/!p'|\
      sed 's/name,//;s/WWPN,//;s/node_logged_in_count,//'|\
      tr '\n' ','
      echo
    fi
  done
done
