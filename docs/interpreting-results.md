# Interpreting Results

After the benchmark finishes you'll have these files in `benchmark-results/`:

```
benchmark-results/
├── build-results.csv        ← build duration + CPU freq per iteration
├── cpu-metrics.csv          ← continuous CPU sampling every 5s
├── report-amd-ryzen-hx370.md ← auto-generated summary report
└── iter-N.log               ← raw build output for iteration N
```

---

## build-results.csv

```
iteration, start_time, end_time, duration_sec, freq_mhz_start, freq_mhz_end, exit_code
1, 2026-02-19 10:00:00, 2026-02-19 10:05:23, 323.4, 4800, 3200, 0
2, 2026-02-19 10:06:00, 2026-02-19 10:11:58, 358.1, 3200, 2900, 0
...
```

| Column | What it tells you |
|--------|-------------------|
| `duration_sec` | How long the build took — **key throttling indicator** |
| `freq_mhz_start` | CPU frequency at the start of the build |
| `freq_mhz_end` | CPU frequency at the end of the build |
| `exit_code` | 0 = build succeeded, anything else = failed |

**What to look for:**
- If `duration_sec` grows steadily across iterations → CPU is throttling and not recovering fully during cooldown
- If `freq_mhz_start` drops after iteration 3–4 → CPU hit thermal limit and reduced base clock

---

## cpu-metrics.csv

```
timestamp, freq_mhz, perf_pct, usage_pct
2026-02-19 10:00:05, 4800, 98.2, 95.1
2026-02-19 10:00:10, 4650, 95.0, 96.3
2026-02-19 10:00:15, 3800, 79.2, 97.1
...
```

| Column | What it tells you |
|--------|-------------------|
| `freq_mhz` | Actual running frequency (`Win32_Processor.CurrentClockSpeed`) |
| `perf_pct` | % of max frequency in use (`% Processor Performance` perf counter) |
| `usage_pct` | CPU utilization (`% Processor Time`) |

**What to look for:**
- `freq_mhz` dropping while `usage_pct` stays at 95–100% → active throttling
- `perf_pct` below 80% during sustained load → significant thermal constraint
- Recovery speed during 30s cooldown = how quickly clock returns to boost levels

---

## The Report

The auto-generated `report-*.md` contains:

1. **Build results table** — all 10 iterations with duration + freq
2. **Summary metrics** — min/max/avg build time, drift, freq range
3. **ASCII frequency chart** — visual of clock speed at start of each build
4. **Conclusion** — auto-detected verdict: minimal / detected / stable throttling

### Key metric: Drift

```
Drift = duration[iteration 10] - duration[iteration 1]
```

- `drift < 5s` → negligible throttling
- `drift 5–30s` → moderate throttling
- `drift > 30s` → significant throttling — CPU can't sustain boost under sustained load

---

## Comparing AMD vs Intel

Once you have both reports, look at:

| What to compare | Why |
|----------------|-----|
| Drift (iter 1 vs 10) | Who throttles more aggressively? |
| Freq drop magnitude | How much does boost clock degrade? |
| Recovery speed | Does freq recover fully in 30s? |
| Build time variance | Higher variance = less consistent performance |

A well-cooled machine should show:
- `drift < 10s`
- `freq_mhz_start` roughly consistent across all iterations
- `perf_pct` > 90% throughout
