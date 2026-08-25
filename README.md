# Turso installer

## macOS / Linux

```bash
curl -sSfL https://get.tur.so/install.sh | bash
```

## Windows (native PowerShell)

```powershell
irm https://get.tur.so/install.ps1 | iex
```

This installs a native `turso.exe` (no WSL required).

Git Bash / MSYS users can also run `install.sh`; it now recognizes Windows hosts and installs `turso.exe`.

After the WinGet package is registered, Windows users can also install with:

```powershell
winget install Turso.CLI
```
