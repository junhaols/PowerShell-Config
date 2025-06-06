#!/usr/bin/env powershell
# PowerShell兼容性配置自动安装脚本
# 一键解决Windows PowerShell终端环境问题
# 创建人：Junhao Luo
# 联系方式：junhaol@mail.bnu.edu.cn

param(
    [switch]$Force,           # 强制覆盖现有配置
    [switch]$Backup,          # 备份现有配置
    [switch]$Uninstall,       # 卸载配置
    [switch]$Verify           # 验证安装
)

# 颜色输出函数
function Write-ColorText {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color
}

# 显示标题
function Show-Banner {
    Write-ColorText "=================================" "Cyan"
    Write-ColorText "PowerShell兼容性配置安装器" "Yellow"
    Write-ColorText "解决Windows终端环境问题" "Green"
    Write-ColorText "=================================" "Cyan"
    Write-Host ""
}

# 检查系统兼容性
function Test-SystemCompatibility {
    Write-ColorText "🔍 检查系统兼容性..." "Cyan"
    
    # 检查操作系统
    if ($PSVersionTable.Platform -and $PSVersionTable.Platform -ne "Win32NT") {
        Write-ColorText "❌ 此配置仅适用于Windows系统" "Red"
        return $false
    }
    
    # 检查PowerShell版本
    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion -lt 3) {
        Write-ColorText "❌ 需要PowerShell 3.0或更高版本" "Red"
        return $false
    }
    
    Write-ColorText "✅ 系统兼容性检查通过" "Green"
    Write-ColorText "   操作系统: Windows" "Gray"
    Write-ColorText "   PowerShell版本: $($PSVersionTable.PSVersion)" "Gray"
    return $true
}

# 获取配置文件路径
function Get-ProfilePath {
    # 支持多种PowerShell版本的配置文件路径
    $profilePaths = @(
        $PROFILE.CurrentUserCurrentHost,
        "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
        "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    )
    
    # 返回第一个有效路径
    foreach ($path in $profilePaths) {
        if ($path) {
            $dir = Split-Path $path -Parent
            if (!(Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            return $path
        }
    }
    
    throw "无法确定PowerShell配置文件路径"
}

# 备份现有配置
function Backup-ExistingProfile {
    param([string]$ProfilePath)
    
    if (Test-Path $ProfilePath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = "$ProfilePath.backup_$timestamp"
        
        Copy-Item $ProfilePath $backupPath
        Write-ColorText "✅ 现有配置已备份到: $backupPath" "Green"
        return $backupPath
    }
    return $null
}

# 创建配置文件内容
function Get-ProfileContent {
    return @'
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
Write-Host "🚀 PowerShell Compatibility Environment Loaded" -ForegroundColor Green
Write-Host "💡 Linux command aliases available, encoding issues fixed" -ForegroundColor Cyan
Write-Host "📚 Use Get-Help for assistance" -ForegroundColor Blue

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
'@
}

# 安装配置
function Install-PowerShellConfig {
    Write-ColorText "🚀 开始安装PowerShell兼容性配置..." "Cyan"
    
    try {
        # 获取配置文件路径
        $profilePath = Get-ProfilePath
        Write-ColorText "📁 配置文件路径: $profilePath" "Gray"
        
        # 检查现有配置
        if (Test-Path $profilePath) {
            if (-not $Force) {
                $response = Read-Host "发现现有配置文件，是否覆盖？(y/N)"
                if ($response -ne 'y' -and $response -ne 'Y') {
                    Write-ColorText "❌ 安装已取消" "Yellow"
                    return $false
                }
            }
            
            # 备份现有配置
            if ($Backup) {
                Backup-ExistingProfile -ProfilePath $profilePath
            }
        }
        
        # 设置执行策略
        Write-ColorText "🔧 设置执行策略..." "Cyan"
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-ColorText "✅ 执行策略设置成功" "Green"
        } catch {
            Write-ColorText "⚠️  执行策略设置失败，可能需要管理员权限" "Yellow"
        }
        
        # 创建配置文件
        Write-ColorText "📝 创建配置文件..." "Cyan"
        $profileContent = Get-ProfileContent
        $profileContent | Out-File -FilePath $profilePath -Encoding UTF8 -Force
        
        Write-ColorText "✅ 配置文件安装成功!" "Green"
        Write-ColorText "📍 位置: $profilePath" "Gray"
        
        return $true
        
    } catch {
        Write-ColorText "❌ 安装失败: $($_.Exception.Message)" "Red"
        return $false
    }
}

# 卸载配置
function Uninstall-PowerShellConfig {
    Write-ColorText "🗑️  开始卸载PowerShell兼容性配置..." "Cyan"
    
    try {
        $profilePath = Get-ProfilePath
        
        if (Test-Path $profilePath) {
            # 备份现有配置
            if ($Backup) {
                Backup-ExistingProfile -ProfilePath $profilePath
            }
            
            Remove-Item $profilePath -Force
            Write-ColorText "✅ 配置文件已删除" "Green"
        } else {
            Write-ColorText "ℹ️  未找到配置文件，无需卸载" "Yellow"
        }
        
        return $true
        
    } catch {
        Write-ColorText "❌ 卸载失败: $($_.Exception.Message)" "Red"
        return $false
    }
}

# 验证安装
function Test-Installation {
    Write-ColorText "🧪 验证安装..." "Cyan"
    
    try {
        $profilePath = Get-ProfilePath
        
        # 检查配置文件存在
        if (!(Test-Path $profilePath)) {
            Write-ColorText "❌ 配置文件不存在" "Red"
            return $false
        }
        
        # 检查配置文件内容
        $content = Get-Content $profilePath -Raw
        $requiredFunctions = @("touch", "cat", "grep", "find", "head", "tail")
        
        foreach ($func in $requiredFunctions) {
            if ($content -notmatch "function $func") {
                Write-ColorText "❌ 缺少函数: $func" "Red"
                return $false
            }
        }
        
        Write-ColorText "✅ 安装验证通过" "Green"
        Write-ColorText "📁 配置文件: $profilePath" "Gray"
        Write-ColorText "📏 文件大小: $((Get-Item $profilePath).Length) 字节" "Gray"
        
        return $true
        
    } catch {
        Write-ColorText "❌ 验证失败: $($_.Exception.Message)" "Red"
        return $false
    }
}

# 显示使用说明
function Show-Usage {
    Write-ColorText "📚 使用说明:" "Yellow"
    Write-Host ""
    Write-ColorText "安装配置:" "Cyan"
    Write-Host "  .\PowerShell_Config_Installer.ps1"
    Write-Host "  .\PowerShell_Config_Installer.ps1 -Force          # 强制覆盖"
    Write-Host "  .\PowerShell_Config_Installer.ps1 -Backup         # 备份现有配置"
    Write-Host ""
    Write-ColorText "其他操作:" "Cyan"
    Write-Host "  .\PowerShell_Config_Installer.ps1 -Verify         # 验证安装"
    Write-Host "  .\PowerShell_Config_Installer.ps1 -Uninstall      # 卸载配置"
    Write-Host "  .\PowerShell_Config_Installer.ps1 -Uninstall -Backup  # 卸载并备份"
    Write-Host ""
    Write-ColorText "安装后可用的Linux命令:" "Green"
    Write-Host "  touch, cat, ls, rm, mv, cp, mkdir, pwd, which, grep, find, head, tail"
    Write-Host ""
}

# 主函数
function Main {
    Show-Banner
    
    # 检查系统兼容性
    if (!(Test-SystemCompatibility)) {
        exit 1
    }
    
    Write-Host ""
    
    # 根据参数执行不同操作
    if ($Verify) {
        $success = Test-Installation
    }
    elseif ($Uninstall) {
        $success = Uninstall-PowerShellConfig
    }
    else {
        $success = Install-PowerShellConfig
    }
    
    Write-Host ""
    
    if ($success) {
        if ($Uninstall) {
            Write-ColorText "🎉 卸载完成!" "Green"
        } elseif ($Verify) {
            Write-ColorText "🎉 验证完成!" "Green"
        } else {
            Write-ColorText "🎉 安装完成!" "Green"
            Write-ColorText "💡 请重新启动PowerShell终端以应用配置" "Yellow"
            Write-Host ""
            Write-ColorText "🧪 快速测试:" "Cyan"
            Write-Host "  打开新的PowerShell窗口"
            Write-Host "  应该看到欢迎信息，然后可以使用: touch, cat, ls, rm 等命令"
        }
    } else {
        Write-ColorText "❌ 操作失败，请查看错误信息" "Red"
        Show-Usage
        exit 1
    }
}

# 如果直接运行脚本，执行主函数
if ($MyInvocation.InvocationName -ne ".") {
    Main
} 