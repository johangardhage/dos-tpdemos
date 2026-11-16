@echo off
if not exist build\nul mkdir build
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo01.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo02.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo03.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo04.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo05.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo06.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo07.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo08.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo09.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo10.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo11.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo12.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo13.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo14.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo15.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo16.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo17.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo18.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo19.pas
if errorlevel 1 goto end
tpc -$G+ -$N+ -B -Usrc\lib -Iassets -Ebuild src\demo20.pas
if errorlevel 1 goto end
:end
