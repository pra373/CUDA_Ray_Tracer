#include<iostream>
#include<cuda.h>
#include <fstream>
#include<Sphere.h>


using std::cout;
using std::endl;

#define NUMBER_OF_SPHERES 20
#define rnd( x ) (x * rand() / RAND_MAX)

#define IMAGE_WIDTH 1024
#define IMAGE_HEIGHT 1024

//function declarations

void saveImagePPM(const char*, unsigned char*, int, int);

int main(void)
{	
	Sphere* arrayOfSpheres_host;
	Sphere* arrayOfSpheres_device;

	unsigned char* imagePointer_dev;
	unsigned char* imagePointer_host;

	size_t imageSize = IMAGE_WIDTH * IMAGE_HEIGHT * 3;

	// CUDA related variables

	cudaError_t error;

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

	// TODO: kernel will be called here and fill the image.

	// Copy rendered image from GPU memory back to CPU memory

	error = cudaMemcpy(imagePointer_host, imagePointer_dev, imageSize, cudaMemcpyDeviceToHost);

	if (error != cudaSuccess)
	{
		cout << "Failed to copy rendered image from GPU memory to CPU memory !" << endl;
		cout << "CUDA Error: " << cudaGetErrorString(error) << endl;
		exit(0);
	}

	saveImagePPM("OutputImage", imagePointer_host, IMAGE_WIDTH, IMAGE_HEIGHT);

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
	std::ofstream file(filename);

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