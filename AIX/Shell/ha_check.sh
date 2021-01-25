#!/bin/ksh
# Verify and Synchronize Cluster Configuration.
# Need root user to run.
####
count=0
echo "Check the Cluster src state,please waiting..."
Cls_src_state=`lssrc -g cluster | awk '{if($2=="cluster"){print $4}}'| uniq`
Caa_src_state=`lssrc -s clcomd | awk '{if($2=="caa"){print $4}}'`
if [ $Caa_src_state = "active" ] && [ $Caa_src_state = "active" ]
then
    echo "The Cluster and caa src state all active!"
	count=$(($count + 1))
else
    echo "ERROR!Someone Cluster src state is abnormal,please check!"
fi
####
Cls_dir="/usr/es/sbin/cluster/utilities"
Cls_State=$($Cls_dir/cldump |sed -n '/Cluster State/p' |awk '{print $3}')
Cls_Substate=`$Cls_dir/cldump |sed -n '/Cluster Substate/p' |awk '{print $3}'`
echo "Check the Cluster state,please waiting..."
if [ $Cls_State = "UP" ] 
then
    echo "The Cluster state is UP!"
	count=$(($count + 1))
else
    echo "ERROR! The Cluster state is $Cls_State,please check!"
fi
####
echo "Check the Cluster Substate,please waiting..."
if [ $Cls_Substate = "STABLE" ]
then
    echo "The Cluster Substate is STABLE!"
	count=$(($count + 1))
else
    echo "ERROR! The Cluster Substate is $Cls_State,please check!"
fi
####
echo "Check the Nodes state,please waiting..."
Node_State=`$Cls_dir/cldump |sed -n '/Node Name/p'| awk '{print $5}'`
Node_qty=`$Cls_dir/clmgr list node |wc -l`
for state in $Node_State
do 
    if [ $state != "UP" ]
    then 
        echo "ERROR! Someone node state is abnormal,please check!"
    else
		echo "The node state is UP!"
		count=$(($count + 1))
    fi
done
####
IP_Label_list=$($Cls_dir/cltopinfo -i |sed -n '/ether/p'|sort |awk '{print $1}' |uniq)
IP_Labe1_num=$($Cls_dir/cltopinfo -i |sed -n '/ether/p'|sort |awk '{print $1}' |uniq |sed -n '=')
IP_Labe1_qty=`$Cls_dir/cltopinfo -i |sed -n '/ether/p'|sort |awk '{print $1}' |uniq |wc -l`
####
echo "Check the /etc/hosts,please waiting..."
for i in $IP_Labe1_num
do
    IP_Label=`echo $IP_Label_list |awk '{print $'$i'}'`
    Address=`echo $Add_list |awk '{print $'$i'}'`
    x=`cat /etc/hosts | sed -n '/'$IP_Label'/p'`
    y=`cat /etc/hosts | sed -n '/'$Address'/p'`
    if [ "$x" != "$y" ]
    then 
        echo "ERROR!$IP_Labe1 found the error in /etc/hosts,please check!"
	else
		count=$(($count + 1))
    fi
done
####
HA_version=`lslpp -l |grep cluster.es.server.rte | uniq |awk '{print $2}'`
HA_jud=$(echo $HA_version | sed -n '/^7/p')
Add_list=$($Cls_dir/cltopinfo -i |sed -n '/ether/p'|sort |awk '{print $5}' |uniq)
Add_list_qty=`$Cls_dir/cltopinfo -i |sed -n '/ether/p'|sort |awk '{print $5}' |uniq |wc -l`
Node_list=`$Cls_dir/cltopinfo -i |sed -n '/ether/p'|sort |awk '{if($1==$4){print $1}}'`
Node_list_qty=`$Cls_dir/cltopinfo -i |sed -n '/ether/p'|sort |awk '{if($1==$4){print $1}}' |wc -l`
rhosts_dir="/usr/es/sbin/cluster/etc"
####
echo "Check the rhosts,please waiting..."
if [ -n $HA_jud  ]
then
    echo "The HA version is $HA_version!"
    for node in $node_list
    do
        vaule1=`cat /etc/cluster/rhosts |sed -n '/'$node'/p'`
        if [ -z $vaule1 ]
        then 
            echo "ERROR!Someone Boot IP Label not in rhosts,Please check!"
		else
			count=$(($count + 1))
        fi
    done
else
    echo "The HA version is $HA_version!"
    for IP_Add in $Add_list
    do
        vaule2=`cat $rhosts_dir/rhosts |sed -n '/'$IP_Add'/p'`
        if [ -z $vaule2 ]
        then 
            echo "WARRING!Someone IP not in rhosts,Please check!"
		else
			count=$(($count + 1))
        fi
    done
fi
###
echo "Check the netmon.cf,please waiting..."
netmon=`cat /usr/es/sbin/cluster/netmon.cf`
netmon_ck=`cat /usr/es/sbin/cluster/netmon.cf |sed -n '/[[:alnum:]]/p'`
if	[ $? -ne 0 ] || [ -z "$netmon_ck" ]
then
	echo "WARRING!File 'netmon.cf' is missing or empty!"
	echo "If the system running in PowerVM environment,please configure the netmon.cf!"
fi
###
count1=$((3 + $Node_qty + $IP_Labe1_qty + $Add_list_qty + $Node_list_qty ))
if [ $count -eq $count1 ]
then
    read answer?"Need to synchronize the Cluster?[Y/N] " 
    case $answer in
    Y | y)  echo
            echo "OK,Synchronize the Cluster now,please waiting..." ;;
    N | n)  echo
            echo "OK,Please synchronize manually if necessary!"
            exit ;;
    esac
    $Cls_dir/clmgr sync cluster
    if [ $? -eq 0 ]
    then
        echo "Synchronize the Cluster successful!"
    else
        echo "Synchronize the Cluster failed!"
        echo "Please check the PowerHA log:/var/hacmp/log/hacmp.out"
    fi
else 
    echo "Cluster Configuration check completed but found some errors,please check!"
fi
