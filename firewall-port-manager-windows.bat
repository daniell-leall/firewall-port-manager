@echo off
setlocal enabledelayedexpansion

:: Check if the script is being run as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ===================================================
    echo      WELCOME TO THE FIREALL PORT MANAGER T00L
    echo ===================================================
    echo.
    echo [ERROR] WHOOPS! Looks like you don't have admin rights.
    echo.
    echo Please restart this script as Administrator to unleash its power!
    echo.
    pause
    exit /b
)

:: This is a main menu with multiples choices.
:main_menu
cls
echo ===================================================
echo      WELCOME TO THE FIREALL PORT MANAGER T00L
echo ===================================================
echo.
echo   Which rule would you like to execute?
echo.
echo   [1] Open a port
echo   [2] Close a port
echo   [3] Delete all rules (Only created by this app)
echo   [4] Exit
echo.
echo ===================================================
echo.

set /p choice="Enter your choice: "

if "%choice%"=="1" goto open_port
if "%choice%"=="2" goto close_port
if "%choice%"=="3" goto delete_all_rules
if "%choice%"=="4" goto ExitScript
echo Invalid option. Please try again.
pause
goto main_menu

:open_port
cls
echo Here, some rules that were previously added may appear:
echo.
for /f "tokens=3*" %%A in ('netsh advfirewall firewall show rule name^=all ^| findstr "FIREWALL-PORT-MANAGER"') do @echo %%A
echo.
set /p port="Enter the port number (1-65535): "
rem Check if the input is numeric
for /f "delims=0123456789" %%A in ("%port%") do (
    echo Invalid port. Please enter a valid number between 1 and 65535.
    pause
    goto open_port
)

rem Check if the port is within the valid range
set /a port=%port% 2>nul
if %port% lss 1 (
    echo Port must be greater than or equal to 1.
    pause
    goto open_port
)
if %port% gtr 65535 (
    echo Port must be less than or equal to 65535.
    pause
    goto open_port
)

:choose_protocol
cls
echo [Choose Protocol]
echo.
echo 1. TCP
echo 2. UDP
echo 3. Both (TCP and UDP)
echo 4. Return to the Start Menu
echo.
set /p protocol="Choose an option: "

if "%protocol%"=="1" set proto=TCP
if "%protocol%"=="2" set proto=UDP
if "%protocol%"=="3" set proto=BOTH
if "%protocol%"=="4" goto main_menu
if not defined proto (
    echo Invalid option. Please try again.
    pause
    goto choose_protocol
)

:confirm_open
cls
if "%proto%"=="BOTH" (
    echo Are you sure that you want to OPEN a port %port% using TCP and UDP protocols?
) else (
    echo Are you sure that you want to OPEN a port %port% using protocol %proto%?
)
echo.
echo 1. Yes
echo 2. Yes, but temporarily
echo 3. No (Return to the Start Menu)
echo.
set /p confirm="Choose an option: "

if "%confirm%"=="1" (
    if "%proto%"=="BOTH" (
        rem Adiciona a regra para TCP
        netsh advfirewall firewall add rule name="FIREWALL-PORT-MANAGER-%port%-TCP" dir=in action=allow protocol=TCP localport=%port%
        echo The port %port% with the TCP protocol has been opened.
        echo.

        rem Adiciona a regra para UDP
        netsh advfirewall firewall add rule name="FIREWALL-PORT-MANAGER-%port%-UDP" dir=in action=allow protocol=UDP localport=%port%
        echo The port %port% with the UDP protocol has been opened.
        echo.
    ) else (
        rem Adiciona a regra com o protocolo selecionado (TCP ou UDP)
        netsh advfirewall firewall add rule name="FIREWALL-PORT-MANAGER-%port%-%proto%" dir=in action=allow protocol=%proto% localport=%port%
        echo The port %port% with the %proto% protocol has been opened.
        echo.
    )
    pause
    goto main_menu
)
if "%confirm%"=="2" goto temporary_rule
if "%confirm%"=="3" goto main_menu
echo Invalid option. Please try again.
pause
goto confirm_open

:temporary_rule
cls
echo [Set Temporary Rule Duration]
echo.
echo 1. 5 minutes
echo 2. 15 minutes
echo 3. 30 minutes
echo 4. 60 minutes
echo 5. Return to the Start Menu (Keep the port open indefinitely)
echo.
set /p duration="Choose an option: "

rem Define o tempo com base na opção escolhida
if "%duration%"=="1" set time=300
if "%duration%"=="2" set time=900
if "%duration%"=="3" set time=1800
if "%duration%"=="4" set time=3600
if "%duration%"=="5" (
    rem Abre a porta indefinidamente para o protocolo selecionado
    netsh advfirewall firewall add rule name="FIREWALL-PORT-MANAGER-%port%-%proto%" dir=in action=allow protocol=%proto% localport=%port%
    echo The port %port% with the %proto% protocol has been opened indefinitely.
    pause
    goto main_menu
)

rem Verifica se o tempo foi definido corretamente
if not defined time (
    echo Invalid option. Please try again.
    pause
    goto temporary_rule
)

rem Abre a porta para o protocolo selecionado (já definido previamente)
if "%proto%"=="TCP" (
    netsh advfirewall firewall add rule name="FIREWALL-PORT-MANAGER-%port%-TCP" dir=in action=allow protocol=TCP localport=%port%
    echo The port %port% with the TCP protocol has been opened for %time% seconds.
) else if "%proto%"=="UDP" (
    netsh advfirewall firewall add rule name="FIREWALL-PORT-MANAGER-%port%-UDP" dir=in action=allow protocol=UDP localport=%port%
    echo The port %port% with the UDP protocol has been opened for %time% seconds.
) else if "%proto%"=="BOTH" (
    netsh advfirewall firewall add rule name="FIREWALL-PORT-MANAGER-%port%-TCP" dir=in action=allow protocol=TCP localport=%port%
    netsh advfirewall firewall add rule name="FIREWALL-PORT-MANAGER-%port%-UDP" dir=in action=allow protocol=UDP localport=%port%
    echo The port %port% with both TCP and UDP protocols has been opened for %time% seconds.
)

rem Aguarda o tempo definido
timeout /t %time%

rem Remove a regra para o protocolo selecionado (TCP ou UDP)
if "%proto%"=="TCP" (
    netsh advfirewall firewall delete rule name="FIREWALL-PORT-MANAGER-%port%-TCP" >nul 2>&1
    echo The TCP rule for port %port% has been removed.
) else if "%proto%"=="UDP" (
    netsh advfirewall firewall delete rule name="FIREWALL-PORT-MANAGER-%port%-UDP" >nul 2>&1
    echo The UDP rule for port %port% has been removed.
) else if "%proto%"=="BOTH" (
    netsh advfirewall firewall delete rule name="FIREWALL-PORT-MANAGER-%port%-TCP" >nul 2>&1
    netsh advfirewall firewall delete rule name="FIREWALL-PORT-MANAGER-%port%-UDP" >nul 2>&1
    echo The TCP and UDP rules for port %port% have been removed.
)

pause
goto main_menu

:close_port
cls
echo Here, some rules that were previously added may appear:
echo.
for /f "tokens=3*" %%A in ('netsh advfirewall firewall show rule name^=all ^| findstr "FIREWALL-PORT-MANAGER"') do @echo %%A
echo.
set "port="
set /p port="Enter the port number to close: "

rem Check if the input is numeric
for /f "delims=0123456789" %%A in ("%port%") do (
    echo Invalid port. Please enter a valid number between 1 and 65535.
    pause
    goto close_port
)

rem Check if the port is within the valid range
set /a port=%port% 2>nul
if %port% lss 1 (
    echo Port must be greater than or equal to 1.
    pause
    goto close_port
)
if %port% gtr 65535 (
    echo Port must be less than or equal to 65535.
    pause
    goto close_port
)

:choose_close_protocol
cls
echo [Choose Protocol to Close]
echo.
echo 1. TCP
echo 2. UDP
echo 3. Both (TCP and UDP)
echo.
set "protocol="
set /p protocol="Choose an option: "

if "%protocol%"=="1" (
    set "proto=TCP"
) else if "%protocol%"=="2" (
    set "proto=UDP"
) else if "%protocol%"=="3" (
    set "proto=BOTH"
) else (
    echo Invalid option. Please try again.
    pause
    goto choose_close_protocol
)

rem Confirmation for deleting the rule
set "confirm="
set /p confirm="Are you sure you want to delete the rule? (1 for Yes, 0 for No): "

if "%confirm%"=="1" (
    if "%proto%"=="BOTH" (
        rem Remove the rule for TCP
        netsh advfirewall firewall delete rule name="FIREWALL-PORT-MANAGER-%port%-TCP" >nul 2>&1
        if %errorlevel%==0 (
            echo Rule for protocol TCP on port %port% has been removed.
        ) else (
            echo No TCP rule found for port %port%.
        )
        
        rem Remove the rule for UDP
        netsh advfirewall firewall delete rule name="FIREWALL-PORT-MANAGER-%port%-UDP" >nul 2>&1
        if %errorlevel%==0 (
            echo Rule for protocol UDP on port %port% has been removed.
        ) else (
            echo No UDP rule found for port %port%.
        )
    ) else (
        rem Remove the rule for the selected protocol (TCP or UDP)
        netsh advfirewall firewall delete rule name="FIREWALL-PORT-MANAGER-%port%-%proto%" >nul 2>&1
        if %errorlevel%==0 (
            echo Rule for protocol %proto% on port %port% has been removed.
        ) else (
            echo No %proto% rule found for port %port%.
        )
    )
    pause
    goto main_menu
) else (
    echo Operation canceled.
    pause
    goto main_menu
)

:delete_all_rules
cls
echo The following rules will be deleted...
echo.
for /f "tokens=3*" %%A in ('netsh advfirewall firewall show rule name^=all ^| findstr "FIREWALL-PORT-MANAGER"') do @echo %%A
echo.
for /f "tokens=2 delims=:" %%A in ('netsh advfirewall firewall show rule name^=all ^| findstr "FIREWALL-PORT-MANAGER"') do @for /f "tokens=* delims= " %%B in ("%%A") do netsh advfirewall firewall delete rule name="%%B"
echo.
echo All rules are deleted.
echo.

pause
goto main_menu

:ExitScript
:: Disables variable expansion to correctly display the exclamation mark
setlocal disableDelayedExpansion

:: Setting the wait time in seconds (can be easily changed)
set WAIT_TIME=20

:: Clearing the screen and displaying the menu
cls
echo ============================================================
echo              THANK YOU FOR USING THIS SCRIPT!
echo ============================================================
echo.
echo   We will close automatically in %WAIT_TIME% seconds.
echo.
echo.
echo   Don't forget to follow me on:
echo.
echo   [1] Instagram
echo   [2] YouTube
echo   [3] GitHub
echo.
echo   [4] Buy Me a Coffee
echo.
echo.
echo ============================================================
echo.

:: Using the "choice" command to get user input with a 20-second timeout
choice /c 12345 /t %WAIT_TIME% /d 5 /n /m "Choose an option:"

:: Action to be executed based on the selected option
if %errorlevel%==5 (
    echo.
    echo   Exiting script... Goodbye!
    timeout /t 2 >nul
    exit
) else if %errorlevel%==1 (
    echo.
    echo Opening Instagram profile...
    timeout /t 2 >nul
    start https://www.instagram.com/daniell.leall/
) else if %errorlevel%==2 (
    echo.
    echo Opening YouTube profile...
    timeout /t 2 >nul
    start https://www.youtube.com/@prosecd?sub_confirmation=1
) else if %errorlevel%==3 (
    echo.
    echo Opening GitHub profile...
    timeout /t 2 >nul
    start https://github.com/daniell-leall
) else if %errorlevel%==4 (
    echo.
    echo Opening Buy Me a Coffee page...
    timeout /t 2 >nul
    start https://ko-fi.com/daniell_leall
)

goto ExitScript

