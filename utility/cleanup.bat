REM =================================

rd /s /q C:\DEL
rd /s /q D:\DEL

REM =================================

cd /d %temp%

pushd %systemdrive%\recycler	& takeown /f . /r & rd /s /q . & popd 
pushd %temp%			& takeown /f . /r & rd /s /q . & popd
pushd %windir%\temp		& takeown /f . /r & rd /s /q . & popd
pushd c:\$Recycle.bin		& takeown /f . /r & rd /s /q . & popd 
pushd d:\$Recycle.bin		& takeown /f . /r & rd /s /q . & popd 
pushd d:\temp			& takeown /f . /r & rd /s /q . & popd 

REM =================================

REM run below first
REM cleanmgr /sageset:99
cleanmgr /sagerun:99

REM =================================

goto :EOF

REM =================================

@echo off
echo Make Sure Dropbox is not in c:
echo Cleaning . . .
pause

pushd %windir%\temp 	  			& takeown /f . /r & rd /s /q . & popd
pushd %temp% 		  			& takeown /f . /r & rd /s /q . & popd
pushd %temp% & pushd %systemdrive%\recycler	& takeown /f . /r & rd /s /q . & popd & popd
pushd %temp% & pushd c:\$Recycle.bin		& takeown /f . /r & rd /s /q . & popd & popd
pushd %temp% & pushd d:\$Recycle.bin		& takeown /f . /r & rd /s /q . & popd & popd

del /f /s /q %systemdrive%\*.tmp
del /f /s /q %systemdrive%\*._mp
del /f /s /q %systemdrive%\*.gid
del /f /s /q %systemdrive%\*.chk
del /f /s /q %systemdrive%\*.old
del /f /s /q %systemdrive%\recycled\*.*
del /f /s /q %windir%\*.bak
del /f /s /q %windir%\prefetch\*.*
del /f /q %userprofile%\cookies\*.*
del /f /q %userprofile%\recent\*.*
del /f /s /q "%userprofile%\Local Settings\Temporary Internet Files\*.*"
del /f /s /q "%userprofile%\Local Settings\Temp\*.*"
del /f /s /q "%userprofile%\recent\*.*"
del /f /s /q "%USERPROFILE%\AppData\Local\Temp\*.*"

echo Clean Complete !!!
echo. & pause