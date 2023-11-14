@echo off
:: ################################################
:: ############ User Defined Variables ############
:: ################################################
:: # Fully qualified domain name.
:: This is passed as an argument by win-acme.
set FQDN=

:: # Admin Console credentials
set FMS_USER=
set FMS_PASS=

:: # Flag file created by win-acme deploy-hook.
FLAG_FILE=C:\Users\Public\Documents\sslDeployFlag

:: The path configured in win-acme to save a copy of the PEM certificate.
:: Exclude trailing backslash.
set PEM_PATH=C:\Program Files\FileMaker\FileMaker Server\SSL
:: ################################################


if exist %FLAG_FILE% (
    del /q %FLAG_FILE%
) else (
    exit /b 0
)

:: ################################################
:: ############# SSL Certificate Path #############
:: ################################################
set CERT_SUFFIX=-chain.pem
set KEY_SUFFIX=-key.pem
set CERT_NAME=%FQDN%%CERT_SUFFIX%
set KEY_NAME=%FQDN%%KEY_SUFFIX% 
set CERT="%PEM_PATH%\%CERT_NAME%"
set KEY="%PEM_PATH%\%KEY_NAME%"
:: ################################################

:: # Delete the installed certificate.
fmsadmin certificate delete --yes -u %FMS_USER% -p %FMS_PASS%

:: # Import the new certificate.
fmsadmin certificate import %CERT% --keyfile %KEY% -y -u %FMS_USER% -p %FMS_PASS%

:: # Close the FileMaker databases.
fmsadmin close -u %FMS_USER% -p %FMS_PASS% -m "Databases will close in two minutes for scheduled maintenance." -t 120

:: # Provide time for the databases to close. Two minutes for the user warning and two minutes to close the databases.
timeout /t 240 /nobreak

:: # Restart the FileMaker Server service
net stop "FileMaker Server"
net start "FileMaker Server"

:: # Provide the service time to gracefully stop and start
timeout /t 300 /nobreak

:: # Start the database server
fmsadmin start server -u %FMS_USER% -p %FMS_PASS%

:: # Provide the database server time to start
timeout /t 60 /nobreak

:: # Open databases
fmsadmin open -u %FMS_USER% -p %FMS_PASS%

:: Clear credentials from environment.
set FMS_USER=
set FMS_PASS=
