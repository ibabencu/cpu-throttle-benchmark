# =============================================================================
# run-benchmark.ps1
# CPU Throttling Benchmark Launcher for Windows
# Zero-argument launcher  -  all paths are hardcoded as variables below.
# =============================================================================

# ---------------------------------------------------------------------------
# PATH VARIABLES
# ---------------------------------------------------------------------------
$dotnet  = "C:/Program Files/dotnet/dotnet.exe"
$git     = "C:/Program Files/Git/bin/git.exe"
$codium  = "C:/Users/ionut.babencu/AppData/Local/Programs/VSCodium/bin/codium.cmd"
$sln     = "C:/dev/studio/Studio/Studio.sln"
$monitor = "C:/dev/monitor-cpu.ps1"
$builder = "C:/dev/benchmark-build.ps1"
$repoDir = "C:/dev/studio/Studio"
$outDir  = "C:/dev/benchmark-results"

# ---------------------------------------------------------------------------
# STEP 0  -  PREFLIGHT
# ---------------------------------------------------------------------------
Write-Host "=== CPU Benchmark Launcher ===" -ForegroundColor Cyan

$preflightPaths = @{
    "dotnet"   = $dotnet
    "git"      = $git
    "codium"   = $codium
    "solution" = $sln
    "monitor"  = $monitor
    "builder"  = $builder
}

$preflightOK = $true
foreach ($key in $preflightPaths.Keys) {
    $path = $preflightPaths[$key]
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: [$key] not found: $path" -ForegroundColor Red
        $preflightOK = $false
    }
}

if (-not $preflightOK) {
    Write-Host "Preflight FAILED  -  fix the missing paths above, then re-run." -ForegroundColor Red
    exit 1
}

Write-Host "Preflight OK" -ForegroundColor Green

# ---------------------------------------------------------------------------
# STEP 1/4  -  DOTNET RESTORE
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 1/4: dotnet restore..." -ForegroundColor Cyan

& $dotnet restore $sln
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: dotnet restore failed (exit code $LASTEXITCODE)." -ForegroundColor Red
    exit 1
}

Write-Host "dotnet restore completed successfully." -ForegroundColor Green

# ---------------------------------------------------------------------------
# STEP 2/4  -  START CPU MONITOR IN A NEW VISIBLE WINDOW
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 2/4: Starting CPU monitor (new window)..." -ForegroundColor Cyan

$monitorArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$monitor`""
$monitorProc = Start-Process "$PSHOME\powershell.exe" `
    -ArgumentList $monitorArgs `
    -PassThru

if ($null -eq $monitorProc) {
    Write-Host "ERROR: Failed to start CPU monitor process." -ForegroundColor Red
    exit 1
}

Write-Host "CPU monitor started  -  PID: $($monitorProc.Id)" -ForegroundColor Green
Write-Host ""
Write-Host "*** Fereastra de monitor e vizibila - nu o inchide inca! ***" -ForegroundColor Magenta
Write-Host ""

Write-Host "Waiting 3 seconds for monitor to initialize..." -ForegroundColor DarkGray
Start-Sleep -Seconds 3

# ---------------------------------------------------------------------------
# STEP 3/4  -  BUILD BENCHMARK LOOP
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 3/4: Running build benchmark (10 iterations)..." -ForegroundColor Cyan
Write-Host "Estimated time: 60-90 minutes. Grab a coffee." -ForegroundColor DarkGray
Write-Host ""

& "$PSHOME\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File $builder `
    -SolutionPath $sln `
    -RepoPath $repoDir `
    -OutputDir $outDir `
    -Iterations 10 `
    -CooldownSec 30

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: benchmark-build.ps1 failed (exit code $LASTEXITCODE)." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# STEP 4/4  -  FINALIZE
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 4/4: Benchmark complete!" -ForegroundColor Green
Write-Host ""

Write-Host "########################################################" -ForegroundColor Magenta
Write-Host "#                                                      #" -ForegroundColor Magenta
Write-Host "#   Benchmarkul s-a terminat.                          #" -ForegroundColor Magenta
Write-Host "#   Poti inchide acum fereastra de monitor CPU.        #" -ForegroundColor Magenta
Write-Host "#   (Apasa Ctrl+C in fereastra monitorului)            #" -ForegroundColor Magenta
Write-Host "#                                                      #" -ForegroundColor Magenta
Write-Host "########################################################" -ForegroundColor Magenta
Write-Host ""

# Open the report in Codium
$reportFile = "$outDir/report-amd-ryzen-hx370.md"
if (Test-Path $reportFile) {
    Write-Host "Opening report in Codium: $reportFile" -ForegroundColor Cyan
    & $codium $reportFile
} else {
    Write-Host "ERROR: Report file not found: $reportFile" -ForegroundColor Red
    Write-Host "The benchmark may not have generated the report yet. Check $outDir manually." -ForegroundColor Yellow
}

# Summary of output files
Write-Host ""
Write-Host "--- Output files in $outDir ---" -ForegroundColor Cyan
if (Test-Path $outDir) {
    Get-ChildItem -Path $outDir -File | Sort-Object LastWriteTime -Descending | ForEach-Object {
        $size = "{0,8:N0} KB" -f ($_.Length / 1KB)
        Write-Host ("  {0,-45} {1}  {2}" -f $_.Name, $size, $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"))
    }
} else {
    Write-Host "  (output directory does not exist: $outDir)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
