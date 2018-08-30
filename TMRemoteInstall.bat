@echo off

rem =================================================================================================================================
rem =================================================================================================================================
rem ***Name: TMRemoteInstall.bat
rem ***Author: Me
rem ***Version: 1.0
rem ***Date: 08 December 2015
rem ***Information: This script will prompt for a computername, an administrators username and password. 
rem ***		    From there it will use these credentials to check the specified computer for an installation of
rem ***		    Trend Micro Office Scan. If Trend Micro Office Scan is installed, the script will notify the user
rem ***		    that it is installed, and ask if the user wants to check another computer, and go through the process again,
rem ***		    using the same username and password as before. If Trend Micro Office Scan is not installed, the script will
rem ***		    notify the user, and ask if the user wants to install Trend Micro Office Scan. If the user selects "Y",
rem ***		    Trend Micro Office Scan will be installed by use of psexec. Upon success or failure of the installation the
rem ***		    user is notified and can continue to check another computer or exit.
rem =================================================================================================================================
rem =================================================================================================================================

rem ***The script upon first run will begin first at the "start" code grouping
goto start

rem ***This is the restart code group, from here the user is asked if they want to check another computer.
rem ***If the user chooses "Y", they are propmpted for another computer name, otherwise the script will exit with a "N" response.
rem ***Other error checking is included if the user inputs something other than "Y" or "N"
:restart
choice /d N /t 030 /m "Do you want to check another computer?"
if %errorlevel%==1 goto nextcomp
if %errorlevel%==2 exit
if %errorlevel%==0 goto restart
if %errorlevel% geq 3 goto end

rem ***This is the "nextcomp" code group. If the user decides to check another computer this code is run to
rem ***check for the next computer name. If the user has already entered username and password, the same variable
rem ***values will be used.
:nextcomp
set /p comp="Computer name:"
if %user%=="" set /p user="Username:"
if %pass%=="" set /p pass="Password:"
goto check

rem ***This is the "start" code group. The script will begin here upon the inital run of the script. The user is prompted
rem ***for a computer name, a username and a password. These values are saved to the respective variables: comp, user, and pass.
rem ***After the variables are collected, the script will move onto the check code group.
:start
set /p comp="Computer name:"
set /p user="Username:"
set /p pass="Password:"

rem ***This is the "check" code group. Here, the script uses the variables collected in start and or restart code groups to
rem ***connect to the target computer. If the connection fails, the user is notified and prompted to try again. If the connection
rem ***completes successfully, the script checks if PccNT.exe is installed on the computer, thus checking if Trend Micro Office Scan
rem ***is installed. If it is installed the user is notified and prompted to check another computer. If it is not installed, the user is
rem ***prompted to choose to install Trend Micro Office Scan. If the user chooses to install, the script moves to the "install" code group.
:check
net use \\%comp%\C$ /user:ntd1\%user% %pass%
if %errorlevel%==2 (
echo The force is not strong with this one...Computer off network or something was mistyped...
pause
goto start
)
echo Checking if Trend Micro is installed on %comp%...
if exist "\\%comp%\C$\Program Files (x86)\Trend Micro\OfficeScan Client\PccNT.exe" (
echo Trend Micro is installed on this computer
pause
goto restart
)
if exist "\\%comp%\C$\Program Files\Trend Micro\OfficeScan Client\PccNT.exe" (
echo Trend Micro is installed on this computer
pause
goto restart
)
echo Trend Micro is not installed on this computer
choice /d N /t 030 /m "Do you want to install Trend Micro on this computer?"
if %errorlevel%==1 goto install
if %errorlevel%==2 goto restart
if %errorlevel%==0 goto restart
if %errorlevel% geq 3 goto end

rem ***This is the "end" code group. This will delete all recorded variables and exit the script.
:end
set comp=
set user=
set pass=
set ques=
exit

rem ***This is the "install" code group. This creates a connection to the network location that
rem ***the TM Installer script is located. It then copies the installer script to the target computer.
rem ***From there it uses psexec to silently run the TM Installer script from the local drive on the
rem ***target computer. It returns a success or failure to the user running the script. Afterwards
rem ***the file copied and the connections created are deleted and terminated respectively.
rem ***it then goes to the "restart" code group to ask if the user wants to check another computer.
:install
net use x: \\tmosce\agentinstallers\script
robocopy x: \\%comp%\C$ TrendMicroRollout.exe
psexec.exe \\%comp% -u ntd1\%user% -p %pass% -s \\%comp%\C$\TrendMicroRollout.exe
if %errorlevel%==0 (
echo Install succeeded, check logs for verficiation.
pause
)
if %errorlevel% geq 1 (
echo Install failed, check syslogs for errors...
pause
)
echo Cleaning up after ourselves! Deleting copied files...
del \\%comp%\C$\TrendMicroRollout.exe
pause
net use \\%comp%\C$ /delete
net use x: /delete
pause
goto restart
