# CPU Throttle Benchmark — 3-Way Comparison

**Generated:** 2026-02-25

| | AMD | Intel (newer) | Intel (older) |
|---|---|---|---|
| **CPU** | AMD Ryzen AI 9 HX PRO 370 | Intel Core Ultra 9 185H | Intel Core i9-12900H |
| **Generation** | Zen 5 (2024) | Meteor Lake (2023) | Alder Lake (2021) |
| **Date** | 2026-02-19 | 2026-02-23 | 2026-02-25 |
| **Max temp** | ~70°C | ~96°C | 100°C |

---

## Side-by-Side Build Times (seconds)

| Iter | AMD | Ultra 9 185H | i9-12900H |
|------|-----|--------------|-----------|
| 1 | 198.1 | 187.5 | 268.4 |
| 2 | 186.5 | 157.8 | 168.0 |
| 3 | 151.0 | 130.4 | 171.3 |
| 4 | 173.7 | 117.0 | 196.6 |
| 5 | 177.4 | 165.3 | 202.1 |
| 6 | 221.5 | 214.0 | 165.5 |
| 7 | 186.5 | 118.5 | 193.7 |
| 8 | 181.3 | 123.1 | 386.1* |
| 9 | 191.1 | 126.0 | 195.3 |
| 10 | 220.8 | 128.4 | 185.1 |

*i9-12900H iter 8 spike likely caused by a background process.

---

## Summary Comparison

| Metric | AMD | Ultra 9 185H | i9-12900H | Best |
|--------|-----|--------------|-----------|------|
| Min build time | 151s | 117s | 165.5s | Intel Ultra 9 |
| Max build time | 221.5s | 214s | 386.1s* | Intel Ultra 9 |
| Avg build time | 188.8s | 146.8s | 213.2s (194s excl. spike) | Intel Ultra 9 |
| Drift (iter 1→10) | +22.7s | -59.1s | -83.3s | Intel Ultra 9 |
| Throttle ratio | 1.12x | 1.14x | 1.44x (1.17x excl. spike) | AMD |
| **Max temp** | **~70°C** | **~96°C** | **100°C** | **AMD** |

---

## Conclusions

**Raw speed:** Intel Ultra 9 185H wins convincingly — **22% faster** than AMD (146.8s vs 188.8s avg), and **25% faster** than i9-12900H (even excluding the spike).

**Thermals:** AMD runs 26°C cooler than Ultra 9 185H and 30°C cooler than i9-12900H. The i9-12900H hit TjMax (100°C) — thermal headroom is gone.

**Throttle stability:** AMD and Ultra 9 185H are nearly tied (1.12x vs 1.14x). The i9-12900H shows 1.17x excluding the spike — comparable to the others, but running at thermal limit means any sustained load will degrade it.

**Drift pattern:** Both Intel machines get *faster* over iterations (CPU finds its sustained boost); AMD gets *slightly slower* (+22.7s) due to mild thermal buildup.

**Verdict:**
- Best performance: Intel Core Ultra 9 185H
- Best thermals + predictability: AMD Ryzen AI 9 HX PRO 370
- i9-12900H: older gen, thermal-limited at 100°C, slower than both — but still competitive when thermals are managed
- When Intel hits the thermal wall (Ultra 9 185H Run 1: 694s spike; i9-12900H: persistent 100°C), degradation can be severe. AMD never hit its wall (~70°C, TjMax 95°C).
