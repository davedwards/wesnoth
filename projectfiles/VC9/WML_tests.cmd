:: WML_tests.cmd : Run the WML unit tests specified in wml_test_schedule

:: preamble: don't spam stdout with commands, don't expand ERRORLEVEL to 0
@echo off
setlocal enabledelayedexpansion

:: save file paths and command line arguments
set LoadFile=%~p0..\..\wml_test_schedule
set binary=wesnoth.exe
set opt=--log-strict=warning
:: executable path can be set for VC debug configuration, defaults to wesnoth\
if "%1"=="" ( cd ..\..\ ) else ( cd %~p1 )

echo running WML tests:
set tSTART=%time%

:: ignore lines beginning with #
:: %%G contains whether the test should pass (0), timeout (2) or fail (1,4)
:: %%H is the name of the WML unit test to be executed
for /f "eol=# tokens=1,2 delims= " %%G in (%LoadFile%) do (
    :: WindowsTimeout is more reliable than the --timeout option
    WindowsTimeout.exe "%binary% %opt% -u %%H" 20000
    if !ERRORLEVEL! neq %%G (
        if !ERRORLEVEL! equ 2 (
            echo(
            echo WML_tests.cmd: Warning WML2: Test '%%H' timed out, expected return value %%G
        ) else (
            echo(
            echo WML_tests.cmd: Error WML1: Test '%%H' returned !ERRORLEVEL!, expected %%G
        )
        set /a "fail_num+=1"
    )
    :: minimalistic progress bar
    <nul (set/p progress=.)
    set /a "test_num+=1"
)
echo(
if not DEFINED fail_num ( set "fail_num=none" )
set /a "minutes = (1%time:~3,2%-100) - (1%tSTART:~3,2%-100)"
set /a "seconds = (1%time:~6,2%-100) - (1%tSTART:~6,2%-100)"
echo %test_num% WML tests completed in %minutes%m %seconds%s, %fail_num% of them failed

:: restore the state before execution
cd %~p0
echo on
