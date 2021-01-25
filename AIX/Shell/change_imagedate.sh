#!/bin/ksh
# Change the image.data!
# Need root user to change!
# The function is not to backup mirror information when doing mksysb！
echo "Great a new image.data,please wait..."
mkszfile
sleep 15
cd /
# Change the LV_SOURCE_DISK_LIST!
echo "Change the LV_SOURCE_DISK_LIST..."
hdisk_list=$(lspv | awk '{if($3=="rootvg"){print $1}}')
for disk in $hdisk_list
do
    lv_count1=`lsvg -l rootvg | wc -l`
    lv_count2=`lspv -l $disk | wc -l`
    if [ $lv_count2 -eq $lv_count1 ]
    then
        hdisk=$disk
    fi
done
sed '
s/LV_SOURCE_DISK_LIST=.*/LV_SOURCE_DISK_LIST= '$hdisk'/
' image.data > image.data.img
mv image.data.img image.data
# Change the COPIES!
echo "Change the COPIES..."
sed 's/COPIES= [0-9]*/COPIES= 1/' image.data > image.data.img
mv image.data.img image.data
# Change the PPs!
echo "Change the PPs..."
sequence=`sed -n '/LPs=/p' image.data|sed -n '/LPs=/='`
LPs_vaule=`cat image.data|awk '/LPs=/{print $2}'`
PP_rows=$(sed -n '/PP=/=' image.data)
for i in $sequence
do
    PP_row=`echo $PP_rows | awk '{print $'$i'}'`
    PP=`echo $LPs_vaule | awk '{print $'$i'}'`
    sed ''$PP_row'{
    s/PP= [0-9]*/PP= '$PP'/
    }' image.data > image.data.img
    mv image.data.img image.data
done
echo "Changes are complete!"
echo "Please use command to do mksysb without '-i' parameter!"
echo "Or use 'smit mksysb' set 'Generate new /image.data file?' to 'No'!"
