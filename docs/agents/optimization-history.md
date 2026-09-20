# Optimization history

This is a living record of private-fork optimization work and historical donor analysis. It is not a permanent instruction set.

## Source repositories

Primary upstream:

- `ggml-org/llama.cpp`

Private fork:

- `bryanwieg/llama.cpp`

Historical donor/archive:

- `bryanwieg/ROCmFPX-rx9070-archive`

Historical donor commits are evidence and implementation references, not merge targets. Audit current upstream before porting any concept.

## Ported optimization concepts

### Scheduler scratch arena trim

Historical source:

`7b08993509fd7718dd18e8c8ed839ddcc0d8874a`

Private-fork behavior is opt-in through `GGML_ROCM_ARENA_TRIM`.

Historical evidence showed large improvements on selected short/long Qwen workloads, but treat those numbers as historical rather than a current baseline.

A later current-API compile correction removed a stale `src_ctx` gate and fixed a `std::max` type mismatch without changing intended behavior.

### Prompt/prefill reserve

Historical source:

`69a36a358b152e6dbde9e6410ce1b7f2808ab3a7`

Gate:

`GGML_ROCM_PREFILL_RESERVE=1`

Purpose: pre-reserve the prompt graph for the full ubatch when the arena is small enough, primarily reducing TTFT/prefill cost rather than decode cost.

### Recurrent MTP2 state reserve

Historical source:

`6b8a2a0caccdc829c5c094337bd7ace2e65242b8`

Gate:

`GGML_ROCM_HOT_BUFFER_RESERVE=recurrent-mtp2`

Purpose: influence first-touch/allocation placement for the recurrent-state allocation on the target Windows/HIP workload.

### Indexed GDN recurrent-state access

Historical source:

`21edd46f773765db02bbae1d480bc68d1ed97115`

Gate:

`GGML_ROCM_GDN_INDEXED_STATE=single-v1`

Purpose: avoid a state-row gather by using indexed GDN recurrent-state bank access under a narrowly validated geometry/backend configuration.

This path includes capability/fallback handling and should remain narrow until stronger end-to-end evidence supports expansion.

## Historical parity decisions

A detailed commit-by-commit record of old-build behavior that was intentionally omitted, superseded, converted to configuration, or left for retest lives in [historical-working-build-parity.md](historical-working-build-parity.md).

Notably, the historical direct-write GDN fusion commit `6f688e7af125bf2b512160c9683b22e81d373038` is now considered **superseded**, because current llama.cpp contains native GDN cache-write fusion. Do not port the old WIP implementation unless current upstream's mechanism demonstrates a concrete regression on the target workload.

## Superseded or rejected historical work

The following historical concepts should not be replayed without new evidence:

- old MTP verification-row fix: current upstream MTP implementation superseded the historical failure mode
- old M-RoPE MTP draft-positioning fix: current upstream has newer draft position handling
- old vision/MTP boundary-crash workaround: historical implementation no longer maps cleanly to the current speculative path
- diagnostics-only commits
- gfx1151/RDNA3.5 MMQ geometry work for the RX 9070 target
- old HIP fast-math removal already addressed upstream
- speculative replay metrics already upstream/superseded
- old Qwen4 port superseded by current upstream model support

The historical prompt-cache rollback series is high blast radius and should be reconsidered only if current upstream demonstrates a reproducible problem that maps to the old issue.

## Benchmark discipline for historical ports

When revisiting any donor optimization:

1. Identify the exact historical source commit.
2. Explain the mechanism, not just the diff.
3. Check current upstream for equivalent or superseding behavior.
4. Port semantically to current APIs.
5. Keep the experiment isolated and opt-in.
6. Compare ON/OFF on the actual target hardware.
7. Record TTFT, decode throughput, correctness/output, MTP counts, context, quant, KV settings, and relevant flags.
8. Remove investigation-only scaffolding before merge.
