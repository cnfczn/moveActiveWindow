# 概述
xfce没有在显示器之间移动窗口的命令，所以写了一个SHELL脚本。
* 支持在2个显示器之间左右移动窗口
* 支持移动全屏的窗口

**需要安装xdotool和wmctl命令**

# BUG和缺点
* 移动全屏程序后，原窗口尺寸没有保留
* 我家使用1440x900的显示器尺寸，所以在脚本中固定了尺寸
* 不支持2个以上显示器
* 两个显示器尺寸如果不一样，效果也不理想
* 频繁使用命令存在失效的可能

功能实现还是朝着windows自带的移动窗口热键去实现的，但是想法很美好，实现起来有些差距。

暂时功能够用了，所以如果谁有想法，可以fork下自己改，也希望能有更好的脚本诞生。

今天在网上看到有类似功能的实现，功能更好，而且支持多个显示器和循环切换。

[movescreen](https://github.com/calandoa/movescreen) 使用python实现，有兴趣的朋友可以去看看这个。

我试用了下，可能家里电脑不太好，功能响应速度比我这个脚本略慢一点。
