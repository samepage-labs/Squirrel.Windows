@echo off

echo build.bat

if not exist vendor\nuget\NuGet.sln (
	echo build.bat: cloning NuGet SDK submodule
	git submodule update --init --recursive || exit /b 1
)

if not exist packages (
	echo build.bat: downloading NuGet dependencies
	.nuget\nuget.exe restore || exit /b 1
)

if not defined DevEnvDir (
	echo build.bat: including VisualStudio env

	if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\Tools\VsDevCmd.bat" (
		call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\Tools\VsDevCmd.bat"
	)
	if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat" (
		call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"
	)
)

echo build.bat: building VisualStudio project
msbuild Squirrel.sln /p:Configuration=Release || exit /b 1

echo build.bat: done
