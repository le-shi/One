#!/bin/sh
#在当前运行的应用中找到名为WeChat.exe的应用程序，并向它发送按键事件"ctrl+alt+W"
#WeChat的可执行文件名为WeChat.exe，如果是其它应用程序就修改成其它应用程序的可执行文件名, 应用名称大小写敏感, 一个字母都不能错!
xdotool key --window $(xdotool search --limit 1 --all --pid $(pgrep WeChat.exe)) "ctrl+alt+W"
