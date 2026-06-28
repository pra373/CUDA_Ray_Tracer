#ifndef SPHERE_H
#define SPHERE_H

#include "Vector3.h"
#include <math.h>

#define INF 2e10f

class Sphere
{
private:

	Vector3 position;
	Vector3 color;
	float radius;

public:

	__host__ __device__ Sphere(Vector3 pos = Vector3(), Vector3 col = Vector3(), float r = 1.0f)
	{
		position = pos;
		color = col;
		radius = r;
	}
	__device__ float hit(float ox, float oy, float* n) const
	{
		float dx = ox - position.getFirst();
		float dy = oy - position.getSecond();

		if ((dx * dx + dy * dy) < (radius * radius))
		{
			float dz = sqrtf(radius * radius - dx * dx - dy * dy);
			*n = dz / sqrtf(radius * radius);
			return dz + position.getThird();
		}

		return -INF;
	}

	__host__ __device__ Vector3 getPosition(void) const
	{
		return(position);
	}

	__host__ __device__ Vector3 getColor(void) const
	{
		return(color);
	}

	__host__ __device__ float getRadius(void) const
	{
		return(radius);
	}

	__host__ __device__ void setPosition(Vector3 pos)
	{
		position = pos;
	}

	__host__ __device__ void setColor(Vector3 col)
	{
		color = col;
	}

	__host__ __device__ void setRadius(float r)
	{
		radius = r;
	}
		
};

#endif