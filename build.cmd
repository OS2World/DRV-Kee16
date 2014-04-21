@echo off
set prompt=[$p,rc$q$r]
nmake /nologo %1 %2>error.txt
if ERRORLEVEL 1 goto end

:end