#Requires -Version 5.1
<#
.SYNOPSIS
  Install the Turso Cloud CLI on native Windows.

.DESCRIPTION
  Downloads the latest Windows release archive, installs turso.exe into
  %USERPROFILE%\.turso, and prepends that directory to the user PATH.

  Optional environment overrides for CI / mirrors:
    TURSO_DOWNLOAD_BASE  - release asset base URL (default: homebrew-tap latest)
    TURSO_INSTALL_ZIP    - local zip path (skips download; used in CI)
    TURSO_INSTALL_DIR    - install directory (default: %USERPROFILE%\.turso)
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-TursoInfo([string]$Message) {
    Write-Host $Message -ForegroundColor Cyan
}

function Get-TursoArch {
    $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    switch ($arch) {
        'X64' { return 'x86_64' }
        'Arm64' { return 'arm64' }
        default {
            throw "Architecture '$arch' is not supported by this installation script."
        }
    }
}

function Add-TursoToUserPath([string]$InstallDirectory) {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ([string]::IsNullOrEmpty($userPath)) {
        $userPath = ''
    }
    $parts = $userPath -split ';' | Where-Object { $_ -and $_.Trim() -ne '' }
    if ($parts -contains $InstallDirectory) {
        Write-TursoInfo "PATH already contains $InstallDirectory"
        return
    }
    $newPath = if ($userPath.Trim() -eq '') {
        $InstallDirectory
    } else {
        "$InstallDirectory;$userPath"
    }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    $env:Path = "$InstallDirectory;$env:Path"
    Write-TursoInfo "Added $InstallDirectory to your user PATH."
}

function Install-TursoFromZip([string]$ZipPath, [string]$InstallDirectory) {
    $extractDir = Join-Path ([System.IO.Path]::GetTempPath()) ("turso-extract-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $extractDir | Out-Null
    try {
        Expand-Archive -Path $ZipPath -DestinationPath $extractDir -Force
        $exe = Get-ChildItem -Path $extractDir -Filter 'turso.exe' -Recurse | Select-Object -First 1
        if (-not $exe) {
            throw "turso.exe was not found inside the release archive."
        }
        New-Item -ItemType Directory -Force -Path $InstallDirectory | Out-Null
        $dest = Join-Path $InstallDirectory 'turso.exe'
        Copy-Item -Path $exe.FullName -Destination $dest -Force
        return $dest
    }
    finally {
        Remove-Item -Recurse -Force $extractDir -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-TursoInfo "Welcome to the Turso installer (native Windows)!"
Write-Host ""

$installDirectory = if ($env:TURSO_INSTALL_DIR) { $env:TURSO_INSTALL_DIR } else {
    Join-Path $HOME '.turso'
}

$zipPath = $null
$tempZip = $null

try {
    if ($env:TURSO_INSTALL_ZIP) {
        if (-not (Test-Path -LiteralPath $env:TURSO_INSTALL_ZIP)) {
            throw "TURSO_INSTALL_ZIP not found: $($env:TURSO_INSTALL_ZIP)"
        }
        $zipPath = $env:TURSO_INSTALL_ZIP
        Write-TursoInfo "Using local archive $zipPath"
    }
    else {
        $arch = Get-TursoArch
        $base = if ($env:TURSO_DOWNLOAD_BASE) {
            $env:TURSO_DOWNLOAD_BASE.TrimEnd('/')
        } else {
            'https://github.com/tursodatabase/homebrew-tap/releases/latest/download'
        }
        # Goreleaser name_template uses title-cased OS ("Windows") and x86_64/arm64.
        $asset = "homebrew-tap_Windows_$arch.zip"
        $url = "$base/$asset"
        $tempZip = Join-Path ([System.IO.Path]::GetTempPath()) $asset
        Write-TursoInfo "Downloading $asset ..."
        Invoke-WebRequest -Uri $url -OutFile $tempZip -UseBasicParsing
        $zipPath = $tempZip
    }

    Write-TursoInfo "Installing to $installDirectory"
    $installed = Install-TursoFromZip -ZipPath $zipPath -InstallDirectory $installDirectory
    Add-TursoToUserPath -InstallDirectory $installDirectory

    Write-Host ""
    Write-TursoInfo "Turso CLI installed at $installed"
    Write-Host ""
    Write-Host "If you are a new user, sign up with:  turso auth signup"
    Write-Host "If you already have an account:     turso auth login"
    Write-Host ""
    Write-Host "Open a new terminal if 'turso' is not found on PATH yet."
    Write-Host ""
}
finally {
    if ($tempZip -and (Test-Path -LiteralPath $tempZip)) {
        Remove-Item -Force $tempZip -ErrorAction SilentlyContinue
    }
}
