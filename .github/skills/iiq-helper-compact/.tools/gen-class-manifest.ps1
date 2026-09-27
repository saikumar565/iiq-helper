# One-time generator for references/JavaDocs/8.4/_classes.md
# Parses allclasses-noframe.html and produces an alphabetical class -> relative-path map.
# Run from repo root: pwsh -File .tools/gen-class-manifest.ps1

param(
    [string]$Source = "references/JavaDocs/8.4/allclasses-noframe.html",
    [string]$Output = "references/JavaDocs/8.4/_classes.md"
)

if (-not (Test-Path $Source)) { throw "Source not found: $Source" }

$html = Get-Content $Source -Raw

# Match <li><a href="path.html" title="kind in package">DisplayName</a></li>
# Interfaces wrap the display name in <span class="interfaceName">...</span>; handle both.
$rx = [regex]'<li><a href="([^"]+\.html)" title="([^"]+)">(?:<span[^>]*>)?([^<]+)(?:</span>)?</a></li>'
$matches = $rx.Matches($html)
if ($matches.Count -eq 0) { throw "No class entries found in $Source" }

# Build entries grouped by package
$entries = foreach ($m in $matches) {
    $href    = $m.Groups[1].Value
    $title   = $m.Groups[2].Value   # e.g. "class in sailpoint.object"
    $display = $m.Groups[3].Value
    $pkg     = if ($title -match 'in ([\w\.]+)$') { $Matches[1] } else { '' }
    $kind    = if ($title -match '^(\w+) in') { $Matches[1] } else { 'class' }
    [pscustomobject]@{
        Display = $display
        Href    = $href
        Package = $pkg
        Kind    = $kind
    }
}

$byPkg = $entries | Group-Object Package | Sort-Object Name

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# JavaDocs class manifest \u2014 IIQ 8.4")
[void]$sb.AppendLine()
[void]$sb.AppendLine("Auto-generated from ``allclasses-noframe.html``. Use this to jump straight to a class file instead of grepping.")
[void]$sb.AppendLine()
[void]$sb.AppendLine("**Paths are relative to ``references/JavaDocs/8.4/``.**")
[void]$sb.AppendLine()
[void]$sb.AppendLine("Total: $($entries.Count) classes/enums/interfaces across $($byPkg.Count) packages.")
[void]$sb.AppendLine()

# Alphabetical master index first
[void]$sb.AppendLine("## Alphabetical index")
[void]$sb.AppendLine()
[void]$sb.AppendLine("| Class | Kind | Path |")
[void]$sb.AppendLine("|---|---|---|")
foreach ($e in ($entries | Sort-Object Display)) {
    [void]$sb.AppendLine("| ``$($e.Display)`` | $($e.Kind) | ``$($e.Href)`` |")
}
[void]$sb.AppendLine()

# By-package sections
[void]$sb.AppendLine("## By package")
[void]$sb.AppendLine()
foreach ($g in $byPkg) {
    [void]$sb.AppendLine("### ``$($g.Name)``  ($($g.Count) entries)")
    [void]$sb.AppendLine()
    foreach ($e in ($g.Group | Sort-Object Display)) {
        [void]$sb.AppendLine("- ``$($e.Display)`` \u2192 ``$($e.Href)``")
    }
    [void]$sb.AppendLine()
}

Set-Content -Path $Output -Value $sb.ToString() -Encoding UTF8
$sizeKB = [math]::Round((Get-Item $Output).Length / 1KB, 1)
Write-Host "Wrote $Output ($sizeKB KB, $($entries.Count) entries)"
