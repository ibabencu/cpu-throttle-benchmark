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
    "solution" = $sln
    "monitor"  = $monitor
    "builder"  = $builder
}

# codium is optional — only check if it exists
if (Test-Path $codium) {
    $preflightPaths["codium"] = $codium
} else {
    Write-Host "INFO: VSCodium not found at $codium - report will not auto-open." -ForegroundColor DarkGray
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
# STEP 1/4  -  DOTNET RESTORE + INITIAL BUILD (creates bin/obj directory structure)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 1/4: dotnet restore + initial build (one-time setup)..." -ForegroundColor Cyan
Write-Host "  This may take a few minutes on first run." -ForegroundColor DarkGray

Set-Location (Split-Path $sln)  # run from repo dir so global.json is picked up (SDK 8)
& $dotnet restore $sln
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: dotnet restore failed (exit code $LASTEXITCODE)." -ForegroundColor Red
    exit 1
}
Write-Host "dotnet restore completed successfully." -ForegroundColor Green

# Initial build: populates bin/obj dirs and all output files (runtimeconfig.json, deps.json, etc.)
# Without this, --no-incremental iterations fail because copy targets reference files that
# only exist after a successful initial build (UseAppHost=false for net8.0 skips app host generation,
# but these files are produced by the first full build and reused in subsequent --no-incremental runs).
$refRoot = "C:\dev\ref-assemblies\"
$nodeDir = "C:/Users/ionut.babencu/bin/node-v22.14.0-win-x64"
if ($env:PATH -notlike "*$nodeDir*") { $env:PATH = "$nodeDir;$env:PATH" }

Write-Host "  Running initial build (populates output dirs for first-time setup)..." -ForegroundColor DarkGray
& $dotnet build $sln --no-restore /p:TargetFrameworkRootPath="$refRoot" /p:RunAnalyzers=false `
    2>&1 | Where-Object { $_ -match "Error\(s\)|succeeded|FAILED|Build succeeded|Build FAILED" } |
    Select-Object -Last 3
Write-Host "  Initial build done (exit $LASTEXITCODE)." -ForegroundColor DarkGray

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

# Find the report — auto-detect filename (works on any CPU, not just AMD)
$reportFile = Get-ChildItem -Path $outDir -Filter "report-*.md" |
              Sort-Object LastWriteTime -Descending |
              Select-Object -First 1 -ExpandProperty FullName

if ($reportFile) {
    Write-Host "Report generated: $reportFile" -ForegroundColor Cyan
    if (Test-Path $codium) {
        Write-Host "Opening in VSCodium..." -ForegroundColor Cyan
        & $codium $reportFile
    } else {
        Write-Host "Open the report manually: $reportFile" -ForegroundColor Yellow
    }
} else {
    Write-Host "ERROR: No report-*.md found in $outDir" -ForegroundColor Red
    Write-Host "Check $outDir manually for build errors." -ForegroundColor Yellow
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
