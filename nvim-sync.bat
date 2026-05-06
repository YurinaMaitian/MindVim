@echo off
chcp 65001 >nul  :: 支持中文
cd /d C:\Users\19241\AppData\Local\nvim

echo.
echo ===== Neovim 配置同步 =====
echo.

:: 显示状态
git status --short
echo.

:: 询问提交信息
set /p msg="输入本次修改描述（直接回车则使用默认）: "

if "%msg%"=="" (
    set msg=update: %date% %time%
)

:: 执行提交
git add .
git commit -m "%msg%"
git push origin master

echo.
echo 已推送到 GitHub！
pause