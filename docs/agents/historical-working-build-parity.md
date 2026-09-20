# Historical working-build parity reference

This document records behavior-changing commits that existed in the previous working lineage from `bryanwieg/ROCmFPX-rx9070-archive`, especially `optimization/indexed-gdn-single-v1`, but were intentionally **not** carried into the current `bryanwieg/llama.cpp` fork.

Its purpose is to prevent future agents from rediscovering the same commits and blindly replaying them. Historical commits are implementation evidence, not merge instructions.

The current fork already carries the separately ported performance concepts documented in [optimization-history.md](optimization-history.md), plus the allocator view-split correctness fix from historical commit `00d54526e24e3aba4c76474e3147cbf9c7cc034c`.

## Decision rules

Use these classifications:

- **Superseded**: current llama.cpp already implements the same behavior or has redesigned the subsystem so the old patch no longer applies.
- **Retest**: the old failure may still matter, but the current implementation is different enough that the historical patch should not be replayed directly.
- **Configure**: preserve the old behavior through current upstream configuration instead of source changes.
- **Optional**: small compatibility or experimental behavior that is not required for the current target workflow.
- **Reference only**: diagnostics, historical investigation scaffolding, or test-only work with no production parity value.
- **Separate feature**: meaningful old-fork functionality that is outside the current IQ4_XS/Qwen target and should be evaluated independently.

## Omitted commit table

| Commit | Historical behavior | Classification | Why it is omitted now | Possible future relevance |
| --- | --- | --- | --- | --- |
| `6f688e7af125bf2b512160c9683b22e81d373038` | Fused GDN state snapshot writeback directly into recurrent cache | **Superseded** | Current llama.cpp has native CUDA/HIP GDN cache-write fusion through `ggml_cuda_try_gdn_cache_fusion()` and `ggml_cuda_op_gated_delta_net_fused_cache()`. Replaying the WIP fork implementation would duplicate newer upstream architecture. | Revisit only if the upstream fusion is measurably slower or incorrect on gfx1201. Compare mechanisms before changing code. |
| `4bf039f0beecbb697cd3be11e833c73bf9470d78` | Retained all MTP verification rows | **Superseded** | The current MTP implementation has different verification and deferred-boundary state management. The historical failure mode no longer maps directly. | Use only as debugging history if a new MTP row-lifetime bug appears. |
| `77b633481ef43cdca873acc02f8735a16c7bb1d6` | Initial speculative prompt-cache trailing rollback | **Superseded** | This was v1 even inside the old fork and was replaced by later rollback designs. Current server checkpointing is newer again. | Historical explanation of why exact-prefix-only cache reuse was expensive for long agent conversations. |
| `a393c3a88a96d2a5abecdeb4b19dedb1b6edf05e` | Checkpoint-based speculative rollback | **Superseded** | Current server checkpoints save target, draft, and speculative implementation state and restore them together. | Useful reference if checkpoint restore loses speculative state in a future regression. |
| `560c4d468a303ae8434173fa70343701983c6161` | MTP boundary-ring rollback after trailing memory removal | **Superseded** | Current Qwen35 has recurrent rollback support and speculative state has been redesigned. Porting the old ring would compete with current state ownership. | Reference only if current rollback cannot recover a valid Qwen35 MTP boundary. |
| `19b08a5a8d4997bfaeaf69b39869cee8c93e1080` | Pushed every batch/verify row into the MTP rollback ring | **Superseded** | Follow-up to the obsolete boundary-ring architecture. | Same as above; useful only as historical debugging context. |
| `1092b44c4a68f6427589f324619a89a511f6e3e7` | Fell back to a context checkpoint when divergence exceeded the rollback ring | **Superseded** | Current server already searches context checkpoints, restores target/draft memory, and restores speculative state with `common_speculative_set_state()`. | Revisit only if long-context prompt divergence still causes full cold reprocessing where a valid checkpoint exists. |
| `b5edff093d4560000e87ba85341447e16a7b9d22` | Added leading newline to forced reasoning-end sequence for cache round-trip consistency | **Superseded** | Current Qwen parser prefers `"\n</think>"` before `"</think>"`, so the newline is part of the forced end sequence. | Regression reference if a reasoning-budget boundary again changes tokenization after client resend. |
| `dfc439dc11f2bfc52c452add072bb5da1d916104` | Avoided abort when MTP boundary was missing after a vision chunk | **Retest** | Current speculative/MTP code is substantially different, so the old workaround should not be transplanted. | Test current vision+MTP. If the failure still exists, fix the current boundary/state model rather than replaying this patch. |
| `7d43016f46ba868be4ea83e9182cede8b8974311` | Passed M-RoPE position explicitly to draft MTP instead of overloading `n_past` | **Superseded** | Current speculative APIs have newer position handling and explicit next-position semantics. | Historical reference if M-RoPE draft positioning regresses. |
| `61b71b5a2b7a866c921ef0b619fb61e16e2b5b4a` | Earlier M-RoPE position-via-`n_past` attempt | **Reference only** | The old fork itself reverted/replaced it. | None unless reconstructing the history of the M-RoPE bug. |
| `06b38c6814b61d7395ef27007eaefd4cd6cf7ed2` | Reverted the earlier M-RoPE attempt | **Reference only** | Revert/history commit, not a feature. | None. |
| `1781bd0d6ed0d6e8482f0bb4ecbe409ca0c97aa2` | Passed `pos_next` in speculative-simple example | **Superseded** | Current speculative interfaces have changed. | Only relevant if the example again fails due to position initialization. |
| `09b36d273c3c0d2838ef60d2f4c9b958500edabf` | Corrected accepted-token accounting during speculative replay | **Superseded** | Current server has explicit speculative replay state and newer acceptance handling. | Use as a regression reference if replay metrics or acceptance counts become inconsistent. |
| `4321c85ccd1752c7a46e738fba4cd3cfe9e68261` | Snapshotted/restored speculative state with context checkpoints | **Superseded** | This concept is now present in current llama.cpp: checkpoints carry speculative state and restore it explicitly. | Important historical provenance for the now-upstream-style mechanism. |
| `4eca07e5a409a57b0a292e98ad8a975f251c3d8a` / `a3656bbf0889b3ce54a6f3b426a5d40b69f74ecf` | Broke speculative replay livelock after repeated checkpoint restore | **Superseded** | Current replay/checkpoint code has changed enough that the old guard does not map safely. | Retest if repeated checkpoint restore can again livelock current server code. |
| `b5562f8c475a9e694f2f07b78c2ed68b407aef02` | Accepted `thinking_token_budget` as an API alias | **Optional** | Current server already accepts `reasoning_budget_tokens` and `thinking_budget_tokens`; the exact vLLM-style alias is not required by the current workflow. | Port if an actual client in use sends `thinking_token_budget`. This should remain a tiny compatibility patch. |
| `de37bcb215e5929f233b26a9316c3558e34b0719` | Added strict exact-greedy Qwen35/Qwen35MoE MTP mode | **Optional** | The validated RX 9070 performance runs used strict MTP off, and current MTP architecture has changed. | Revisit only if exact-greedy draft behavior becomes a desired experiment or debugging control. |
| `d0fae4ded01228a0e51137f110eb379bb9c6ccd0` | Staged large mmap host-to-device HIP uploads through a pinned bounce buffer | **Retest** | Original hang was reproduced on gfx1151/ROCm with a very large model. A global serialized staging path adds complexity and should not be carried without reproducing the failure on gfx1201. | Test very large mmap model loading on RX 9070. Port a current-form workaround only if the SDMA/pageable-memory hang reproduces. |
| `b3c0576517793f61bb63b00e714712374a82960d` | Built every FlashAttention K/V quant combination by default | **Configure** | Current llama.cpp replaced the old boolean policy with `GGML_CUDA_FA_QUANTS`. The old source patch is unnecessary. | For old-build mixed-KV parity, build with `-DGGML_CUDA_FA_QUANTS=all`. |
| `a5984b3c5c1b59c6f7a4d8f8ccff85af31511efc` | Build scripts auto-selected the installed HIP GPU architecture | **Optional/tooling** | This was local build convenience, not inference behavior. The current project explicitly targets `gfx1201`. | Adapt the idea into current build scripts if automatic local target selection becomes useful. |
| `a087b5d2468583e2ce849881260778814d8201fe` | Centered fabricated scale tensors correctly in a test | **Reference only** | Test-only and no current runtime parity requirement. | Port only if the equivalent current test still has the same defect. |
| `f2693e5c6fea906f683b6714be2ec91c4c05c032` | Added prompt timing and allocation-layout diagnostics | **Reference only** | Investigation scaffolding, not production behavior. | Mine it for instrumentation ideas during a targeted performance investigation; do not carry it wholesale. |
| `8e6277f855df2a27ce072525ed19f3adc4138c47` | Removed HIP `-ffast-math` to match upstream | **Superseded** | It was already a catch-up-to-upstream change when committed. | None unless a future build configuration reintroduces unsafe fast-math behavior. |
| `5ed0d9ef03b4fba17c1cefa6f987dd5380bf2fef` | Claimed CUDA/HIP NORM support only for contiguous rows | **Superseded** | Current CUDA backend explicitly checks `ggml_is_contiguous_rows()` for NORM/RMS_NORM/L2_NORM. | Regression reference only. |
| `7b02624ee79678d253494a792bfde01bca3cd63c`, `52906256ad52fad3a1121f1f589a3fe8d5c03305`, `5466f3bb078ac89ff99105fbfade6e604c0c316d`, `29bd789e24b66c5eaf6eaaf90fa67c22130a334f` | NVFP4 conversion, lm_head scale handling, quantize target, mixed compressed-tensors support | **Superseded** | Current llama.cpp has native NVFP4 types/conversion paths, scale sidecars, and compressed-tensors mixed-precision handling. | Relevant only for regression archaeology around NVFP4 conversion. |
| `95bb4c798ee8c571e6b34ba4dd0ce15f4c2b9232` / `4b53e333a375cc4bcbad9e64f3c1a0ce9b4fda3c` | Laguna/LFM tokenizer hash mappings | **Superseded** | Current conversion code has native tokenizer detection for these families. | Regression reference if conversion emits unknown pre-tokenizer warnings again. |
| `22686453717b8e5fb9365a73a291dd0e562dd2f1` | Large ROCmFP4/FPX bundle: quantizer speedups, CPU dot, GPU decode, quant routing, FA graph safety, numerical hardening | **Separate feature / investigate by sub-patch** | The aggregate commit touches many unrelated subsystems and has too large a blast radius to preserve wholesale, especially while IQ4_XS currently tests comparably well. | Keep ROCmFP4 as an investigation path. Extract only isolated sub-patches with clear value on RX 9070 and low blast radius. Do not revive ROCmI4/IU4 as part of this effort. |

## ROCmFP4 policy

ROCmFP4 remains potentially useful for investigation, but it is not currently a required production format.

Current working assumption:

- IQ4_XS is the production quality floor and has so far tested as good as ROCmFP4 for the workloads that matter.
- Do not import the historical ROCmFP4/FPX aggregate patch wholesale.
- Audit ROCmFP4 improvements one mechanism at a time.
- Keep a sub-patch only when it is isolated, understandable, low blast radius, and produces a measurable benefit on the RX 9070.
- Do not use ROCmFP4 work as a reason to reintroduce ROCmI4/IU4 or gfx1151-specific tuning.

Potentially interesting pieces from `22686453...` include:

1. ROCmFP4 quantization-search speedups.
2. AVX2 CPU vec-dot for the ROCmFP4 representation.
3. HIP FlashAttention graph-capture safety for quantized KV paths, if current upstream does not already provide an equivalent.
4. MTP-aware quant routing only if current conversion/quantization paths demonstrate a concrete quality problem.

Treat the broad numerical-hardening edits and FP3/FP6/FP8 changes as separate concerns, not prerequisites for ROCmFP4.

## Parity checklist

For practical parity with the former working build, future agents should think in terms of **behavior**, not commit count.

Current checklist:

- [x] scheduler scratch-arena trim ported
- [x] prompt/prefill reserve ported
- [x] MTP2 recurrent-state reserve ported
- [x] indexed GDN recurrent-state access ported
- [x] allocator zero-size-view split fix ported or queued in the current fork
- [x] direct GDN cache-write fusion provided by current upstream
- [x] speculative checkpoint state save/restore provided by current upstream
- [x] reasoning-end newline behavior provided by current upstream
- [ ] build with `GGML_CUDA_FA_QUANTS=all` when mixed K/V cache type coverage is required
- [ ] verify current vision+MTP behavior before declaring that old workaround unnecessary for the active model
- [ ] test very-large-model mmap loading on RX 9070 before deciding whether HIP pinned staging is needed
- [ ] optionally add `thinking_token_budget` compatibility only if a real client needs it
- [ ] investigate ROCmFP4 only through isolated low-blast-radius sub-patches

## How to revisit an omitted commit

Before reviving anything from this table:

1. Reproduce the old failure or demonstrate the missing behavior on the current `rx9070-port` lineage.
2. Inspect current `ggml-org/llama.cpp` for equivalent or newer machinery.
3. Explain why configuration or existing APIs are insufficient.
4. Port the mechanism semantically to current code; do not blindly cherry-pick.
5. Keep unrelated donor changes out.
6. Validate correctness first, then measure performance where relevant.
7. Update this document with the resulting decision so the same audit is not repeated later.
