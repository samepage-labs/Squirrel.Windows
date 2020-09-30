@echo off

:: before pasting this script into TC, do "%" -> "%%" replace (except those around TC variables)

echo buildSquirrelWindows.bat

set VERSION=%teamcity.build.branch%

if "%VERSION%"=="" (
	echo buildSquirrelWindows.bat: devel build
	set VERSION=devel
) else (
	echo buildSquirrelWindows.bat: TeamCity build
)

set OUTPUT_NAME=Squirrel.Windows-%VERSION%
set OUT=_out\%OUTPUT_NAME%

echo buildSquirrelWindows.bat: version: %VERSION%
echo buildSquirrelWindows.bat: outputName: %OUTPUT_NAME%

set PATH=%CD%\vendor\7zip;%PATH%

::-------------------------------------------------------------------------------------------------

if not exist vendor\nuget\NuGet.sln (
	echo buildSquirrelWindows.bat: downloading NuGet SDK submodule
	git submodule update --init --recursive || exit /b 1
)

if not exist packages (
	echo buildSquirrelWindows.bat: downloading NuGet dependencies
	.nuget\nuget.exe restore || exit /b 1
)

::-------------------------------------------------------------------------------------------------

echo buildOpenSsl.bat: including VS2017 x32 env
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools" (
	echo buildOpenSsl.bat: VS2017 BuildTools x32 env
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x86
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community" (
	echo buildOpenSsl.bat: VS2017 Community x32 env
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x86
)

::-------------------------------------------------------------------------------------------------

echo buildSquirrelWindows.bat: clearing build folder
MSBuild Squirrel.sln /p:Configuration=Release /t:clean || exit /b 1

echo buildSquirrelWindows.bat: building SquirrelWindows VS project
msbuild Squirrel.sln /p:Configuration=Release || exit /b 1

::-------------------------------------------------------------------------------------------------

echo buildSquirrelWindows.bat: clearing out folder
if not exist _out ( md _out )
del /s /q _out\*
md %OUT%

echo buildSquirrelWindows.bat: copying Setup.exe
copy src\Setup\bin\Release\Setup.exe %OUT% || exit /b 1

echo buildSquirrelWindows.bat: copying WriteZipToSetup.exe
copy src\WriteZipToSetup\bin\Release\WriteZipToSetup.exe %OUT% || exit /b 1

echo buildSquirrelWindows.bat: copying StubExecutable.exe
copy src\StubExecutable\bin\Release\StubExecutable.exe %OUT% || exit /b 1

echo buildSquirrelWindows.bat: copying Update.exe to Squirrel.exe
copy src\Update\bin\Release\Update.exe %OUT%\Squirrel.exe || exit /b 1

echo buildSquirrelWindows.bat: copying Update-Mono.exe to Squirrel-Mono.exe
copy src\Update\bin\Release\Update-Mono.exe %OUT%\Squirrel-Mono.exe || exit /b 1

echo buildSquirrelWindows.bat: copying SyncReleases.exe
copy src\SyncReleases\bin\Release\SyncReleases.exe %OUT% || exit /b 1

echo buildSquirrelWindows.bat: copying rcedit.exe
copy src\Update\rcedit.exe %OUT% || exit /b 1

echo buildSquirrelWindows.bat: copying wix/*
copy vendor\wix\* %OUT% || exit /b 1

echo buildSquirrelWindows.bat: copying 7zip/*
copy vendor\7zip\* %OUT% || exit /b 1

::-------------------------------------------------------------------------------------------------

echo buildSquirrelWindows.bat: packing artifacts
pushd %OUT%
7z.exe a ..\%OUTPUT_NAME%.zip * -r || exit /b 1
popd

::-------------------------------------------------------------------------------------------------

echo buildSquirrelWindows.bat: done
