@echo off

rem =================================================================================================================================
rem =================================================================================================================================
rem ***Name: PasswordSelfServiceUninstall.bat
rem ***Author: Me
rem ***Version: 1.0
rem ***Date: 02/03/2016
rem ***Information: This script will loop through all computer objects on the domain. It will check
rem 		    to see if the old Desktop Authority Password Self Service software is installed,
rem		    and if it is, it will uninstall according to the appropriate OS archetecture for the
rem		    target computer. If the software is not installed, it will list that it doesn't
rem		    exist and will loop to the next object. The uninstallation is silent and does not
rem		    require a reboot.
rem =================================================================================================================================
rem =================================================================================================================================

rem ***
rem ***In this start code group, the user is prompted with a choice of checking one computer or all computers on the domain,
rem ***if the user selects 1 or Y, the checkone group is called, if the user selects 2 or N, the checkall group is called.
rem ***

:start
choice /d 1 /n /c "YN12" /t 030 /m "Press 1 to check one computer, press 2 to check all domain."
if %errorlevel%==1 goto checkone
if %errorlevel%==2 goto checkall

rem ***
rem ***In this checkone code group, the user is prompted for a computer name and the single computer is checked to see if 
rem ***the Desktop Authority Self Service is installed. If it is, the computer is checked for 32 bit or 64 bit OS architecture.
rem ***From there, the appropriate msi is copied from the server to the computer and then run silently, without a reboot.
:checkone
echo Ready to check one!
set /p comp="Computer name:"
if exist "\\%comp%\C$\Windows\System32\SPEnroll.exe" (
	echo It exists...		
	robocopy C:\SelfService \\%comp%\C$\Temp "Desktop Authority Secure Password Extension x86.msi"
	start /wait psexec \\%comp% -s msiexec /x "\\%comp%\C$\Temp\Desktop Authority Secure Password Extension x86.msi" /qn /norestart
	del "\\%comp%\C$\Temp\Desktop Authority Secure Password Extension x86.msi"
) else (
echo It does not exist...
)
pause
choice /d N /t 030 /m "Do you want to check another computer?"
if %errorlevel%==1 goto checkone
if %errorlevel%==2 exit
if %errorlevel%==0 goto start
if %errorlevel% geq 3 goto end


:checkall
echo Ready to check all!
pause
rem ***This is the for loop, it will loop through *all* computers in the CBN.Local Forest
for /f "delims=" %%a in ('DSQUERY COMPUTER forestroot -o rdn -limit 0') do (
	call :checkallprocess %%a
)
goto :checkallend

:checkallprocess
set comp=%1
rem     ***Remove quotes surrounding computer name***
for /f "useback tokens=*" %%a in ('%comp%') do set comp=%%~a
rem     ***Here the code checks to see if the Self Service software is installed***
if exist "\\%comp%\C$\Windows\System32\SPEnroll.exe" (
	echo '%comp%' It exists...
	robocopy C:\SelfService \\%comp%\C$\Temp "Desktop Authority Secure Password Extension x86.msi"
	start /wait psexec \\%comp% -s msiexec /x "\\%comp%\C$\Temp\Desktop Authority Secure Password Extension x86.msi" /qn /norestart
	del "\\%comp%\C$\Temp\Desktop Authority Secure Password Extension x86.msi"
) else (
	echo '%comp%' It does not exist...
)
goto :end

:checkallend
pause
choice /d N /t 030 /m "Do you want to check another computer?"
if %errorlevel%==1 goto checkone
if %errorlevel%==2 exit
if %errorlevel%==0 goto start
if %errorlevel% geq 3 goto end

:end
