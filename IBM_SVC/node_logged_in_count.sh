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
