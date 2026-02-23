# AMD vs Intel CPU Throttle Benchmark Comparison

**Generated:** 2026-02-23 14:24

| | AMD | Intel |
|---|---|---|
| **CPU** | AMD Ryzen AI 9 HX PRO 370 w/ Radeon 890M | Intel(R) Core(TM) Ultra 9 185H |
| **Max temp observed** | ~70°C | ~96°C |

---

## Side-by-Side Build Times

| Iter | AMD Duration (s) | Intel Duration (s) |
|------|-----------------|-------------------|
| 1 | 198.1 | 187.5 |
| 2 | 186.5 | 157.8 |
| 3 | 151 | 130.4 |
| 4 | 173.7 | 117 |
| 5 | 177.4 | 165.3 |
| 6 | 221.5 | 214 |
| 7 | 186.5 | 118.5 |
| 8 | 181.3 | 123.1 |
| 9 | 191.1 | 126 |
| 10 | 220.8 | 128.4 |

---

## Summary Comparison

| Metric | AMD | Intel | Winner |
|--------|-----|-------|--------|
| Min build time | 151s | 117s | Intel |
| Max build time | 221.5s | 214s | Intel |
| Avg build time | 188.8s | 146.8s | Intel |
| Drift (iter1 vs 10) | +22.7s | -59.1s | Intel |
| Throttle ratio | 1.12x | 1.14x | AMD |
| **Max temp** | **~70°C** | **~96°C** | **AMD** |

---

## Conclusion
- **Avg build time:** Intel is ~22% faster (146.8s vs 188.8s)
- **Throttle ratio:** essentially tied (1.14x vs 1.12x) — both CPUs sustain load similarly
- **Drift:** Intel gets *faster* over iterations (-59.1s); AMD gets *slower* (+22.7s)
- **Temperature:** AMD runs 26°C cooler (70°C vs 96°C) — significantly better thermal headroom
- **Verdict:** Intel wins on raw speed; AMD wins on thermals and predictability. When Intel hits its thermal wall (as in Run 1 with a 694s spike), it degrades catastrophically — AMD never does that.
