#include <iostream>
#include <algorithm>
#include <cuda.h>
using namespace std;

__global__ void knapsack(int n, int capacity, int* weights, int* values, int* solution, int* start) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid >= capacity + 1) {
        return;
    }
    for (int i = start[tid]; i < n; i++) {
        if (weights[i] <= tid) {
            int temp = solution[tid - weights[i]] + values[i];
            if (temp > solution[tid]) {
                solution[tid] = temp;
                start[tid] = i;
            }
        }
    }
}

int main() {
    int n = 5;
    int capacity = 10;
    int weights[] = {2, 3, 5, 4, 1};
    int values[] = {5, 6, 10, 9, 2};

    int* gpu_capacity, *gpu_weights, *gpu_values, *gpu_solution, *gpu_start;
    cudaMalloc(&gpu_capacity, sizeof(int));
    cudaMalloc(&gpu_weights, n * sizeof(int));
    cudaMalloc(&gpu_values, n * sizeof(int));
    cudaMalloc(&gpu_solution, (capacity + 1) * sizeof(int));
    cudaMalloc(&gpu_start, (capacity + 1) * sizeof(int));

    cudaMemcpy(gpu_capacity, &capacity, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(gpu_weights, weights, n * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(gpu_values, values, n * sizeof(int), cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (capacity + threadsPerBlock - 1) / threadsPerBlock;
    knapsack <<<blocksPerGrid, threadsPerBlock>>>(n, capacity, gpu_weights, gpu_values, gpu_solution, gpu_start);

    int* solution = new int[capacity + 1];
    cudaMemcpy(solution, gpu_solution, (capacity + 1) * sizeof(int), cudaMemcpyDeviceToHost);
    cout << "Maximum Value: " << solution[capacity] << endl;

    cudaFree(gpu_capacity);
    cudaFree(gpu_weights);
    cudaFree(gpu_values);
    cudaFree(gpu_solution);
    cudaFree(gpu_start);
    delete[] solution;
    return 0;
}
