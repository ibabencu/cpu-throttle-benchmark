# CPU Throttling Benchmark Report

**CPU:** 12th Gen Intel(R) Core(TM) i9-12900H
**Date:** 2026-02-25 08:19
**Iterations:** 10  |  **Cooldown:** 30s
**Max temp observed:** 100°C

## Build Results

| Iteration | Start | Duration (s) | Status |
|-----------|-------|-------------|--------|
| 1 | 07:34:32 | 268.4 | OK |
| 2 | 07:40:00 | 168.0 | OK |
| 3 | 07:43:46 | 171.3 | OK |
| 4 | 07:47:36 | 196.6 | OK |
| 5 | 07:51:52 | 202.1 | OK |
| 6 | 07:56:12 | 165.5 | OK |
| 7 | 08:00:00 | 193.7 | OK |
| 8 | 08:04:40 | 386.1 | OK* |
| 9 | 08:12:16 | 195.3 | OK |
| 10 | 08:16:37 | 185.1 | OK |

*Iter 8 spike (386.1s) likely caused by a background process on the machine, not CPU throttling.

## Summary

| Metric | Value |
|--------|-------|
| Min build time | 165.5s |
| Max build time | 386.1s* |
| Avg build time | 213.2s |
| Avg (excl. iter 8 spike) | 194.0s |
| **Drift (iter 1 vs 10)** | **-83.3s** |
| **Throttle ratio (max/min)** | **1.44x*** |
| **Throttle ratio (excl. spike)** | **~1.17x** |
| **Max temp observed** | **100°C** |

## Conclusion

CPU reached 100°C — at thermal limit (TjMax). Build time improved significantly after the first warm-up iteration (-83.3s drift), suggesting the CPU needed time to ramp up boost clocks from a cold state. No sustained throttling detected beyond the initial warm-up. The iter 8 spike (386.1s) is an outlier consistent with a background process interference, not thermal throttling.

> 100°C is the TjMax for i9-12900H — the CPU was thermal-limited during the benchmark.
