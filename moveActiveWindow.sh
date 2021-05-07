#!/bin/bash
cmd=`basename "$0"`
function usage(){
    echo "usage:"
    echo "   ${cmd} -l|--left"
    echo "   把当前窗口移动到左侧显示器"
    echo "" 
    echo "   ${cmd} -r|--right"
    echo "   把当前窗口移动到右侧显示器"
}

## 解析脚本参数
ARGS=`getopt -q -o lr -l left,right -n "${cmd}" -- "$@"`
eval set -- "${ARGS}"

par_l=0 	#left
par_r=0 	#right
while [ -n "$1" ];do
    case "$1" in
        -l|--left)
            par_l=1
            shift
            ;;
        -r|--right) 
            par_r=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

# 必须传入一个合法参数
temp=0
((temp=$par_l + $par_r))
if [[ $temp != 1 ]];then
    usage
    exit 1
fi

# 获取当前窗口信息
WID=`xdotool getactivewindow`

# 获取当前窗口信息
info=`xwininfo -tree -stats -id ${WID}`
ax=`echo "$info" | grep "Absolute upper-left X:" | grep -P -o "\d+"`
ay=`echo "$info" | grep "Absolute upper-left Y:" | grep -P -o "\d+"`
rx=`echo "$info" | grep "Relative upper-left X:" | grep -P -o "\d+"`
ry=`echo "$info" | grep "Relative upper-left Y:" | grep -P -o "\d+"`
width=`echo "$info" | grep "Width:" | grep -P -o "\d+"`
height=`echo "$info" | grep "Height:" | grep -P -o "\d+"`

# 根据传入的参数调整窗口的x坐标
if [ ${par_l} == 1 ];then
    if (( ${ax} >= 1440 ));then
        ((ax=${ax} - 1440))
    fi
elif [ ${par_r} == 1 ];then
    if (( ${ax} < 1440 ));then
        ((ax=${ax} + 1440))
    fi
fi

# 是否全屏
isFullScreen=`xprop -id ${WID} | grep -P "^_NET_WM_STATE" | grep -Po "_NET_WM_STATE_FULLSCREEN"`
# 是否横向最大化
isMaxHorz=`xprop -id ${WID} | grep -P "^_NET_WM_STATE" | grep -Po "_NET_WM_STATE_MAXIMIZED_HORZ"`
# 是否纵向最大化
isMaxVert=`xprop -id ${WID} | grep -P "^_NET_WM_STATE" | grep -Po "_NET_WM_STATE_MAXIMIZED_VERT"`

# 根据窗口状态移动窗口
if [ ${isFullScreen} != "" ];then
    wmctrl -ir $WID -b toggle,fullscreen
    wmctrl -i -r $WID -e 0,${ax},${ay},800,600
    wmctrl -ir $WID -b toggle,fullscreen
elif [ ${isMaxHorz} != "" ] && [ ${isMaxVert} != "" ];then
    wmctrl -ir $WID -b remove,maximized_horz,maximized_vert
    ((ax=${ax} + 4))
    xdotool getactivewindow windowmove ${ax} ${ay}
    wmctrl -ir $WID -b add,maximized_horz,maximized_vert
elif [ ${isMaxHorz} != "" ];then
    wmctrl -ir $WID -b toggle,maximized_horz
    xdotool getactivewindow windowmove ${ax} ${ay}
    wmctrl -ir $WID -b toggle,maximized_horz
elif [ ${isMaxVert} != "" ];then
    wmctrl -ir $WID -b toggle,maximized_vert
    xdotool getactivewindow windowmove ${ax} ${ay}
    wmctrl -ir $WID -b toggle,maximized_vert
else
    # 修正偏移
    PID=`xdotool getactivewindow getwindowpid`
    binName=`readlink -f /proc/$PID/exe | xargs basename`
    case ${binName} in
        "nvim-qt" )
            ;;
        * )
            ((ax=${ax} - ${rx}))
            ((ay=${ay} - ${ry}))
            ;;
    esac
    #xdotool getactivewindow windowmove ${ax} ${ay}
    wmctrl -r ":ACTIVE:" -e 0,${ax},${ay},${width},${height}
fi
