for %%I in (.) do powershell -ExecutionPolicy ByPass -file D:\Modding\SpaceEngineers\Mods\Assets\Generate-icons.ps1 "%%~nxI"
for %%I in (.) do powershell -ExecutionPolicy ByPass -file D:\Modding\SpaceEngineers\Mods\Assets\Deploy.ps1 "%%~nxI"
pause
