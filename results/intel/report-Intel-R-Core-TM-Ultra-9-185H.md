# CPU Throttling Benchmark Report

**CPU:** Intel(R) Core(TM) Ultra 9 185H
**Date:** 2026-02-23 14:24
**Iterations:** 10  |  **Cooldown:** 30s

## Build Results

| Iteration | Start | Duration (s) | CPU Start (MHz) | CPU End (MHz) | Status |
|-----------|-------|-------------|----------------|--------------|--------|
| 1 | 13:31:04 | 187.5 | 2300 | 2300 | OK |
| 2 | 13:35:00 | 157.8 | 2300 | 2300 | OK |
| 3 | 13:38:27 | 130.4 | 2300 | 2300 | OK |
| 4 | 13:41:26 | 117 | 2300 | 2300 | OK |
| 5 | 13:44:17 | 165.3 | 2300 | 2300 | OK |
| 6 | 14:08:57 | 214 | 2300 | 2300 | OK |
| 7 | 14:13:20 | 118.5 | 2300 | 2300 | OK |
| 8 | 14:16:06 | 123.1 | 2300 | 2300 | OK |
| 9 | 14:18:57 | 126 | 2300 | 2300 | OK |
| 10 | 14:21:52 | 128.4 | 2300 | 2300 | OK |

## Summary

| Metric | Value |
|--------|-------|
| Min build time | 117s |
| Max build time | 214s |
| Avg build time | 146.8s |
| **Drift (iter 1 vs 10)** | **-59.1s** |
| **Throttle ratio (max/min)** | **1.14x** |
| Min CPU freq seen | 2300 MHz |
| Max CPU freq seen | 2300 MHz |

## ASCII Frequency Chart (start of each build)

```
Iter  1:  2300 MHz |########################################
Iter  2:  2300 MHz |########################################
Iter  3:  2300 MHz |########################################
Iter  4:  2300 MHz |########################################
Iter  5:  2300 MHz |########################################
Iter  6:  2300 MHz |########################################
Iter  7:  2300 MHz |########################################
Iter  8:  2300 MHz |########################################
Iter  9:  2300 MHz |########################################
Iter 10:  2300 MHz |########################################
```

## Conclusion

CPU s-a incalzit si s-a stabilizat - build time stabil sau mai rapid dupa warm-up.

Frecventa CPU: min 2300 MHz / max 2300 MHz (delta 0 MHz).

> **Pentru comparatie AMD vs Intel:** ruleaza compare-results.ps1 dupa ce ai rezultate de pe ambele masini.
