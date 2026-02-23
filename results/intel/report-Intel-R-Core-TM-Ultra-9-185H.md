# CPU Throttling Benchmark Report — Intel

**CPU:** Intel(R) Core(TM) Ultra 9 185H
**Date:** 2026-02-23 14:24
**Iterations:** 10  |  **Cooldown:** 30s
**Max temp observed:** ~96°C

## Build Results

| Iteration | Start | Duration (s) | Status |
|-----------|-------|-------------|--------|
| 1 | 13:31:04 | 187.5 | OK |
| 2 | 13:35:00 | 157.8 | OK |
| 3 | 13:38:27 | 130.4 | OK |
| 4 | 13:41:26 | 117 | OK |
| 5 | 13:44:17 | 165.3 | OK |
| 6 | 14:08:57 | 214 | OK |
| 7 | 14:13:20 | 118.5 | OK |
| 8 | 14:16:06 | 123.1 | OK |
| 9 | 14:18:57 | 126 | OK |
| 10 | 14:21:52 | 128.4 | OK |

## Summary

| Metric | Value |
|--------|-------|
| Min build time | 117s |
| Max build time | 214s |
| Avg build time | 146.8s |
| **Drift (iter 1 vs 10)** | **-59.1s** |
| **Throttle ratio (max/min)** | **1.14x** |
| **Max temp** | **~96°C** |

## Conclusion

Build time got faster over iterations (negative drift of 59.1s) — CPU warmed up and stabilized boost clocks. No severe throttling in this run. Throttle ratio of 1.14x is nearly identical to AMD (1.12x).

> Note: a previous run (Run 1) showed a catastrophic spike at iteration 4 (694s — 5.6x throttle ratio), caused by hitting the thermal wall at ~96°C. Thermal headroom is limited on this CPU.
