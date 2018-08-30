@echo off
echo Please Wait while the system is uninstalling Microsoft's SMS/SCCM Client.

echo Checking for SCCM 2007 client...
IF EXIST %windir%\System32\ccmsetup\ccmsetup.exe GOTO DEL07
echo No SCCM 2007 client found.

echo Checking for SCCM 2012 client...
IF EXIST %windir%\ccmsetup\ccmsetup.exe GOTO DEL12
echo No SCCM 2012 client found.

echo Checking for SMSCFG file...
IF EXIST %windir%\SMSCFG.INI GOTO DELINI
echo No SMSCFG file found.
echo All software already removed or no client installed.

GOTO END

:DEL07
echo Found SCCM Client v2007. Removing...
%windir%\System32\ccmsetup\ccmsetup.exe /uninstall
RD /S /Q %windir%\System32\ccmsetup
RD /S /Q %windir%\System32\ccm
RD /S /Q %windir%\System32\ccmcache
echo SCCM Client 2007 removed.
IF EXIST %windir%\ccmsetup\ccmsetup.exe GOTO DEL12
IF EXIST %windir%\SMSCFG.INI GOTO DELINI
GOTO END

:DEL12
echo Found SCCM client v2012. Removing.
%windir%\ccmsetup\ccmsetup.exe /uninstall
RD /S /Q %windir%\ccmsetup
RD /S /Q %windir%\ccm
RD /S /Q %windir%\ccmcache
echo SCCM Client 2012 removed.
IF EXIST %windir%\SMSCFG.INI GOTO DELINI
GOTO END

:DELINI
echo SMSCFG file found. Removing...
del /F %windir%\SMSCFG.INI
echo SMSCFG file removed.
GOTO END

:END
echo Done!
rem pause
rem I always put a pause for testing. derem and you can see the text fly by.
exit
