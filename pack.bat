@echo off

set VERSION=%teamcity.build.branch%

if "%VERSION%"=="" (
	echo pack.bat: devel build
	set VERSION=devel
) else (
	echo pack.bat: TeamCity build
)

set OUTPUT_NAME=Squirrel.Windows-%VERSION%
echo pack.bat: version: %VERSION%
echo pack.bat: outputName: %OUTPUT_NAME%

echo pack.bat: clearing build folder
if not exist _build ( md _build )
del /s /q _build\* || exit /b 1

echo pack.bat: clearing packages folder
if not exist _packages ( md _packages )
del /s /q _packages\* || exit /b 1

echo pack.bat: copying Setup.exe
copy src\Setup\bin\Release\Setup.exe _build\ || exit /b 1

echo pack.bat: copying WriteZipToSetup.exe
copy src\WriteZipToSetup\bin\Release\WriteZipToSetup.exe _build\ || exit /b 1

echo pack.bat: copying StubExecutable.exe
copy src\StubExecutable\bin\Release\StubExecutable.exe _build\ || exit /b 1

echo pack.bat: copying Update.exe to Squirrel.exe
copy src\Update\bin\Release\Update.exe _build\Squirrel.exe || exit /b 1

echo pack.bat: copying Update-Mono.exe to Squirrel-Mono.exe
copy src\Update\bin\Release\Update-Mono.exe _build\Squirrel-Mono.exe || exit /b 1

echo pack.bat: copying Update.com to Squirrel.com
copy src\Update\bin\Release\Update.com _build\Squirrel.com || exit /b 1

echo pack.bat: copying SyncReleases.exe
copy src\SyncReleases\bin\Release\SyncReleases.exe _build\ || exit /b 1

echo pack.bat: copying signtool.exe
copy src\Update\signtool.exe _build\ || exit /b 1

echo pack.bat: copying rcedit.exe
copy src\Update\rcedit.exe _build\ || exit /b 1

echo pack.bat: copying wix/*
copy vendor\wix\* _build\ || exit /b 1

echo pack.bat: copying 7zip/*
copy vendor\7zip\* _build\ || exit /b 1

echo pack.bat: building .ZIP package
pushd _build
..\vendor\7zip\7z.exe a ..\_packages\%OUTPUT_NAME%.zip * -r || exit /b 1
popd

echo build.bat: done
