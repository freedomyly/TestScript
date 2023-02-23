#! /bin/sh

# 脚本用来启动或停止CpuStress程序
# 它接收两个参数，分别是start或stop和CPU占用率


# 定义一个变量CPU_RATE 用来存储用户指定的CPU占用率
# 定义一个变量BIN_NAME 用来存储CpuStress的二进制文件名
CPU_RATE="$2"
BIN_NAME="CpuStress"


echo -e "\033[34m=============================================\033[0m"
echo -e "\033[34m _    __                             __      \033[0m"
echo -e "\033[34m| |  / /___ _____  _  ______  ____ _/ /__    \033[0m"
echo -e "\033[34m| | / / __ \// __ \| |/_/ __ \/ __ \/ //_/   \033[0m"
echo -e "\033[34m| |/ / /_/ / / / />  </ /_/ / /_/ / ,<       \033[0m"
echo -e "\033[34m|___/\__,_/_/ /_/_/|_|\____/\__,_/_/|_|      \033[0m"
echo -e "                              \033[31mwww.vanxoak.com\033[0m"
echo -e "\033[34m=============================================\033[0m"


# 定义一个函数start_CpuStress，用来根据CPU的线程数启动相应个数的CpuStress进程
# 这个函数首先使用grep命令从/proc/cpuinfo文件中获取当前机器上的CPU线程数，并赋值给变量cpu_count
# 然后使用for循环遍历每隔线程，并在后台执行CpuStress程序
# 最后打印Done！表示启动完成
killall CpuStress

function start_CpuStress()
{
    echo "校准时间："
    read -p "请输入当前北京时间，格式为 2022 02 20 22 22 22 " year month day hour minute second
    # 用date命令设置系统时间
    date -s "$year-$month-$day $hour:$minute:$second"
    # 用hwclock命令同步到硬件时钟
    hwclock --systohc
    echo -e "============================================="
    echo "当前开发板时间为："`date`
    sleep 1s
    
    cpu_count=$(grep -c "processor" /proc/cpuinfo)
    for ((i=0;i<${cpu_count};i++))
    do
      echo "请输入测试时长（秒），需比实际时长多120秒" 
      read Testtime
      ( ./CpuStress -r ${CPU_RATE} & )
      gst-launch-1.0 filesrc location=/home/video.mp4 ! qtdemux ! queue ! h264parse ! omxh264dec ! waylandsink
      echo -e "MPU压力测试程序正在运行中,预计运行\033[44;37;5m $Testtime 秒\033[0m以上......"
      start=$(date +%s)
      while true;do
        #显示CpuStress CPU占用率
        cpu_usage=$(top -bn 1 | grep CpuStress | awk '{print $7}' | awk 'NR==1')
        echo -ne "\033[32m$cpu_usage\r\033[0m""当前程序CpuStress的CPU占用率为:"
        echo -ne "$cpu_usage\r"
        # 等待 0.5 秒
        sleep 1s
        
        # 检查测试时间是否结束
        current=$(date +%s)
        elapsed=$((current - start))
        if [[ $elapsed -ge $Testtime ]]; then
            echo -e "\033[5m\033[43m 测试完成！！！！ \033[0m"
            echo -e ""
            echo -e "\033[47m\033[30m测试时长： ($((elapsed / 3600)) hours $(((elapsed % 3600) / 60)) minutes $((elapsed % 60)) seconds.)\033[0m"

            killall CpuStress
            break
        fi
      done  
    done
}




# while循环
# 判断参数是否大于0 ，如果不是就退出循环
while [ $# -gt 0 ]
do
    # 使用case语句根据第一个参数的值进行匹配
    ## 如果是start，就调用start_CpuStress函数并退出程序
    case "X$1" in
        Xstart)
            start_CpuStress
	    exit 1
            ;;
        ## 如果是stop就使用ps命令和grep命令找出所有运行中的CpuStress进程，
        ## 并使用awk命令和kill命令将他们终止，然后退出程序
        Xstop)
            ps | grep "${BIN_NAME}" | awk '{print "kill -KILL "$1}' |sh
	    exit 1
            ;;
        *)
            ## 如果是其他值，就打印错误信息和使用说明，并退出程序
            echo "Error : parameters error"
            echo "Usage : sh CpuStress.sh [start|stop]"
            exit 1
            ;;
    esac    

    shift 1
     
done


#总体而言，此脚本旨在通过运行重复执行浮点算术运算的循环来对 CPU 进行压力测试。以下是脚本关键组件的细分：


#该脚本定义一个名为“stress”的函数，该函数接受一个参数，即运行压力测试的秒数。在函数内部，它将变量“end_time”初始化为当前时间加上作为参数传递的秒数。此值用于确定何时停止压力测试。

#然后，脚本进入一个 while 循环，该循环一直运行到当前时间超过上一步中计算的“end_time”值。在循环中，它使用“bc”命令生成随机浮点数，并对其执行各种算术运算。

#“sleep”命令用于在循环迭代之间引入延迟。延迟值设置为 0.01 秒，这是一个相对较小的值，可确保循环尽可能快地迭代。

#最后，脚本调用值为 10 秒的“stress”函数，这意味着 CPU 将受到 10 秒的压力。

#总之，该脚本生成随机浮点数，并在指定的持续时间内在循环中对它们执行算术运算，从而有效地给 CPU 带来了沉重的负载。可以通过修改压力测试的长度或在循环中执行的操作来自定义脚本。



