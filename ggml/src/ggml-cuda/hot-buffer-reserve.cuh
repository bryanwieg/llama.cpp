#pragma once

// Opt-in Windows/HIP placement experiment adapted from historical ROCmFPX
// commit 6b8a2a0caccdc829c5c094337bd7ace2e65242b8.
//
// Qwen3.8/Fable MTP max2 used a 448.875 MiB recurrent-state allocation: one
// live recurrent-state row plus two rollback rows. On the tested RX 9070,
// reserving and touching that exact-size allocation before model weights, then
// transferring ownership to the normal ggml buffer when the matching request
// arrives, improved decode throughput by about 17%.
//
// This is deliberately NOT a general allocator policy. It is Windows + HIP,
// device 0, exact-size matching, default OFF, and does not alter arithmetic,
// weights, quantization, recurrent-state semantics, or rollback behavior.
//
// Enable with:
//   GGML_ROCM_HOT_BUFFER_RESERVE=recurrent-mtp2
//
// If the expected allocation never claims the reservation, the run should be
// treated as an invalid performance experiment: the reserved memory remains
// held for the process lifetime.
#if defined(GGML_USE_HIP) && defined(_WIN32)

static bool ggml_rocm_mtp2_reserve_enabled() {
    static const bool enabled = [] {
        const char * value = getenv("GGML_ROCM_HOT_BUFFER_RESERVE");
        if (!value || strcmp(value, "0") == 0) {
            return false;
        }
        if (strcmp(value, "recurrent-mtp2") == 0) {
            return true;
        }

        GGML_ABORT(
            "Invalid GGML_ROCM_HOT_BUFFER_RESERVE for this build; "
            "use 0 or recurrent-mtp2");
    }();

    return enabled;
}

static cudaError_t ggml_rocm_mtp2_reserve_allocate(void ** result, size_t size, int device) {
    // Historical measured allocation: 448.875 MiB.
    static constexpr size_t recurrent_mtp2_capacity = 470679552;

    static std::mutex mutex;
    static void * reserved = nullptr;
    static bool initialized = false;
    static cudaError_t failure = cudaSuccess;

    std::lock_guard<std::mutex> lock(mutex);

    if (device != 0 || getenv("GGML_CUDA_ENABLE_UNIFIED_MEMORY") != nullptr) {
        GGML_ABORT(
            "recurrent-mtp2 hot-buffer reservation requires device 0 "
            "and ordinary device allocations");
    }

    if (!initialized) {
        initialized = true;

        failure = cudaMalloc(&reserved, recurrent_mtp2_capacity);
        if (failure == cudaSuccess) {
            // First-touch the allocation before model weights are placed.
            failure = cudaMemset(reserved, 0, recurrent_mtp2_capacity);
        }
        if (failure == cudaSuccess) {
            failure = cudaDeviceSynchronize();
        }

        if (failure != cudaSuccess) {
            if (reserved) {
                (void) cudaFree(reserved);
                reserved = nullptr;
            }
        } else {
            GGML_LOG_INFO(
                "rocm-mtp2-reserve: reserved recurrent state capacity=%zu data=%p\n",
                recurrent_mtp2_capacity, reserved);
        }
    }

    if (failure != cudaSuccess) {
        return failure;
    }

    // Windows device allocations are page-granular. Match within one 64 KiB
    // page while never handing a caller less memory than requested.
    if (reserved &&
        size <= recurrent_mtp2_capacity &&
        size > recurrent_mtp2_capacity - 65536) {
        *result = reserved;
        reserved = nullptr;

        GGML_LOG_INFO(
            "rocm-mtp2-reserve: claimed recurrent state requested=%zu capacity=%zu data=%p\n",
            size, recurrent_mtp2_capacity, *result);

        return cudaSuccess;
    }

    return ggml_cuda_device_malloc(result, size, device);
}

#endif
