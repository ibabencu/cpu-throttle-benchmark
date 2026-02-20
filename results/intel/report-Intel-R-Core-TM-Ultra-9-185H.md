# CPU Throttling Benchmark Report

**CPU:** Intel(R) Core(TM) Ultra 9 185H
**Date:** 2026-02-20 18:22
**Iterations:** 10  |  **Cooldown:** 30s

## Build Results

| Iteration | Start | Duration (s) | CPU Start (MHz) | CPU End (MHz) | Status |
|-----------|-------|-------------|----------------|--------------|--------|
| 1 | 17:44:46 | 123.4 | 2300 | 2300 | OK |
| 2 | 17:47:36 | 120.3 | 2300 | 2300 | OK |
| 3 | 17:50:22 | 150.3 | 2300 | 2300 | OK |
| 4 | 17:53:39 | 694.3 | 2300 | 2300 | OK |
| 5 | 18:05:59 | 128.8 | 2300 | 2300 | OK |
| 6 | 18:08:53 | 123.8 | 2300 | 2300 | OK |
| 7 | 18:11:44 | 128.3 | 2300 | 2300 | OK |
| 8 | 18:14:40 | 154.4 | 2300 | 2300 | OK |
| 9 | 18:18:00 | 131 | 2300 | 2300 | OK |
| 10 | 18:20:58 | 116.7 | 2300 | 2300 | OK |

## Summary

| Metric | Value |
|--------|-------|
| Min build time | 116.7s |
| Max build time | 694.3s |
| Avg build time | 187.1s |
| **Drift (iter 1 vs 10)** | **-6.7s** |
| **Throttle ratio (max/min)** | **5.63x** |
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
