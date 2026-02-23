# CPU Throttle Benchmark N/A AMD vs Intel Comparison

**Generated:** 2026-02-23 14:24

| | AMD | Intel |
|---|---|---|
| **CPU** | AMD Ryzen AI 9 HX PRO 370 w/ Radeon 890M | Intel(R) Core(TM) Ultra 9 185H |

---

## Side-by-Side Build Times

| Iter | AMD Duration (s) | AMD Freq Start (MHz) | Intel Duration (s) | Intel Freq Start (MHz) |
|------|-----------------|---------------------|-------------------|----------------------|
| 1 | 198.1 | 2000 | 187.5 | 2300 |
| 2 | 186.5 | 2000 | 157.8 | 2300 |
| 3 | 151 | 2000 | 130.4 | 2300 |
| 4 | 173.7 | 2000 | 117 | 2300 |
| 5 | 177.4 | 2000 | 165.3 | 2300 |
| 6 | 221.5 | 2000 | 214 | 2300 |
| 7 | 186.5 | 2000 | 118.5 | 2300 |
| 8 | 181.3 | 2000 | 123.1 | 2300 |
| 9 | 191.1 | 2000 | 126 | 2300 |
| 10 | 220.8 | 2000 | 128.4 | 2300 |

---

## Summary Comparison

| Metric | AMD | Intel | Winner |
|--------|-----|-------|--------|
| Min build time | 151s | 117s | Intel |
| Max build time | 221.5s | 214s | Intel |
| Avg build time | 188.8s | 146.8s | Intel |
| Drift (iter1 vs 10) | 22.7s | -59.1s | Intel |
| Throttle ratio | 1.12x | 1.14x | AMD |
| Min CPU freq | 2000 MHz | 2300 MHz | Intel |
| Max CPU freq | 2000 MHz | 2300 MHz | Intel |

---

## ASCII Frequency Charts

### AMD N/A AMD Ryzen AI 9 HX PRO 370 w/ Radeon 890M

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

### Intel N/A Intel(R) Core(TM) Ultra 9 185H

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

---

## Conclusion
- **Drift:** AMD=22.7s vs Intel=-59.1s N/A **Intel throttles less**
- **Throttle ratio:** AMD=1.12x vs Intel=1.14x N/A **AMD has less throttling**
- **Freq drop:** AMD 0 MHz delta vs Intel 0 MHz delta
- **Avg build time:** AMD=188.8s vs Intel=146.8s
