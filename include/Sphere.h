#ifndef SPHERE_H
#define SPHERE_H

#include <math.h>

#define INF 2e10f

struct Sphere
{
    float posX;
    float posY;
    float posZ;

    float colR;
    float colG;
    float colB;

    float radius;

    __device__ float hit(float ox, float oy, float* n) const
    {
        float dx = ox - posX;
        float dy = oy - posY;

        if ((dx * dx + dy * dy) < (radius * radius))
        {
            float dz = sqrtf(radius * radius - dx * dx - dy * dy);
            *n = dz / radius;
            return dz + posZ;
        }

        return -INF;
    }
};

#endif