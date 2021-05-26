@echo off

:version_chk

SET USER_VER=1.0

SET GITHUB_VERSION_CHK_URL=https://github.com/KSanders7070/vSTARS_MSAW_CREATOR/blob/main/Version_Check

SET BATCH_FILE_RELEASES_URL=https://github.com/KSanders7070/vSTARS_MSAW_CREATOR/releases

TITLE vSTARS MSAW CREATOR v%USER_VER%

ECHO.
ECHO.
ECHO * * * * * * * * * * * * *
ECHO  CHECKING FOR UPDATES...
ECHO * * * * * * * * * * * * *
ECHO.
ECHO.

CD "%temp%"
IF Not Exist TempBatWillDelete.bat goto MK_TEMP_FOLDER
	DEL /Q TempBatWillDelete.bat >NUL

:MK_TEMP_FOLDER

If Not Exist "%temp%\VersionCheckWillDelete\" MD "%temp%\VersionCheckWillDelete"

cd "%temp%\VersionCheckWillDelete"

powershell -Command "Invoke-WebRequest %GITHUB_VERSION_CHK_URL% -OutFile 'version_check.HTML'"

For /F "Tokens=3 Delims=><" %%G In ('%__AppDir__%findstr.exe ">VERSION-" "version_check.html"') Do For /F "Tokens=1* Delims=-" %%H In ("%%G") Do Set "GH_VER=%%I"

If "%USER_VER%" == "%GH_VER%" GOTO RMDIR

:UPDATE_AVAIL

CLS

cd "%temp%"
rd /s /q "%temp%\VersionCheckWillDelete\"

ECHO.
ECHO.
ECHO * * * * * * * * * * * * *
ECHO     UPDATE AVAILABLE
ECHO * * * * * * * * * * * * *
ECHO.
ECHO.
ECHO GITHUB VERSION: %GH_VER%
ECHO YOUR VERSION:   %USER_VER%
ECHO.
ECHO.
ECHO.
ECHO  CHOICES:
ECHO.
ECHO     A   -   AUTOMATICALLY UPDATE THE BATCH FILE YOU ARE USING NOW.
ECHO.
ECHO     M   -   MANUALLY DOWNLOAD THE NEWEST BATCH FILE UPDATE AND USE THAT FILE.
ECHO.
ECHO     C   -   CONTINUE USING THIS FILE.
ECHO.
ECHO.
ECHO.
ECHO NOTE: IF YOU HAVE ATTMEPTED TO AUTOATMICALLY UPDATE ALREADY AND YOU CONTINUE
ECHO       TO GET THIS UPDATE SCREEN, PLEASE UTILIZE THE MANUAL UPDATE OPTION.
ECHO.
ECHO.
ECHO.

:UPDATE_CHOICE

SET UPDATE_CHOICE=UPDATE_METHOD_NOT_SELECTED

	SET /p UPDATE_CHOICE=Please type either A, M, or C and press Enter: 
		if /I %UPDATE_CHOICE%==A GOTO AUTO_UPDATE
		if /I %UPDATE_CHOICE%==M GOTO MANUAL_UPDATE
		if /I %UPDATE_CHOICE%==C GOTO CONTINUE
		if /I %UPDATE_CHOICE%==UPDATE_METHOD_NOT_SELECTED GOTO UPDATE_CHOICE
			echo.
			echo.
			echo.
			echo.
			echo  %UPDATE_CHOICE% IS NOT A RECOGNIZED RESPONSE. Try again.
			echo.
			GOTO UPDATE_CHOICE

:AUTO_UPDATE

CLS

ECHO.
ECHO.
ECHO * * * * * * * * * * * * * * * * * * * * * * * * * * *
ECHO.
ECHO   PRESS ANY KEY TO START THE AUTOMATIC UPDATE.
ECHO.
ECHO.
ECHO   THIS SCREEN WILL CLOSE.
ECHO.
ECHO   WAIT 5 SECONDS
ECHO.
ECHO   THE NEW UPDATED BATCH FILE WILL START BY ITSELF.
ECHO.
ECHO * * * * * * * * * * * * * * * * * * * * * * * * * * *
ECHO.
ECHO.

PAUSE

CD "%temp%"

ECHO @ECHO OFF >> TempBatWillDelete.bat
ECHO TIMEOUT 5 >> TempBatWillDelete.bat
ECHO CD "%~dp0" >> TempBatWillDelete.bat
ECHO START %~nx0 >> TempBatWillDelete.bat
ECHO EXIT >> TempBatWillDelete.bat

START /MIN TempBatWillDelete.bat

CD "%~dp0"

powershell -Command "Invoke-WebRequest %BATCH_FILE_RELEASES_URL%/download/v%GH_VER%/%~nx0 -OutFile '%~nx0'"

EXIT /b

:MANUAL_UPDATE

CLS

START "" "%BATCH_FILE_RELEASES_URL%"

ECHO.
ECHO.
ECHO GO TO THE FOLLOWING WEBSITE, DOWNLOAD AND USE THE LATEST VERSION OF %~nx0
ECHO.
ECHO.
ECHO    %BATCH_FILE_RELEASES_URL%
ECHO.
ECHO.
ECHO.
ECHO.
ECHO NOTE: PRESSING ANY KEY NOW WILL QUIT THIS VERSION OF THE BATCH FILE.
ECHO.
ECHO.

PAUSE

EXIT /b

:RMDIR

CLS

cd "%temp%"
rd /s /q "%temp%\VersionCheckWillDelete\"

:CONTINUE

:HELLO

CLS

CD "%temp%"

if exist MSAW_BATCH_TEMP RD /Q /S MSAW_BATCH_TEMP
MD MSAW_BATCH_TEMP

CD "%temp%\MSAW_BATCH_TEMP"

ECHO.
ECHO.
ECHO  THIS BATCH FILE WILL CREATE A .xml FILE
ECHO  BY USING THE MYFSIM.COM MSAW_CREATOR.php
ECHO.
ECHO  Parameters that will be used:
ECHO.
ECHO              RADIUS:      50nm
ECHO              WIDTH:       2nm
ECHO              ELEVELATION: 300ft
ECHO.
ECHO.
ECHO  The .xml will be saved to your desktop.
ECHO.
ECHO  Average Processing time is approx 18min
ECHO  depending on your connection to and the
ECHO  current server load for MyFSim.com
ECHO.
ECHO.
ECHO  Type the FAA ID or ICAO Code of the Airport
ECHO  that will be the center of the MSAW Grid
ECHO  and press Enter...
ECHO.
ECHO.

SET /P APT=

CURL "https://www.airnav.com/airport/%APT%">>AIRNAV_PAGE_%APT%.HTML

setlocal enabledelayedexpansion

for /f "tokens=* delims=" %%a in ('FINDSTR "Lat/Long" "AIRNAV_PAGE_%APT%.HTML"') do (
	SET LINE=%%a
		SET LINE=!LINE:^<BR^>=@!
		SET LINE=!LINE:,=@!
	
	for /f "usebackq tokens=3,4 delims=@" %%a in ('!LINE!') do (
		
		SET LAT=%%a
		SET LON=%%b
	)
)

if exist "%userprofile%\Desktop\!APT!_MSAW.xml" DEL /Q "%userprofile%\Desktop\!APT!_MSAW.xml"

:GET_HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 1 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300">>1_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 2 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=2&dooffset=1">>2_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 3 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=3&dooffset=1">>3_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 4 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=4&dooffset=1">>4_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 5 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=5&dooffset=1">>5_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 6 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=6&dooffset=1">>6_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 7 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=7&dooffset=1">>7_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 8 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=8&dooffset=1">>8_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 9 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=9&dooffset=1">>9_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 10 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=10&dooffset=1">>10_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 11 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=11&dooffset=1">>11_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 12 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=12&dooffset=1">>12_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 13 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=13&dooffset=1">>13_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 14 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=14&dooffset=1">>14_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 15 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=15&dooffset=1">>15_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 16 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=16&dooffset=1">>16_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 17 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=17&dooffset=1">>17_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 18 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=18&dooffset=1">>18_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 19 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=19&dooffset=1">>19_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 20 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=20&dooffset=1">>20_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 21 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=21&dooffset=1">>21_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 22 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=22&dooffset=1">>22_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 23 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=23&dooffset=1">>23_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 24 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=24&dooffset=1">>24_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 25 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=25&dooffset=1">>25_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 26 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=26&dooffset=1">>26_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 27 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=27&dooffset=1">>27_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 28 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=28&dooffset=1">>28_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 29 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=29&dooffset=1">>29_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 30 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=30&dooffset=1">>30_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 31 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=31&dooffset=1">>31_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 32 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=32&dooffset=1">>32_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 33 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=33&dooffset=1">>33_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 34 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=34&dooffset=1">>34_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 35 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=35&dooffset=1">>35_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 36 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=36&dooffset=1">>36_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 37 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=37&dooffset=1">>37_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 38 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=38&dooffset=1">>38_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 39 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=39&dooffset=1">>39_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 40 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=40&dooffset=1">>40_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 41 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=41&dooffset=1">>41_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 42 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=42&dooffset=1">>42_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 43 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=43&dooffset=1">>43_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 44 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=44&dooffset=1">>44_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 45 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=45&dooffset=1">>45_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 46 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=46&dooffset=1">>46_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 47 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=47&dooffset=1">>47_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 48 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=48&dooffset=1">>48_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 49 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=49&dooffset=1">>49_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO TITLE: !APT!_MSAW
ECHO LAT:   !LAT!
ECHO LON:   !LON!
ECHO.
ECHO.
ECHO.
ECHO Downloading Volume 50 of 50...
ECHO.
ECHO.
CURL "http://www.myfsim.com/sectorfilecreation/MSAW_creator.php?Title=!APT!_MSAW&Lat=!LAT!&Lon=!LON!&Radius=50&Width=2&Ceiling=300&offsetX=50&dooffset=1">>50_OF_50.HTML

CLS

ECHO.
ECHO.
ECHO  CONVERTING DOWNLOADED FILES
ECHO.
ECHO  Completed:
ECHO.
ECHO.

SET /A COUNT=0

:PARSE_FILES

SET /A COUNT=!COUNT! + 1

if "!COUNT!"=="51" GOTO DONE

ECHO !COUNT! of 50

SET END_OF_VOLUME=FALSE

if "!COUNT!"=="1" (

	for /f "skip=98 tokens=* delims=" %%a in (!COUNT!_OF_50.HTML) do (

		SET LINE=%%a
		
		SET TEXT_AREA_CHK=!LINE:~23,8!
			IF "!TEXT_AREA_CHK!"=="textarea" SET END_OF_VOLUME=TRUE
		
			if "!END_OF_VOLUME!"=="TRUE" (
				ECHO         ^</SystemVolume^>>>"%userprofile%\Desktop\!APT!_MSAW.xml"
				GOTO PARSE_FILES
			)
			
			if "!END_OF_VOLUME!"=="FALSE" (
				ECHO   !LINE!>>"%userprofile%\Desktop\!APT!_MSAW.xml"
			)
	)
)

if "!COUNT!"=="50" (

	for /f "skip=98 tokens=* delims=" %%a in (!COUNT!_OF_50.HTML) do (

		SET LINE=%%a
		
		SET TEXT_AREA_CHK=!LINE:~23,8!
			IF "!TEXT_AREA_CHK!"=="textarea" SET END_OF_VOLUME=TRUE
		
			if "!END_OF_VOLUME!"=="TRUE" (
				ECHO         ^</SystemVolume^>>>"%userprofile%\Desktop\!APT!_MSAW.xml"
				GOTO PARSE_FILES
			)
			
			if "!END_OF_VOLUME!"=="FALSE" (
				ECHO   !LINE!>>"%userprofile%\Desktop\!APT!_MSAW.xml"
			)
	)
)

if not "!COUNT!"=="1" if not "!COUNT!"=="50" (

	for /f "skip=99 tokens=* delims=" %%a in (!COUNT!_OF_50.HTML) do (

		SET LINE=%%a
		
		SET TEXT_AREA_CHK=!LINE:~23,8!
			IF "!TEXT_AREA_CHK!"=="textarea" SET END_OF_VOLUME=TRUE
		
		if "!END_OF_VOLUME!"=="TRUE" (
			ECHO         ^</SystemVolume^>>>"%userprofile%\Desktop\!APT!_MSAW.xml"
			GOTO PARSE_FILES
		)
		
		if "!END_OF_VOLUME!"=="FALSE" (
			ECHO   !LINE!>>"%userprofile%\Desktop\!APT!_MSAW.xml"
		)
	)
)

:DONE

CD "%temp%"

RD /Q /S MSAW_BATCH_TEMP

ECHO.
ECHO.
ECHO      **********
ECHO      ** Done **
ECHO      **********
ECHO.
ECHO.
ECHO  Your !APT!_MSAW.xml may be found on your desktop.
ECHO.
ECHO.

endlocal

PAUSE

EXIT
