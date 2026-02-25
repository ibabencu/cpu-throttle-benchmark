$refRoot  = "C:\dev\ref-assemblies\.NETFramework"
$nuget461 = "C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.6.1"
$sys472   = "C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.7.2"
$sys481   = "C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8.1"

New-Item -ItemType Directory -Path $refRoot -Force | Out-Null

foreach ($pair in @(
    @{ link = "$refRoot\v4.6.1"; target = $nuget461 },
    @{ link = "$refRoot\v4.7.2"; target = $sys472   },
    @{ link = "$refRoot\v4.8.1"; target = $sys481   }
)) {
    if (-not (Test-Path $pair.link)) {
        $null = New-Item -ItemType Junction -Path $pair.link -Target $pair.target
        Write-Host "Created junction: $($pair.link) -> $($pair.target)"
    } else {
        Write-Host "Already exists: $($pair.link)"
    }
}

Write-Host "Done. Contents of $refRoot :"
Get-ChildItem $refRoot
