
#include<stdio.h>
#include <cuda.h>

void random_ints(int* a, int N) 
{
	int i;
	for (i = 0; i < N; ++i)
		a[i] = rand()%20000;
}

void add_array(int* a, int N)  
{
	for (int i = 0; i < N; ++i)
		a[i] =i;
}
__global__ void binary_search(int* a, int* b, bool* c, int sizeofa) //kernal function
{
	int index = blockIdx.x * blockDim.x + threadIdx.x;
	printf(" %d\n", index);
	int key = b[index];
	int min = 0, max = sizeofa;
	int mid = sizeofa / 2;
	while (min != mid)
	{
		if (key == a[mid])
		{
			break;
		}
		else if (key < a[mid])
		{
			min = min;
			max = mid;
		}
		else {
			min = mid;
			max = max;
		}
		mid = (min + max) / 2;
	}
	
	if (key == a[mid])
		c[index] = true;
	else
		c[index] = false;

	printf(" %d %d  %d %d\n", index, key, a[mid],c[index]);
}

int main()
{
	int N = 10000; //size of given array
	int M = 1000; //Number of searching element
	size_t size = N * sizeof(int);
	size_t size2 = M * sizeof(int);

	//allocate memory for host array
	int* vector1 = (int*)malloc(size);
	int* vector2 = (int*)malloc(size2);
	bool* vector3 = (bool*)malloc(M * sizeof(bool));

	//insert number into array
	add_array(vector1,N);

	//insert random elements to search
	random_ints(vector2,M);

	//create device array pointer
	int *d_vector1;
	int *d_vector2;
	bool *d_vector3;

	//allocate device memory for vector
	cudaMalloc(& d_vector1, size);
	cudaMalloc(& d_vector2, size2);
	cudaMalloc(& d_vector3, M*sizeof(bool));

	//copy vectors from host memory to dvice memory
	cudaMemcpy(d_vector1,vector1, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_vector2,vector2, size2, cudaMemcpyHostToDevice);

	//call kernal
	binary_search<<<M,1>>>(d_vector1, d_vector2, d_vector3,N);
	

	cudaMemcpy(vector3,d_vector3, M * sizeof(bool), cudaMemcpyDeviceToHost);

	for (int i = 0; i < M; i++)
	{
		if(vector3[i]==true)
			printf("%d is present in array\n",vector2[i]);
		else if(vector3[i] == 0)
			printf("%d is not present in array\n", vector2[i]);

	}
}
