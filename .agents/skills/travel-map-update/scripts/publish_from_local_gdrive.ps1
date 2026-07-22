[CmdletBinding()]
param(
    [string]$SourceDirectory,
    [string]$RepositoryDirectory,
    [string]$CommitMessage = 'Publish travel maps from local Google Drive',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

if (-not $SourceDirectory) {
    $sourceCandidates = @(Get-ChildItem -LiteralPath 'G:\' -Directory | ForEach-Object {
        $candidate = Join-Path $_.FullName 'private\Trip2026\website'
        if (Test-Path -LiteralPath $candidate -PathType Container) {
            $candidate
        }
    })
    if ($sourceCandidates.Count -ne 1) {
        throw "Could not uniquely find G:\*\private\Trip2026\website. Pass -SourceDirectory explicitly."
    }
    $SourceDirectory = $sourceCandidates[0]
}

if (-not $RepositoryDirectory) {
    $RepositoryDirectory = Join-Path $PSScriptRoot '..\..\..\..'
}

$sourceRoot = [IO.Path]::GetFullPath($SourceDirectory)
$repoRoot = [IO.Path]::GetFullPath($RepositoryDirectory)

$htmlFiles = @(
    'all_days_hotels_spots_overall_map.html'
    'day1_day11_maps_index.html'
    'day1_hotels_spots_only_map.html'
    'day2_hotels_spots_only_map.html'
    'day3_hotels_spots_only_map.html'
    'day4_hotels_spots_only_map.html'
    'day5_hotels_spots_only_map.html'
    'day6_hotels_spots_only_map.html'
    'day7_hotels_spots_only_map.html'
    'day8_hotels_spots_only_map.html'
    'day9_hotels_spots_only_map.html'
    'day10_hotels_spots_only_map.html'
    'day11_hotels_spots_only_map.html'
)
$zipName = '2026_summer_roadtrip_maps_latest_rebuilt.zip'

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw "Google Drive folder not found: $sourceRoot"
}
if (-not (Test-Path -LiteralPath (Join-Path $repoRoot '.git'))) {
    throw "Git repository not found: $repoRoot"
}

$copyPlan = foreach ($name in $htmlFiles) {
    $source = Join-Path $sourceRoot $name
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Required map file not found: $source"
    }
    [pscustomobject]@{ Source = $source; DestinationName = $name }
}

$zipSource = Get-ChildItem -LiteralPath $sourceRoot -File |
    Where-Object { $_.Name -like '2026_summer_roadtrip_maps_latest_rebuilt*.zip' } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if (-not $zipSource) {
    throw "Map ZIP not found in: $sourceRoot"
}
$copyPlan += [pscustomobject]@{ Source = $zipSource.FullName; DestinationName = $zipName }

Write-Host "Source: $sourceRoot"
Write-Host "Repository: $repoRoot"
foreach ($item in $copyPlan) {
    Write-Host ("  {0} -> {1}" -f (Split-Path $item.Source -Leaf), $item.DestinationName)
}

if ($DryRun) {
    Write-Host 'Dry run complete. No files were changed.'
    exit 0
}

$branch = (& git -C $repoRoot branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or $branch -ne 'main') {
    throw "Run this script on the main branch. Current branch: $branch"
}

$remote = (& git -C $repoRoot remote get-url origin).Trim()
if ($LASTEXITCODE -ne 0 -or $remote -notmatch 'takahiro125-prog/Travel2026(?:\.git)?$') {
    throw "Unexpected origin remote: $remote"
}

$existingChanges = @(& git -C $repoRoot status --porcelain)
if ($LASTEXITCODE -ne 0) {
    throw 'Could not read Git status.'
}
if ($existingChanges.Count -gt 0) {
    throw 'The repository has uncommitted changes. Commit or remove them before publishing maps.'
}

Write-Host 'Synchronizing with origin/main...'
& git -C $repoRoot fetch origin main
if ($LASTEXITCODE -ne 0) {
    throw 'git fetch failed. Check the network connection and Git credentials.'
}

$localHead = (& git -C $repoRoot rev-parse HEAD).Trim()
$remoteHead = (& git -C $repoRoot rev-parse origin/main).Trim()
if ($localHead -ne $remoteHead) {
    & git -C $repoRoot merge-base --is-ancestor $localHead $remoteHead
    $localIsAncestor = $LASTEXITCODE -eq 0
    & git -C $repoRoot merge-base --is-ancestor $remoteHead $localHead
    $remoteIsAncestor = $LASTEXITCODE -eq 0

    if ($localIsAncestor) {
        & git -C $repoRoot merge --ff-only origin/main
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not fast-forward to origin/main.'
        }
    } elseif (-not $remoteIsAncestor) {
        & git -C $repoRoot rebase origin/main
        if ($LASTEXITCODE -ne 0) {
            & git -C $repoRoot rebase --abort 2>$null
            throw 'Could not rebase local commits onto origin/main.'
        }
    } else {
        Write-Host 'An unpushed local commit was found. It will be pushed below.'
    }
}

foreach ($item in $copyPlan) {
    Copy-Item -LiteralPath $item.Source -Destination (Join-Path $repoRoot $item.DestinationName) -Force
}

$publishNames = @($htmlFiles) + @($zipName)
& git -C $repoRoot add -- $publishNames
if ($LASTEXITCODE -ne 0) {
    throw 'git add failed.'
}

$staged = @(& git -C $repoRoot diff --cached --name-only)
if ($LASTEXITCODE -ne 0) {
    throw 'Could not inspect staged files.'
}
if ($staged.Count -eq 0) {
    Write-Host 'No new map file changes were found.'
} else {
    $unexpected = @($staged | Where-Object { $_ -notin $publishNames })
    if ($unexpected.Count -gt 0) {
        throw "Unexpected staged files: $($unexpected -join ', ')"
    }

    & git -C $repoRoot commit -m $CommitMessage
    if ($LASTEXITCODE -ne 0) {
        throw 'git commit failed.'
    }
}

$aheadCount = [int]((& git -C $repoRoot rev-list --count origin/main..HEAD).Trim())
if ($aheadCount -eq 0) {
    Write-Host 'GitHub is already up to date.'
    exit 0
}

$pushSucceeded = $false
for ($attempt = 1; $attempt -le 3; $attempt++) {
    Write-Host "Pushing to GitHub (attempt $attempt of 3)..."
    & git -C $repoRoot push origin main
    if ($LASTEXITCODE -eq 0) {
        $pushSucceeded = $true
        break
    }

    if ($attempt -lt 3) {
        Start-Sleep -Seconds 2
        & git -C $repoRoot fetch origin main
        if ($LASTEXITCODE -eq 0) {
            & git -C $repoRoot merge-base --is-ancestor origin/main HEAD
            if ($LASTEXITCODE -ne 0) {
                & git -C $repoRoot rebase origin/main
                if ($LASTEXITCODE -ne 0) {
                    & git -C $repoRoot rebase --abort 2>$null
                    throw 'GitHub changed during upload and automatic rebase failed.'
                }
            }
        }
    }
}

if (-not $pushSucceeded) {
    throw 'git push failed after 3 attempts. The local commit was kept; run Upload_2026tmap again to retry.'
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
Write-Host "Published successfully: $commit"
