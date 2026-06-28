#ifndef VECTOR3_H
#define VECTOR3_H

class Vector3
{
private:

	float first, second, third;

public:

	__host__ __device__ Vector3(float f = 0, float s = 0, float t = 0) : first(f), second(s), third(t)
	{

	}

	__host__ __device__ float getFirst(void) const
	{
		return(first);
	}

	__host__ __device__ float getSecond(void) const
	{
		return(second);
	}

	__host__ __device__ float getThird(void) const
	{
		return(third);
	}

	__host__ __device__ void setFirst(float val)
	{
		first = val;
	}

	__host__ __device__ void setSecond(float val)
	{
		second = val;
	}

	__host__ __device__ void setThird(float val)
	{
		third = val;
	}
};

#endif