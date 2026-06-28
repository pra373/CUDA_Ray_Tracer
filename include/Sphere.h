#ifndef SPHERE_H
#define SPHERE_H

#include "Vector3.h"

#define INF 2e10f

class Sphere
{
private:

	Vector3 position;
	Vector3 color;
	float radius;

public:

	Sphere(Vector3 pos = Vector3(), Vector3 col = Vector3(), float r = 1.0f) 
	{
		position = pos;
		color = col;
		radius = r;
	}

	__device__ float hit(float , float , float*);

	Vector3 getPosition(void) const
	{
		return(position);
	}

	Vector3 getColor(void) const
	{
		return(color);
	}

	float getRadius(void) const
	{
		return(radius);
	}

	void setPosition(Vector3 pos)
	{
		position = pos;
	}

	void setColor(Vector3 col)
	{
		color = col;
	}

	void setRadius(float r)
	{
		radius = r;
	}
		
};

#endif