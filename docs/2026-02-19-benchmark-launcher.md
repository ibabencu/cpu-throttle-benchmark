# Benchmark Launcher Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create `C:/dev/run-benchmark.ps1` — un singur script care orchestrează tot benchmark-ul CPU throttling: preflight → restore → monitor vizibil → build loop → raport în Codium.

**Architecture:** Scriptul apelează `monitor-cpu.ps1` într-o fereastră PowerShell separată vizibilă (via `Start-Process`), rulează `benchmark-build.ps1` în aceeași fereastră, apoi deschide raportul în VSCodium. La final afișează mesaj să se închidă manual fereastra de monitor.

**Tech Stack:** PowerShell 5+, dotnet CLI 8.0, Git, VSCodium (`codium.cmd`)

---

### Task 1: Preflight checks

**Files:**
- Create: `C:/dev/run-benchmark.ps1`

**Step 1: Creează fișierul cu preflight checks**

```powershell
$dotnet  = "C:/Program Files/dotnet/dotnet.exe"
$git     = "C:/Program Files/Git/bin/git.exe"
$codium  = "C:/Users/ionut.babencu/AppData/Local/Programs/VSCodium/bin/codium.cmd"
$sln     = "C:/dev/studio/Studio/Studio.sln"
$repoDir = "C:/dev/studio/Studio"
$outDir  = "C:/dev/benchmark-results"
$monitor = "C:/dev/monitor-cpu.ps1"
$builder = "C:/dev/benchmark-build.ps1"

Write-Host "=== CPU Benchmark Launcher ===" -ForegroundColor Cyan

$errors = @()
if (-not (Test-Path $dotnet))  { $errors += "dotnet not found: $dotnet" }
if (-not (Test-Path $git))     { $errors += "git not found: $git" }
if (-not (Test-Path $sln))     { $errors += "Studio.sln not found: $sln" }
if (-not (Test-Path $monitor)) { $errors += "monitor-cpu.ps1 not found: $monitor" }
if (-not (Test-Path $builder)) { $errors += "benchmark-build.ps1 not found: $builder" }
if (-not (Test-Path $codium))  { $errors += "codium not found: $codium" }

if ($errors.Count -gt 0) {
    Write-Host "PREFLIGHT FAILED:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Preflight OK" -ForegroundColor Green
```

**Step 2: Verifică manual că căile sunt corecte**

```powershell
powershell -NoProfile -Command "Test-Path 'C:/Program Files/dotnet/dotnet.exe'"
# Expected: True

powershell -NoProfile -Command "Test-Path 'C:/dev/studio/Studio/Studio.sln'"
# Expected: True
```

---

### Task 2: dotnet restore

**Files:**
- Modify: `C:/dev/run-benchmark.ps1` (append)

**Step 1: Adaugă restore după preflight**

```powershell
Write-Host ""
Write-Host "Step 1/4: dotnet restore..." -ForegroundColor Yellow
& $dotnet restore $sln
if ($LASTEXITCODE -ne 0) {
    Write-Host "dotnet restore FAILED (exit $LASTEXITCODE)" -ForegroundColor Red
    exit 1
}
Write-Host "Restore OK" -ForegroundColor Green
```

---

### Task 3: Pornire monitor în fereastră separată

**Files:**
- Modify: `C:/dev/run-benchmark.ps1` (append)

**Step 1: Adaugă Start-Process pentru monitor**

```powershell
Write-Host ""
Write-Host "Step 2/4: Starting CPU monitor (new window)..." -ForegroundColor Yellow

$monitorProc = Start-Process powershell -ArgumentList @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", $monitor
) -PassThru

Write-Host "Monitor started (PID $($monitorProc.Id)) -> $outDir/cpu-metrics.csv" -ForegroundColor Green
Write-Host ">> Fereastra de monitor e vizibila - nu o inchide inca! <<" -ForegroundColor Magenta
Start-Sleep 3   # lasam monitorul sa porneasca si sa scrie header-ul
```

---

### Task 4: Build loop

**Files:**
- Modify: `C:/dev/run-benchmark.ps1` (append)

**Step 1: Adaugă apelul la benchmark-build.ps1**

```powershell
Write-Host ""
Write-Host "Step 3/4: Running build benchmark (10 iterations)..." -ForegroundColor Yellow
Write-Host "Estimated time: 60-90 minutes. Grab a coffee." -ForegroundColor DarkGray
Write-Host ""

& powershell -NoProfile -ExecutionPolicy Bypass -File $builder `
    -SolutionPath $sln `
    -RepoPath $repoDir `
    -OutputDir $outDir `
    -Iterations 10 `
    -CooldownSec 30

if ($LASTEXITCODE -ne 0) {
    Write-Host "Benchmark FAILED (exit $LASTEXITCODE)" -ForegroundColor Red
    Write-Host "Check logs in: $outDir" -ForegroundColor Yellow
    exit 1
}
```

---

### Task 5: Finalizare — mesaj monitor + deschide raport

**Files:**
- Modify: `C:/dev/run-benchmark.ps1` (append)

**Step 1: Adaugă mesajul final și deschiderea raportului**

```powershell
Write-Host ""
Write-Host "Step 4/4: Benchmark complete!" -ForegroundColor Green
Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "  INCHIDE ACUM fereastra 'monitor-cpu.ps1'" -ForegroundColor Magenta
Write-Host "  (fereastra PowerShell separata)          " -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""

$reportFile = "$outDir/report-amd-ryzen-hx370.md"

if (Test-Path $reportFile) {
    Write-Host "Opening report in VSCodium..." -ForegroundColor Cyan
    & $codium $reportFile
} else {
    Write-Host "Report not found at: $reportFile" -ForegroundColor Red
}

Write-Host ""
Write-Host "Results in: $outDir" -ForegroundColor Green
Write-Host "  - build-results.csv    (durate per iteratie)"
Write-Host "  - cpu-metrics.csv      (frecventa la fiecare 5s)"
Write-Host "  - report-amd-*.md      (raport final)"
Write-Host "  - iter-N.log           (build log per iteratie)"
```

---

### Task 6: Test end-to-end (smoke test)

**Step 1: Verifică că scriptul e valid sintactic**

```powershell
powershell -NoProfile -Command "& { . 'C:/dev/run-benchmark.ps1' }" 2>&1
# Expected: pornire cu preflight OK, apoi restore
# Daca vrei sa testezi fara sa rulezi build-ul complet, comenteaza temporar Task 4
```

**Step 2: Verifică că fereastra de monitor se deschide**

Rulează scriptul și confirmă că apare o fereastră PowerShell separată cu textul:
```
CPU monitor started -> C:/dev/benchmark-results/cpu-metrics.csv (every 5s). Ctrl+C to stop.
```

**Step 3: Run complet**

```powershell
powershell -ExecutionPolicy Bypass -File C:/dev/run-benchmark.ps1
```

Expected flow:
1. `Preflight OK`
2. `dotnet restore` output
3. Fereastră nouă cu monitor
4. Build loop cu 10 iterații
5. Mesaj roșu/magenta să închizi monitorul
6. VSCodium se deschide cu raportul

---

### Fișiere finale

| Fișier | Rol |
|--------|-----|
| `C:/dev/run-benchmark.ps1` | **Launcher principal** (nou) |
| `C:/dev/monitor-cpu.ps1` | Monitor CPU — neschimbat |
| `C:/dev/benchmark-build.ps1` | Build loop — neschimbat |
| `C:/dev/benchmark-results/` | Output: CSV-uri + raport |
