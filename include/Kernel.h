#ifndef KERNEL_H
#define KERNEL_H

#include <Sphere.h>

__global__ void ComputeRayTracingImage(unsigned char* , const Sphere*, int, int);

#endif // !KERNEL_H
