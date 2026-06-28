#include<Sphere.h>
#include<math.h>

__device__ float Sphere::hit(float ox, float oy, float* n)
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