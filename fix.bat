@echo off
:: Check for administrative privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

echo ===================================================
echo   DISABLING SECURITY AND ANTI-CHEAT SERVICES      
echo ===================================================
echo.

:: 1. Turn Off Core Isolation (Memory Integrity / HVCI)
echo [1/3] Disabling Core Isolation (Memory Integrity)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 (echo Successfully scheduled Core Isolation to turn OFF.) else (echo Failed to modify Core Isolation key.)

:: 2. Turn Off Microsoft Vulnerable Driver Blocklist
echo [2/3] Disabling Vulnerable Driver Blocklist...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v VulnerableDriverBlocklistEnable /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 (echo Successfully scheduled Driver Blocklist to turn OFF.) else (echo Failed to modify Driver Blocklist key.)

echo.
:: 3. Stop Anti-Cheat and Background Gaming Services
echo [3/3] Stopping Anti-Cheat Services...
echo ---------------------------------------------------

:: FACEIT AC
echo Stopping FACEIT Anti-Cheat...
sc stop FACEIT >nul 2>&1

:: Riot Vanguard (Valorant)
echo Stopping Riot Vanguard (vgk)...
sc stop vgk >nul 2>&1

:: Easy Anti-Cheat (EAC)
echo Stopping Easy Anti-Cheat...
sc stop EasyAntiCheat >nul 2>&1
sc stop EasyAntiCheat_EoS >nul 2>&1

:: BattlEye (PUBG, Destiny 2, Rainbow Six, etc.)
echo Stopping BattlEye...
sc stop BEService >nul 2>&1

:: Origin / EA Anti-Cheat
echo Stopping EA Anti-Cheat...
sc stop EAAntiCheatService >nul 2>&1

echo ---------------------------------------------------
echo.
echo Operation complete. 
echo NOTE: Registry modifications (Core Isolation / Blocklist) require a PC restart to take full effect.
echo.
pause