# Current state and priorities

This is the short-horizon project brief. It is expected to change often.

## Current direction

The project is centered on the existing dense Qwen3.8/Qwen35-style ~27B workflow and on building reusable optimization/integration infrastructure around it.

The current strategic direction is **not** to pursue the earlier GLM compression path or the Qwen3.8-Flash-Next shrinking effort unless the user explicitly reopens those directions.

The longer-term model-engineering direction remains:

`dense base -> specialists/adapters -> sparse routing/MoE experimentation`

The intent is to improve both capability and throughput while preserving vision/OCR, MTP, and long-context behavior.

## Near-term priorities

1. Keep the private fork rebased conceptually on current llama.cpp rather than accumulating historical ROCmFPX architecture.
2. Validate already-ported RX 9070 optimizations on the real Windows/HIP machine.
3. Continue auditing historical donor commits one concept at a time and port only ideas that current upstream has not superseded.
4. Improve performance without dropping below the IQ4_XS quality floor for production artifacts.
5. Distinguish TTFT/prefill improvements from decode-throughput improvements.
6. Keep experimental paths opt-in and easy to remove if measurements do not justify them.
7. Preserve a clean agent/tooling environment through the repository-local Ponytail and Matt Pocock plugin integrations.

## Current benchmark expectations

Historical quality-focused dense runs have generally been in the mid-30 tokens/sec range, while some ROCm-native/faster model variants have approached roughly 40 tokens/sec with weaker reasoning quality.

The long-term aspiration remains materially higher throughput, including the earlier ~60 tokens/sec target, but treat that as a goal rather than a current baseline or guaranteed outcome.

Always replace these rough expectations with fresh measurements when evaluating a code change.

## Working branches and integration

Use `rx9070-port` as the private integration branch unless the user changes the branch strategy.

Optimization work should normally land through focused feature branches/PRs so individual concepts remain reviewable and reversible.

## Agent plugins

The repository now uses a local Codex marketplace for both:

- Ponytail
- Matt Pocock engineering skills

See the dedicated integration docs for install/update details. Do not recreate separate ad-hoc copies under `.agents/skills/`.
