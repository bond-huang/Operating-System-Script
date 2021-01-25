#!/usr/bin/python3
#修改hdisk的PVID,只能修改未使用磁盘，脚本中加入了校验方法
#脚本中对输入的16进制的PVID也有校验，不符合条件不会被写入
#需使用root用户执行
import os
import re
import time
class ChangePVID():
    #校验输入的hdisk名称是否可以修改
    def __input_disk(self):
        hdisk = input('Please input hdisk name:')
        getdsklst_cmd = 'lspv | awk \'{if($3==\"None\"){print $1}}\''
        disk_list = os.popen(getdsklst_cmd)
        disk_list = disk_list.read()
        if hdisk in disk_list:
            print('The ' + hdisk +' can change!')
            return hdisk
        else:
            print('The '+ hdisk + ' cannot change PVID,please enter another!')
            quit()
    #校验输入的PVID是否可用，并且格式化输入的PVID
    def __input_pvid(self):
        new_PVID = input('Please enter new PVID:')
        if len(new_PVID) == 16 and re.findall('\A[0-9a-fA-F]+\Z',new_PVID):
            hex_ids = re.findall('[0-9a-fA-F]{2}',new_PVID)
            oct_ids = [];ids_list = [];new_id = '\\'
            for i in range(0,len(hex_ids)):
                oct_id = oct(eval('0x'+hex_ids[i]))
                oct_ids.append(oct_id)
            for j in range(0,len(oct_ids)):
                if re.findall('[0-9a-fA-F]{2,}',oct_ids[j]) == []:
                    ids = ['00']
                else:
                    ids = re.findall('[0-9a-fA-F]{2,}',oct_ids[j])
                id_str = str(ids[0]).zfill(4)
                ids_list.append(id_str)
            for k in range(0,len(ids_list)):
                new_id = new_id + ids_list[k] +'\\'
            new_id = new_id + 'c'
            return new_id
        else:
            print('The enter '+ new_PVID + ' format is incorrect,please try again!')
            quit()
    #修改PVID并且显示新的PVID
    def __change_pvid(self,hdisk,new_id):
        cmd1 = 'echo '+'"'+new_id+'"'+' > /tmp/myPVID'
        cmd2 = 'cat /tmp/myPVID | dd of=/dev/'+hdisk+' bs=1 seek=128'
        cmd3 = 'rmdev -dl '+hdisk
        cmd4 = 'lspv |grep '+hdisk
        os.popen(cmd1);os.popen(cmd2);os.popen(cmd3)
        os.popen('cfgmgr')
        print('Please wait 30 seconds!')
        time.sleep(30)
        print('Please check the pvid of '+hdisk+':')
        lspv = os.popen(cmd4)
        print(lspv.read())
    def go_change_pvid(self):
        hdisk = self.__input_disk()
        new_id = self.__input_pvid()
        self.__change_pvid(hdisk,new_id)
changepvid = ChangePVID()
changepvid.go_change_pvid()
