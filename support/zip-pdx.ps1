# zip-pdx.ps1

# Get game name from pdxinfo
$name = (Get-Content source/pdxinfo | Select-String "^name=").ToString().Split("=")[1].Trim()

$src = "$name.pdx"
$dst = "$name.pdx.zip"

if (-not (Test-Path $src)) {
    throw "PDX folder not found: $src"
}

if (Test-Path $dst) {
    Remove-Item $dst -Force
}

# Use Windows bsdtar explicitly so -a + .zip gives a real ZIP file
$windowsTar = "$env:SystemRoot\System32\tar.exe"

& $windowsTar -a -cf $dst $src

Write-Output "Created: $dst"
