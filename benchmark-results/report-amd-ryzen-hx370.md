# CPU Throttling Benchmark Report - AMD

**CPU:** AMD Ryzen AI 9 HX PRO 370 w/ Radeon 890M
**Date:** 2026-02-19 20:32
**Iterations:** 10  |  **Cooldown:** 30s

## Build Results

| Iteration | Start | Duration (s) | CPU Start (MHz) | CPU End (MHz) | Status |
|-----------|-------|-------------|----------------|--------------|--------|
| 1 | 19:38:45 | 198.1 | 2000 | 2000 | OK |
| 2 | 19:43:13 | 186.5 | 2000 | 2000 | OK |
| 3 | 19:59:36 | 151 | 2000 | 2000 | OK |
| 4 | 20:03:12 | 173.7 | 2000 | 2000 | OK |
| 5 | 20:07:12 | 177.4 | 2000 | 2000 | OK |
| 6 | 20:11:19 | 221.5 | 2000 | 2000 | OK |
| 7 | 20:16:08 | 186.5 | 2000 | 2000 | OK |
| 8 | 20:20:23 | 181.3 | 2000 | 2000 | OK |
| 9 | 20:24:32 | 191.1 | 2000 | 2000 | OK |
| 10 | 20:28:52 | 220.8 | 2000 | 2000 | OK |

## Summary

| Metric | Value |
|--------|-------|
| Min build time | 151s |
| Max build time | 221.5s |
| Avg build time | 188.8s |
| **Drift (iter 1 vs 10)** | **22.7s** |
| Min CPU freq seen | 2000 MHz |
| Max CPU freq seen | 2000 MHz |

> **Note on CPU frequency:** `Win32_Processor.CurrentClockSpeed` reports the base clock (2000 MHz) on
> this AMD CPU regardless of actual boost state. Real frequency during builds is ~3.5-5 GHz
> (confirmed via `% Processor Performance` counter). Frequency column is not meaningful for throttling
> detection on this machine - use `duration_sec` instead.

## ASCII Frequency Chart (start of each build)

```
Iter  1:  2000 MHz |########################################
Iter  2:  2000 MHz |########################################
Iter  3:  2000 MHz |########################################
Iter  4:  2000 MHz |########################################
Iter  5:  2000 MHz |########################################
Iter  6:  2000 MHz |########################################
Iter  7:  2000 MHz |########################################
Iter  8:  2000 MHz |########################################
Iter  9:  2000 MHz |########################################
Iter 10:  2000 MHz |########################################
```

## Conclusion

Throttling minimal: build time drift of only 22.7s (11.5%) between iteration 1 and 10.
No severe throttling detected - times stayed in the 151-221s range throughout.

CPU frequency: min 2000 MHz / max 2000 MHz (delta 0 MHz — WMI limitation on AMD, see note above).

> **For comparison:** run the same script on the Intel laptop and compare `drift` and `freq delta`.
