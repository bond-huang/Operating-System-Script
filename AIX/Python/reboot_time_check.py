#!/usr/bin/python3
#读取bos.rte安装时间和系统重启时间，判断在升级后系统是否重启过
#需要使用root用户才能运行
import os
import time
class CheckReboot():
    upgrade_time_cmd = 'lslpp -h bos.rte|awk \'{print \"\"$4,$5\"\"}\'|tail -1'
    reboot_time_cmd = 'alog -t boot -o|grep date|awk \'{print \"\"$7,$8,$9,$10,$11,$12\"\"}\'|tail -1'
    #命令输出时间格式为：03/21/19 11:32:57，定义方法转化时间
    def __get_upgrade_time(self):
        upgrade_time = os.popen(CheckReboot.upgrade_time_cmd)
        upgrade_time = upgrade_time.read(17)
        upgrade_time = time.strptime(upgrade_time,'%m/%d/%y %H:%M:%S')
        upgrade_time = time.mktime(upgrade_time)
        print('The latest upgrade time is:'+ time.ctime(upgrade_time))
        return upgrade_time
    #命令输出时间格式为：Fri Jul 19 09:08:38 UTC 2019，定义方法转化时间
    def __get_reboot_time(self):
        reboot_time = os.popen(CheckReboot.reboot_time_cmd)
        reboot_time = reboot_time.read(28)
        reboot_time = reboot_time.strip()
        reboot_time = time.strptime(reboot_time,'%a %b %d %H:%M:%S %Z %Y')
        reboot_time = time.mktime(reboot_time)
        reboot_time = reboot_time + 28800
        print('The latest reboot time is:' + time.ctime(reboot_time))
        return reboot_time
    #定义方法进行判断
    def __determine(self,upgrade_time,reboot_time):
        if upgrade_time < reboot_time:
            print('The system has been restart after upgrade!')
        else:
            print('The system did not restart after upgrade!')
    def go_check(self):
        upgrade_time = self.__get_upgrade_time()
        reboot_time = self.__get_reboot_time()
        self.__determine(upgrade_time,reboot_time)
checkreboot = CheckReboot()
checkreboot.go_check()
