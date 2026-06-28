#include<iostream>
#include<string>
#include<cuda.h>
#include<cuda_runtime.h>
#include <fstream>
#include<Sphere.h>
#include<Kernel.h>


using std::cout;
using std::endl;
using std::string;

#define NUMBER_OF_SPHERES 20
#define rnd( x ) (x * rand() / RAND_MAX)

#define IMAGE_WIDTH 3840
#define IMAGE_HEIGHT 2160

//function declarations

void saveImagePPM(const char*, unsigned char*, int, int);
void printCudaDeviceSpecs(void);

int main(void)
{	
	Sphere* arrayOfSpheres_host;
	Sphere* arrayOfSpheres_device;

	unsigned char* imagePointer_dev;
	unsigned char* imagePointer_host;

	size_t imageSize = IMAGE_WIDTH * IMAGE_HEIGHT * 3;

	// CUDA related variables

	cudaError_t error;

	printCudaDeviceSpecs();

	try
	{
		arrayOfSpheres_host = new Sphere[NUMBER_OF_SPHERES];
	}
	catch (std::bad_alloc&)
	{
		cout << "Memory allocation failed for " << NUMBER_OF_SPHERES << "spheres" << endl;
		exit(0);
	}

	// fill array of spheres.

	for (int i = 0; i < NUMBER_OF_SPHERES; i++)
	{
		float r, g, b;
		float x, y, z;
		float radius;

		r = rnd(1.0f);
		g = rnd(1.0f);
		b = rnd(1.0f);

		x = rnd(1000.0f) - 500;
		y = rnd(1000.0f) - 500;
		z = rnd(1000.0f) - 500;

		radius = rnd(100.0f) + 20;

		Vector3 col(r, g, b);
		Vector3 pos(x, y, z);


		arrayOfSpheres_host[i].setPosition(pos);
		arrayOfSpheres_host[i].setColor(col);
		arrayOfSpheres_host[i].setRadius(radius);

	}

	// allocate memory on GPU for array of spheres

	size_t sizeOfSphereArray = sizeof(Sphere) * NUMBER_OF_SPHERES;
	
	error = cudaMalloc((void**)&arrayOfSpheres_device, sizeOfSphereArray);

	if (error != cudaSuccess)
	{
		cout << "Memory allocation of " << NUMBER_OF_SPHERES << "on GPU failed !" << endl;

		cout << "CUDA Error: " << cudaGetErrorString(error) << endl;

		exit(0);
	}

	//copy spheres array from CPU to GPU

	error = cudaMemcpy(arrayOfSpheres_device, arrayOfSpheres_host, sizeOfSphereArray, cudaMemcpyHostToDevice);

	if (error != cudaSuccess)
	{
		cout << "Failed to copy " << NUMBER_OF_SPHERES << " spheres from CPU memory to GPU memory !" << endl;

		cout << "CUDA Error: " << cudaGetErrorString(error) << endl;

		exit(0);
	}

	//allocate memory from for image on GPU directly

	error = cudaMalloc((void**)&imagePointer_dev, imageSize);

	if (error != cudaSuccess)
	{
		cout << "Memory allocation for image failed !" << endl;

		cout << "CUDA Error: " << cudaGetErrorString(error) << endl;

		exit(0);
	}

	//allocate memory for host image image buffer.

	try
	{
		imagePointer_host = new unsigned char[imageSize];
	}
	catch (std::bad_alloc&)
	{
		cout << "Memory allocation failed for host image buffer !" << endl;
		exit(0);
	}

	// decide the grid properties

	dim3 blockDim(32, 32);
	dim3 gridDim(
		(IMAGE_WIDTH + blockDim.x - 1) / blockDim.x,
		(IMAGE_HEIGHT + blockDim.y - 1) / blockDim.y
	);

	// call the kernel

	ComputeRayTracingImage<<<gridDim, blockDim>>>(imagePointer_dev, arrayOfSpheres_device, IMAGE_WIDTH, IMAGE_HEIGHT);

	// Copy rendered image from GPU memory back to CPU memory

	error = cudaMemcpy(imagePointer_host, imagePointer_dev, imageSize, cudaMemcpyDeviceToHost);

	if (error != cudaSuccess)
	{
		cout << "Failed to copy rendered image from GPU memory to CPU memory !" << endl;
		cout << "CUDA Error: " << cudaGetErrorString(error) << endl;
		exit(0);
	}

	saveImagePPM("OutputImage.ppm", imagePointer_host, IMAGE_WIDTH, IMAGE_HEIGHT);

	// free allocated memory

	cudaFree(arrayOfSpheres_device);
	cudaFree(imagePointer_dev);

	delete [] arrayOfSpheres_host;
	delete[] imagePointer_host;


	return(0);
}

#include <fstream>

void saveImagePPM(const char* filename, unsigned char* image, int width, int height)
{

	string imagePath = "D:\\CUDA_Ray_Tracer\\OutputImage\\Ray_Traced_Spheres.ppm";

	std::ofstream file(imagePath, std::ios::binary);

	if (!file)
	{
		std::cout << "Failed to create image file!" << std::endl;
		return;
	}


	// PPM header

	file << "P3\n";
	file << width << " " << height << "\n";
	file << "255\n";


	// Write RGB pixel data

	for (int y = 0; y < height; y++)
	{
		for (int x = 0; x < width; x++)
		{
			int index = (y * width + x) * 3;

			file << (int)image[index] << " "
				<< (int)image[index + 1] << " "
				<< (int)image[index + 2] << "\n";
		}
	}


	file.close();

	std::cout << "Image saved successfully!" << std::endl;
}

void printCudaDeviceSpecs(void)
{
	int deviceCount = 0;
	cudaError_t error = cudaGetDeviceCount(&deviceCount);

	if (error != cudaSuccess)
	{
		cout << "Failed to query CUDA devices: " << cudaGetErrorString(error) << endl;
		return;
	}

	if (deviceCount == 0)
	{
		cout << "No CUDA-capable GPU found." << endl;
		return;
	}

	int currentDevice = 0;
	error = cudaGetDevice(&currentDevice);

	if (error != cudaSuccess)
	{
		cout << "Failed to get current CUDA device: " << cudaGetErrorString(error) << endl;
		return;
	}

	cout << "========== CUDA Device Specs (for grid/block sizing) ==========" << endl;
	cout << "Device count: " << deviceCount << endl;
	cout << "Active device index: " << currentDevice << endl;

	for (int device = 0; device < deviceCount; device++)
	{
		cudaDeviceProp properties;
		error = cudaGetDeviceProperties(&properties, device);

		if (error != cudaSuccess)
		{
			cout << "Failed to read properties for device " << device << ": "
				<< cudaGetErrorString(error) << endl;
			continue;
		}

		cout << "--------------------------------------------------------------" << endl;
		cout << "Device " << device << ": " << properties.name << endl;
		cout << "Compute capability: " << properties.major << "." << properties.minor << endl;
		cout << "Multiprocessors (SMs): " << properties.multiProcessorCount << endl;
		cout << "Warp size: " << properties.warpSize << endl;
		cout << "Max threads per block: " << properties.maxThreadsPerBlock << endl;
		cout << "Max block dimensions (x, y, z): "
			<< properties.maxThreadsDim[0] << ", "
			<< properties.maxThreadsDim[1] << ", "
			<< properties.maxThreadsDim[2] << endl;
		cout << "Max grid dimensions (x, y, z): "
			<< properties.maxGridSize[0] << ", "
			<< properties.maxGridSize[1] << ", "
			<< properties.maxGridSize[2] << endl;
		cout << "Max threads per multiprocessor: " << properties.maxThreadsPerMultiProcessor << endl;
		cout << "Shared memory per block: " << properties.sharedMemPerBlock << " bytes" << endl;
		cout << "Registers per block: " << properties.regsPerBlock << endl;
		cout << "Total global memory: "
			<< (properties.totalGlobalMem / (1024 * 1024)) << " MB" << endl;
	}

	cout << "==============================================================" << endl;
}
