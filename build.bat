@echo off

cls

echo Building ____________ CUDA Ray Tracer _____________

nvcc src/main.cu -I include -o RayTracer.exe

if %errorlevel% neq 0 (

	echo.
	echo ________ Build Failed ________
	pause
	exit/b
)

echo.
echo ________________ Build Successfull _____________
pause