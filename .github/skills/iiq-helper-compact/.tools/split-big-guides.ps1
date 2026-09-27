# One-time splitter: chunks oversized object guides into ~60 KB page-aligned parts.
# Run from repo root: pwsh -File .tools/split-big-guides.ps1
# Files in $BigFiles are deleted and replaced with N parts named _pNNN-MMM.txt.

param(
    [int]$TargetKB = 60,
    [string]$Dir = "references/objects/8.4"
)

$BigFiles = @(
    "8.4_IdentityIQ_Reports.txt",
    "8.4_IdentityIQ_Certifications_and_Access_Reviews.txt",
    "8.4_IdentityIQ_System_Configuration.txt",
    "8.4_IdentityIQ_Role_Group_and_Population_Management.txt"
)

$targetBytes = $TargetKB * 1024

foreach ($file in $BigFiles) {
    $path = Join-Path $Dir $file
    if (-not (Test-Path $path)) { Write-Warning "Skipping missing $path"; continue }

    $raw = Get-Content $path -Raw
    $totalBytes = [System.Text.Encoding]::UTF8.GetByteCount($raw)
    Write-Host "Splitting $file ($([math]::Round($totalBytes/1KB,1)) KB)..."

    # Parse total page count from first page marker
    $totalPages = 0
    if ($raw -match '===== Page \d+/(\d+) =====') { $totalPages = [int]$Matches[1] }

    # Find every page-marker offset (byte position in the raw string is also char position for ASCII-leaning text)
    $markerRegex = [regex]'(?m)^===== Page (\d+)/\d+ =====\s*$'
    $matches = $markerRegex.Matches($raw)
    if ($matches.Count -eq 0) { Write-Warning "No page markers in $path; skipping"; continue }

    # Build page spans: pageNum -> [startCharIdx, endCharIdx)
    $spans = @()
    for ($i = 0; $i -lt $matches.Count; $i++) {
        $pageNum  = [int]$matches[$i].Groups[1].Value
        $startIdx = $matches[$i].Index
        $endIdx   = if ($i + 1 -lt $matches.Count) { $matches[$i+1].Index } else { $raw.Length }
        $spans += [pscustomobject]@{ Page = $pageNum; Start = $startIdx; End = $endIdx; Size = $endIdx - $startIdx }
    }

    # Greedy chunking aligned to page boundaries
    $chunks = @()
    $curStart = $spans[0].Start
    $curStartPage = $spans[0].Page
    $curSize = 0
    foreach ($s in $spans) {
        $curSize += $s.Size
        $isLast = ($s -eq $spans[-1])
        if ($curSize -ge $targetBytes -or $isLast) {
            $chunks += [pscustomobject]@{
                StartPage = $curStartPage
                EndPage   = $s.Page
                StartIdx  = $curStart
                EndIdx    = $s.End
            }
            # Reset for next chunk
            $nextIdx = [array]::IndexOf($spans, $s) + 1
            if ($nextIdx -lt $spans.Count) {
                $curStart = $spans[$nextIdx].Start
                $curStartPage = $spans[$nextIdx].Page
                $curSize = 0
            }
        }
    }

    # Width for padded page numbers
    $width = ([string]$totalPages).Length
    $base  = [System.IO.Path]::GetFileNameWithoutExtension($file)

    foreach ($c in $chunks) {
        $startStr = ([string]$c.StartPage).PadLeft($width, '0')
        $endStr   = ([string]$c.EndPage).PadLeft($width, '0')
        $partName = "${base}_p${startStr}-${endStr}.txt"
        $partPath = Join-Path $Dir $partName
        $body = $raw.Substring($c.StartIdx, $c.EndIdx - $c.StartIdx)
        Set-Content -Path $partPath -Value $body -Encoding UTF8 -NoNewline
        $sizeKB = [math]::Round((Get-Item $partPath).Length / 1KB, 1)
        Write-Host "  -> $partName  ($sizeKB KB, pages $($c.StartPage)-$($c.EndPage))"
    }

    Remove-Item $path
    Write-Host "  Removed original $file"
}

Write-Host "`nDone."
