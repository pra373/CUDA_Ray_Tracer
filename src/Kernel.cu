#include "Kernel.h"

#define NUMBER_OF_SPHERES 20

__global__ void ComputeRayTracingImage(unsigned char* imagePointer_dev, const Sphere* arrayOfSpheres, int imageWidth, int imageHeight)
{
	// Find which pixel this CUDA thread is responsible for

	int idx = threadIdx.x + blockIdx.x * blockDim.x;
	int idy = threadIdx.y + blockIdx.y * blockDim.y;

	// Ignore extra threads outside image size

	if (idx >= imageWidth || idy >= imageHeight)
	{
		return;
	}

	// RGB image buffer index

	int offset = (idy * imageWidth + idx) * 3;

	// shift origin of the image to centre pixel

	float ox = (idx - (imageWidth / 2.0f));
	float oy = (idy - (imageHeight / 2.0f));

	float r = 0.0f;
	float g = 0.0f;
	float b = 0.0f;

	float closestHitDistance = -INF;

	// shoot ray and check how many spheres the ray hit.

	for (int i = 0; i < NUMBER_OF_SPHERES; i++)
	{
		float normal;

		float t = arrayOfSpheres[i].hit(ox, oy, &normal);

		if (t > closestHitDistance)
		{
			float colorScale = normal;

			r = arrayOfSpheres[i].getColor().getFirst() * colorScale;
			g = arrayOfSpheres[i].getColor().getSecond() * colorScale;
			b = arrayOfSpheres[i].getColor().getThird() * colorScale;

			closestHitDistance = t;

		}
	}

	// Store final RGB value into image buffer

	imagePointer_dev[offset + 0] = (unsigned char)(r * 255);
	imagePointer_dev[offset + 1] = (unsigned char)(g * 255);
	imagePointer_dev[offset + 2] = (unsigned char)(b * 255);
}
