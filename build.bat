@echo off

cls

echo  ____________ Building CUDA Ray Tracer _____________

nvcc src/Main.cu src/Kernel.cu -I include -o RayTracer.exe

if %errorlevel% neq 0 (

	echo.
	echo ________ Build Failed ________
	pause
	exit/b
)

echo.
echo ________________ Build Successfull _____________

RayTracer.exe

pause