# Technical context

This is a living document. Update it when the development machine, toolchain, runtime, model family, or build assumptions change. Do not promote these details into root `AGENTS.md` unless they become enduring project constraints.

## Primary development machine

Current local target:

- Windows x64
- AMD Radeon RX 9070, RDNA4, HIP target `gfx1201`
- Ryzen 9 5900X
- 64 GB DDR4, approximately 3600 MT/s
- B550 platform, PCIe 4.0

The machine is also used for workstation and virtualization workloads, so changes that destabilize idle behavior, device initialization, memory ownership, or Windows interaction matter even when inference benchmarks look good.

## Build/runtime focus

Primary backend:

- HIP/ROCm
- `GGML_HIP=ON`
- `GPU_TARGETS=gfx1201`
- Release builds

Frequently relevant targets:

- `llama-cli`
- `llama-server`
- `test-backend-ops`

Avoid assuming CUDA behavior maps directly to HIP/RDNA4. Use current upstream backend abstractions and capability checks where possible.

## Model/workload profile

The current performance work centers on Qwen3.8/Qwen3.5-family dense ~27B models and related Fable/TurboFCFusion/NEO-CODER style variants.

Important workload characteristics:

- agentic coding and repository/software-architecture reasoning
- formal/math reasoning
- MTP/speculative behavior is important
- vision/OCR should remain supported
- long context is desirable, ideally around 128K where practical
- production runtime quantization floor is IQ4_XS unless the user explicitly changes it

Do not assume the exact checkpoint, quant, context length, or KV precision from old benchmark notes; confirm the active test matrix before drawing conclusions.

## Performance interpretation

Recent work has shown that this workload can be limited by more than shader throughput. Memory bandwidth, cache behavior, KV-cache footprint/traffic, allocator placement, graph scheduling, and recurrent-state access can materially affect tokens/sec and TTFT.

Core-clock scaling alone is not sufficient evidence of a compute bottleneck.

## Local-first constraint

Design and benchmark under the assumption that useful workflows should run locally on the user's system. Remote compute may be discussed as a comparison point, but do not make it a hidden dependency of the project.
