#!/bin/ksh
# Two nodes PowerHA resource group switch script.
# Need root user to run.
Cls_dir="/usr/es/sbin/cluster/utilities"
Cls_State=`$Cls_dir/cldump |sed -n '/Cluster State/p' |awk '{print $3}'`
Cls_Substate=`$Cls_dir/cldump |sed -n '/Cluster Substate/p' |awk '{print $3}'`
echo "Check the Cluster state,please waiting..."
if [ $Cls_State = "UP" ] && [ $Cls_Substate = "STABLE" ]
then
    echo "The Cluster state is STABLE!"
else
    echo "The Cluster state is abnormal,please check the cluster!"
    exit 1
fi
#### 
echo "Check the Nodes state,please waiting..."
Node_State=$($Cls_dir/cldump |sed -n '/Node name/p'| awk '{print $5}')
for state in $Node_State
do 
    if [ $state != "UP" ]
    then 
        echo "Someone node state is abnormal,please check the cluster!"
        exit 1
    fi
done
####
RG=$($Cls_dir/clmgr list rg)
RG_Node=`$Cls_dir/cldump |tail -2 |awk '{if($2=="ONLINE"){print $1}}'`
Standy_Node=`$Cls_dir/cldump |tail -2 |awk '{if($2=="OFFLINE"){print $1}}'`
####
if [ -n $RG_Node  ] && [ -n $Standy_Node ]
then
    echo "Move the resource group form $RG_Node to $Standy_Node,please waiting..."
    $Cls_dir/clRGmove -s 'false' -m -i -g $RG -n $Standy_Node
else
    echo "RG state is abnormal on someone node,please check the cluster!"
    exit 1
fi
####
if [ $? -eq 0 ]
then 
    echo "Successfully moved the resource group form $RG_Node to $Standy_Node!"
    echo "Please check the Cluster status and check the application!"
else
    echo "Failed to move the resource group form $RG_Node to $Standy_Node!"
    echo "Please check the PowerHA log:/var/hacmp/log/hacmp.out!"
fi
