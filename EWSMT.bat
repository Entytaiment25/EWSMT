:: Hide Command and Set Scope
@echo off
setlocal EnableExtensions

set isadmin=0
whoami /all | findstr /c:" S-1-16-12288 ">nul && set isadmin=1

:: Customize Window
title "EWSMT"

:: Menu Options
:: Specify as many as you want, but they must be sequential from 1 with no gaps
:: Step 1. List the Application Names
set "App[1]=Stop http (frees port 80)"
set "App[2]=Open FxServer Ports (in/out)"
set "App[3]=Close FxServer Ports (in/out)"
set "App[4]=Taskkill FxServer Instance"
set "App[5]=Exit"
rem set "App[6]=Exit"

:: Display the Menu
set "Message="
:Menu
cls
color 04
echo.%Message%
echo.
echo.  Enty`s Windows Server Managment Tool
echo.  Version: 1.2.1
echo.
set "x=0"
:MenuLoop
set /a "x+=1"
if defined App[%x%] (
    call echo   %x%. %%App[%x%]%%
    goto MenuLoop
)
echo.

:: Prompt User for Choice
:Prompt
set "Input="
set /p "Input=Select what app: "

:: Validate Input [Remove Special Characters]
if not defined Input goto Prompt
set "Input=%Input:"=%"
set "Input=%Input:^=%"
set "Input=%Input:<=%"
set "Input=%Input:>=%"
set "Input=%Input:&=%"
set "Input=%Input:|=%"
set "Input=%Input:(=%"
set "Input=%Input:)=%"
:: Equals are not allowed in variable names
set "Input=%Input:^==%"
call :Validate %Input%

:: Process Input
call :Process %Input%
goto End

:Validate
set "Next=%2"
if not defined App[%1] (
    set "Message=Invalid Input: %1"
    goto Menu
)
if defined Next shift & goto Validate
goto :eof

:Process
set "Next=%2"
call set "App=%%App[%1]%%"

:: Run Installations
:: Specify all of the installations for each app.
:: Step 2. Match on the application names and perform the installation for each
if "%App%" EQU "Stop http (open port 80)" net stop http
if "%App%" EQU "Open FxServer Ports (in/out)" (
    netstat -na | findstr "30120">NUL
    if "%ERRORLEVEL%"=="1" (
        netsh advfirewall firewall add rule name="FxServer" dir=in action=allow protocol=TCP localport=30120
        netsh advfirewall firewall add rule name="FxServer" dir=out action=allow protocol=TCP localport=30120
        netsh advfirewall firewall add rule name="FxServer" dir=in action=allow protocol=UDP localport=30120
        netsh advfirewall firewall add rule name="FxServer" dir=out action=allow protocol=UDP localport=30120
        echo Port 30120 is now open.
    ) else echo Port 30120 is already open.
)
if "%App%" EQU "Taskkill FxServer Instance" (
    tasklist /fi "ImageName eq FXServer.exe" /fo csv 2>NUL | find /I "FXServer.exe">NUL
    if "%ERRORLEVEL%"=="0" (
        echo Program is running
        taskkill /IM FXServer.exe /F
    ) else echo there is no FxServer Instance running.
)
if "%App%" EQU "Close FxServer Ports (in/out)" (
    netstat -na | findstr "30120">NUL
    if "%ERRORLEVEL%"=="1" (
        netsh advfirewall firewall delete rule name="FxServer" dir=in action=allow protocol=TCP localport=30120
        netsh advfirewall firewall delete rule name="FxServer" dir=out action=allow protocol=TCP localport=30120
        netsh advfirewall firewall delete rule name="FxServer" dir=in action=allow protocol=UDP localport=30120
        netsh advfirewall firewall delete rule name="FxServer" dir=out action=allow protocol=UDP localport=30120
        echo Port 30120 is now closed.
    ) else echo Port 30120 is not open.
)
if "%App%" EQU "Five" echo Run Install for App Five here
if "%App%" EQU "Exit" Exit

:: Prevent the command from being processed twice if listed twice.
set "App[%1]="
if defined Next shift & goto Process
goto :eof

:End
endlocal
pause >nul
