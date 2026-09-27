# One-time generator for references/objects/8.4/_toc.md
# Reads the "Contents" page of each guide (or its first split part) and emits a
# unified chapter -> file -> page table. The TOC tells the model which split
# part covers which chapter, eliminating blind grepping on the big files.
# Run from repo root: pwsh -File .tools/gen-object-toc.ps1

param(
    [string]$Dir    = "references/objects/8.4",
    [string]$Output = "references/objects/8.4/_toc.md"
)

if (-not (Test-Path $Dir)) { throw "Source dir not found: $Dir" }

# Group files by their logical guide. Split parts share a base name with a _pNNN-MMM suffix.
$splitRx = [regex]'^(.+?)_p(\d+)-(\d+)\.txt$'
$files = Get-ChildItem $Dir -Filter *.txt | Where-Object { $_.Name -notlike '_*' }

$groups = @{}
foreach ($f in $files) {
    $base = $f.BaseName
    $parts = $null
    if ($f.Name -match $splitRx) {
        $base = $Matches[1]
    }
    if (-not $groups.ContainsKey($base)) {
        $groups[$base] = [ordered]@{
            Base  = $base
            Files = @()  # each: { Name, StartPage, EndPage }
        }
    }
    if ($f.Name -match $splitRx) {
        $groups[$base].Files += [pscustomobject]@{
            Name      = $f.Name
            StartPage = [int]$Matches[2]
            EndPage   = [int]$Matches[3]
        }
    } else {
        $groups[$base].Files += [pscustomobject]@{
            Name      = $f.Name
            StartPage = 1
            EndPage   = [int]::MaxValue
        }
    }
}

# Sort: each guide's split parts go in page order
foreach ($g in $groups.Values) {
    $g.Files = $g.Files | Sort-Object StartPage
}

function Get-PageMarkerLines {
    param([string]$Path)
    Select-String -Path $Path -Pattern '^===== Page (\d+)/(\d+) =====' | ForEach-Object {
        [pscustomobject]@{
            Line  = $_.LineNumber
            Page  = [int]$_.Matches[0].Groups[1].Value
            Total = [int]$_.Matches[0].Groups[2].Value
        }
    }
}

function Parse-TocEntries {
    param(
        [string]$Path,
        [int]$ContentsStartPage,
        [int]$ContentsEndPage
    )
    $markers = Get-PageMarkerLines -Path $Path
    $startMarker = $markers | Where-Object { $_.Page -eq $ContentsStartPage } | Select-Object -First 1
    $endMarker   = $markers | Where-Object { $_.Page -eq ($ContentsEndPage + 1) } | Select-Object -First 1
    if (-not $startMarker) { return @() }

    $lines = Get-Content $Path
    $startLine = $startMarker.Line  # 1-based; content starts on the next line
    $endLine   = if ($endMarker) { $endMarker.Line - 1 } else { [Math]::Min($startLine + 200, $lines.Count) }

    $entries = @()
    $seen = @{}  # de-dupe on "title|page"
    # TOC entries look like: "  Some Title 23"  — title (mixed case) followed by a trailing integer
    # We are deliberately lenient on whitespace inside the title.
    $entryRx = [regex]'^\s+(?<title>[A-Za-z][A-Za-z0-9 ,/&:\-\(\)\.'']*?)\s+(?<page>\d+)\s*$'
    for ($i = $startLine; $i -lt $endLine; $i++) {
        $line = $lines[$i]
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -match '^===== Page') { continue }
        if ($line -match '^\s*Contents\s*$') { continue }
        $m = $entryRx.Match($line)
        if ($m.Success) {
            $title = $m.Groups['title'].Value.Trim()
            $page  = [int]$m.Groups['page'].Value
            # Skip junk entries
            if ($title.Length -lt 3) { continue }
            if ($page -lt 1 -or $page -gt 1000) { continue }
            # Drop page-footer artifacts: every body page repeats the product title
            if ($title -match '^SailPoint\b') { continue }
            # De-duplicate
            $key = "$title|$page"
            if ($seen.ContainsKey($key)) { continue }
            $seen[$key] = $true
            $entries += [pscustomobject]@{ Title = $title; Page = $page }
        }
    }
    return $entries
}

function Find-PartForPage {
    param($Files, [int]$Page)
    foreach ($f in $Files) {
        if ($Page -ge $f.StartPage -and $Page -le $f.EndPage) { return $f.Name }
    }
    return $Files[0].Name
}

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# Object guides TOC \u2014 IIQ 8.4")
[void]$sb.AppendLine()
[void]$sb.AppendLine("Auto-generated from each guide's Contents page. Use this to jump straight to the right chapter (and the right split part) instead of grepping blindly across multi-hundred-KB files.")
[void]$sb.AppendLine()
[void]$sb.AppendLine("**How to use:** grep this file for your topic (e.g. ``ProvisioningPolicy``, ``Correlation Rule``), then open the listed file and search around the listed page. Page numbers are the canonical PDF page numbers preserved in the ``===== Page N/total =====`` markers inside each ``.txt`` file.")
[void]$sb.AppendLine()

foreach ($base in ($groups.Keys | Sort-Object)) {
    $g = $groups[$base]
    [void]$sb.AppendLine("## $base")
    [void]$sb.AppendLine()

    # Show file -> page range up front
    if ($g.Files.Count -gt 1) {
        [void]$sb.AppendLine("Split into $($g.Files.Count) parts:")
        foreach ($f in $g.Files) {
            [void]$sb.AppendLine("- ``$($f.Name)`` \u2014 pages $($f.StartPage)\u2013$($f.EndPage)")
        }
        [void]$sb.AppendLine()
    }

    # TOC pages are typically pages 3-7. We try 3..6 and pick the longest entry list.
    $bestEntries = @()
    $firstFile   = Join-Path $Dir $g.Files[0].Name
    for ($end = 3; $end -le 7; $end++) {
        $entries = Parse-TocEntries -Path $firstFile -ContentsStartPage 3 -ContentsEndPage $end
        if ($entries.Count -gt $bestEntries.Count) { $bestEntries = $entries }
    }

    if ($bestEntries.Count -eq 0) {
        [void]$sb.AppendLine("_(No Contents page detected.)_")
        [void]$sb.AppendLine()
        continue
    }

    [void]$sb.AppendLine("| Chapter | File | Page |")
    [void]$sb.AppendLine("|---|---|---|")
    foreach ($e in $bestEntries) {
        $part = Find-PartForPage -Files $g.Files -Page $e.Page
        [void]$sb.AppendLine("| $($e.Title) | ``$part`` | $($e.Page) |")
    }
    [void]$sb.AppendLine()
}

Set-Content -Path $Output -Value $sb.ToString() -Encoding UTF8
$sizeKB = [math]::Round((Get-Item $Output).Length / 1KB, 1)
Write-Host "Wrote $Output ($sizeKB KB)"
