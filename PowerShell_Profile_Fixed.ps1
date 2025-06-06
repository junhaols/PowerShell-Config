# PowerShell Compatibility Profile
# Auto-generated - Fix Windows Terminal Environment Issues
# Created by: Junhao Luo

# Set UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Set execution policy
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
} catch {
    Write-Host "Notice: Execution policy may require admin privileges" -ForegroundColor Yellow
}

# Linux command aliases
function touch { 
    param([string]$Path)
    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $Path -Force | Out-Null
    }
}

function cat { 
    param([string]$Path)
    Get-Content -Path $Path -Encoding UTF8
}

Set-Alias -Name ls -Value Get-ChildItem -Option AllScope
Set-Alias -Name rm -Value Remove-Item -Option AllScope
Set-Alias -Name mv -Value Move-Item -Option AllScope
Set-Alias -Name cp -Value Copy-Item -Option AllScope

function mkdir { 
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

Set-Alias -Name pwd -Value Get-Location -Option AllScope
Set-Alias -Name which -Value Get-Command -Option AllScope

function grep { 
    param([string]$Pattern, [string]$Path)
    if ($Path) {
        Select-String -Pattern $Pattern -Path $Path
    } else {
        $input | Select-String -Pattern $Pattern
    }
}

function find { 
    param([string]$Path = ".", [string]$Name)
    if ($Name) {
        Get-ChildItem -Path $Path -Recurse -Name $Name
    } else {
        Get-ChildItem -Path $Path -Recurse
    }
}

function head { 
    param([int]$Lines = 10, [string]$Path)
    if ($Path) {
        Get-Content -Path $Path -TotalCount $Lines
    } else {
        $input | Select-Object -First $Lines
    }
}

function tail { 
    param([int]$Lines = 10, [string]$Path)
    if ($Path) {
        Get-Content -Path $Path -Tail $Lines
    } else {
        $input | Select-Object -Last $Lines
    }
}

# Error handling function
function Handle-CommandError {
    param([string]$Command, [string]$Error)
    
    if ($Error -match "cannot be recognized as cmdlet") {
        Write-Host "Tip: '$Command' is not a PowerShell command, try using aliases" -ForegroundColor Yellow
        Write-Host "   Available aliases: touch, cat, ls, rm, mv, cp, mkdir, pwd, which, grep, find, head, tail" -ForegroundColor Cyan
    }
    elseif ($Error -match "q\^D") {
        Write-Host "Tip: Use Ctrl+C to interrupt commands in Windows, not Ctrl+D" -ForegroundColor Yellow
    }
    elseif ($Error -match "&&.*is not recognized") {
        Write-Host "Tip: Use ';' or newlines to chain commands in PowerShell, not '&&'" -ForegroundColor Yellow
    }
}

# Set error handling
$ErrorActionPreference = "Continue"

# Welcome message
Write-Host "PowerShell Compatibility Environment Loaded" -ForegroundColor Green
Write-Host "Linux command aliases available, encoding issues fixed" -ForegroundColor Cyan
Write-Host "Use Get-Help for assistance" -ForegroundColor Blue

# Custom prompt
function prompt {
    $currentPath = (Get-Location).Path
    $branch = ""
    if (Test-Path .git) {
        try {
            $gitBranch = git branch --show-current 2>$null
            if ($gitBranch) {
                $branch = " [$gitBranch]"
            }
        } catch {
            # Ignore git errors
        }
    }
    
    Write-Host "PS " -NoNewline -ForegroundColor Green
    Write-Host $currentPath -NoNewline -ForegroundColor Blue
    Write-Host $branch -NoNewline -ForegroundColor Yellow
    Write-Host " > " -NoNewline -ForegroundColor Green
    return " "
} 