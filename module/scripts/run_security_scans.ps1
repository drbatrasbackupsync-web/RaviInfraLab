# PowerShell Script to run Terraform Security, Quality & Cost Scans

param (
    [string]$TargetDir = "d:\Study\Practice\12_07_2026\module\dev",
    [string]$ToolsDir = "$env:LOCALAPPDATA\TerraformSecurityTools"
)

$env:PATH = "$ToolsDir;$env:PATH"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Starting Terraform Security & Analysis Scans" -ForegroundColor Cyan
Write-Host " Target Directory: $TargetDir" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. TFLint Scan
Write-Host "`n[1] Running TFLint (Terraform Linter)..." -ForegroundColor Yellow
$tflint = Get-Command tflint -ErrorAction SilentlyContinue
if ($tflint) {
    Set-Location $TargetDir
    & $tflint.Path --init
    & $tflint.Path --recursive
} else {
    Write-Host " -> TFLint not found in PATH." -ForegroundColor Red
}

# 2. TFSec Scan
Write-Host "`n[2] Running TFSec (Security Analysis)..." -ForegroundColor Yellow
$tfsec = Get-Command tfsec -ErrorAction SilentlyContinue
if ($tfsec) {
    & $tfsec.Path $TargetDir
} else {
    Write-Host " -> TFSec not found in PATH." -ForegroundColor Red
}

# 3. Gitleaks Scan
Write-Host "`n[3] Running Gitleaks (Secret Detection)..." -ForegroundColor Yellow
$gitleaks = Get-Command gitleaks -ErrorAction SilentlyContinue
if ($gitleaks) {
    & $gitleaks.Path detect --source $TargetDir --verbose
} else {
    Write-Host " -> Gitleaks not found in PATH." -ForegroundColor Red
}

# 4. Infracost Breakdown
Write-Host "`n[4] Running Infracost (Cost Estimation)..." -ForegroundColor Yellow
$infracost = Get-Command infracost -ErrorAction SilentlyContinue
if ($infracost) {
    & $infracost.Path breakdown --path $TargetDir
} else {
    Write-Host " -> Infracost not found in PATH." -ForegroundColor Red
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host " Scans completed!" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
