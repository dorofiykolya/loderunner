@echo off

::::::::::::::: ENVIRONMENT ::::::::::::::
set PROG=LodeRunner
set JDK="e:\Program Files\j2sdk1.4.2_13"
rem :: set NOKIA=E:\nokia\Devices\Nokia_7210_MIDP_SDK_v1_0
rem :: set EMULATOR=7210.exe -provisioning
set NOKIA=E:\nokia\Devices\S40_SDK_3rd_Edition_Feature_Pack_1
set EMULATOR=emulator.exe load

::::::::::::::: COMPILATION ::::::::::::::
echo Compiling %PROG%...
%JDK%\bin\javac -g:none -target 1.1 -d classes -classpath classes -bootclasspath  %NOKIA%\lib\classes.zip src\*.java
if errorlevel 1 goto error

:::::::::::::: OPTIMIZE/OBFUSCATE ::::::::::::::
echo Optimizing/Obfuscating %PROG%...
%JDK%\bin\java -jar E:\nokia\proguard3.7\lib\proguard.jar -injars classes -outjars classes.obfuscated -libraryjars %NOKIA%\lib\classes.zip -dontusemixedcaseclassnames -overloadaggressively -allowaccessmodification -dontobfuscate -keep "!abstract public class * extends javax.microedition.midlet.MIDlet"
if errorlevel 1 goto end
del /q classes\*.*
rmdir classes
ren classes.obfuscated classes

:::::::::::::: ARCHIVE ::::::::::::::
echo Archiving %PROG%...
%NOKIA%\bin\preverify -classpath %NOKIA%\lib\classes.zip -d classes classes
if errorlevel 1 goto end
%JDK%\bin\jar cfm %PROG%.jar src/Manifest.manifest -C classes . -C res .
if errorlevel 1 goto end

:::::::::::::: DEPLOYING ::::::::::::::
echo Deploying %PROG%...
type src\Manifest.manifest > %PROG%.jad
echo MIDlet-Jar-URL: %PROG%.jar >> %PROG%.jad
for %%R in (%PROG%.jar) do echo MIDlet-Jar-Size: %%~zR >> %PROG%.jad

:::::::::::::: RUNTIME ::::::::::::::
echo Running %PROG%...
%NOKIA%\bin\%EMULATOR% %PROG%.jad
goto end

:error
pause
:end