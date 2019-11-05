#include<stdio.h>
#include <cuda.h>

void random_ints(int* a, int N)
{
	int i;
	for (i = 0; i < N; ++i)
		a[i] = rand()%100;
}

__global__ void add_vector(int* a,int* b,int*c)
{
	int i = blockIdx.x*blockDim.x+ threadIdx.x;
	c[i] = a[i] + b[i];
}

int main()
{
	int N = 10000; //size of vector
	int M = 10; //Number of thread
	size_t size = N * sizeof(int);
	//allocate memory for host vector
	int* vector1 = (int*)malloc(size);
	int* vector2 = (int*)malloc(size);
	int* vector3 = (int*)malloc(size);

	//insert number into vector
	random_ints(vector1,N);
	random_ints(vector2,N);

	//create device vector pointer
	int *d_vector1;
	int *d_vector2;
	int *d_vector3;

	//allocate device memory for vector
	cudaMalloc(& d_vector1, size);
	cudaMalloc(& d_vector2, size);
	cudaMalloc(& d_vector3, size);

	//copy vectors from host memory to dvice memory
	cudaMemcpy(d_vector1,vector1, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_vector2,vector2, size, cudaMemcpyHostToDevice);

	//call kernal
	add_vector<<<(N+M-1)/M,M>>>(d_vector1, d_vector2, d_vector3);
	
	//cudaDeviceSynchronize();
	cudaMemcpy(vector3,d_vector3, size, cudaMemcpyDeviceToHost);

	for (int i = 0; i < 10000; i++)
	{
		printf("%d %d + %d =%d\n",i,vector1[i], vector2[i], vector3[i]);

	}
}
