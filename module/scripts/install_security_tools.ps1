# PowerShell Script to install Terraform Security & Cost Analysis Tools on Windows
# Downloads direct binaries for TFLint, TFSec, Infracost, and Gitleaks

param (
    [string]$InstallDir = "$env:LOCALAPPDATA\TerraformSecurityTools"
)

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Installing Terraform Security & Optimization Suite..." -ForegroundColor Cyan
Write-Host " Target Directory: $InstallDir" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
}

$env:PATH += ";$InstallDir"

# Helper Function: Download & Extract Zip
function Download-And-ExtractZip {
    param ($Url, $ZipName, $ExeName)
    $ZipPath = Join-Path $InstallDir $ZipName
    $ExePath = Join-Path $InstallDir $ExeName

    if (-not (Test-Path $ExePath)) {
        Write-Host " -> Downloading $ExeName from $Url..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $Url -OutFile $ZipPath -UseBasicParsing
        Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force
        Remove-Item $ZipPath -ErrorAction SilentlyContinue
        Write-Host " -> Installed $ExeName successfully." -ForegroundColor Green
    } else {
        Write-Host " -> $ExeName is already installed at $ExePath." -ForegroundColor Green
    }
}

# Helper Function: Download Single Exe/Tar
function Download-File {
    param ($Url, $FileName)
    $FilePath = Join-Path $InstallDir $FileName
    if (-not (Test-Path $FilePath)) {
        Write-Host " -> Downloading $FileName from $Url..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $Url -OutFile $FilePath -UseBasicParsing
        Write-Host " -> Downloaded $FileName successfully." -ForegroundColor Green
    } else {
        Write-Host " -> $FileName is already installed at $FilePath." -ForegroundColor Green
    }
}

# 1. Install TFLint
Write-Host "`n[1/4] Checking TFLint..." -ForegroundColor Yellow
try {
    $tflintUrl = "https://github.com/terraform-linters/tflint/releases/download/v0.50.3/tflint_windows_amd64.zip"
    Download-And-ExtractZip -Url $tflintUrl -ZipName "tflint.zip" -ExeName "tflint.exe"
} catch {
    Write-Host " -> TFLint download warning: $_" -ForegroundColor Red
}

# 2. Install TFSec
Write-Host "`n[2/4] Checking TFSec..." -ForegroundColor Yellow
try {
    $tfsecUrl = "https://github.com/aquasecurity/tfsec/releases/download/v1.28.6/tfsec-windows-amd64.exe"
    Download-File -Url $tfsecUrl -FileName "tfsec.exe"
} catch {
    Write-Host " -> TFSec download warning: $_" -ForegroundColor Red
}

# 3. Install Infracost
Write-Host "`n[3/4] Checking Infracost..." -ForegroundColor Yellow
try {
    if (Get-Command infracost -ErrorAction SilentlyContinue) {
        Write-Host " -> Infracost is installed in system PATH." -ForegroundColor Green
    } else {
        $infracostUrl = "https://github.com/infracost/infracost/releases/download/v0.10.35/infracost-windows-amd64.zip"
        Download-And-ExtractZip -Url $infracostUrl -ZipName "infracost.zip" -ExeName "infracost-windows-amd64.exe"
    }
} catch {
    Write-Host " -> Infracost download warning: $_" -ForegroundColor Red
}

# 4. Install Gitleaks (Secret Scanner / TFLeaks)
Write-Host "`n[4/4] Checking Gitleaks..." -ForegroundColor Yellow
try {
    $gitleaksUrl = "https://github.com/gitleaks/gitleaks/releases/download/v8.18.2/gitleaks_8.18.2_windows_x64.zip"
    Download-And-ExtractZip -Url $gitleaksUrl -ZipName "gitleaks.zip" -ExeName "gitleaks.exe"
} catch {
    Write-Host " -> Gitleaks download warning: $_" -ForegroundColor Red
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host " All tools downloaded/installed to $InstallDir!" -ForegroundColor Cyan
Write-Host " Add '$InstallDir' to your User/System PATH environment variable." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
