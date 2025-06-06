# PowerShell 配置故障排除指南

## 🔍 常见问题诊断

### 问题 1: 执行策略限制

**错误信息**:
```
无法加载文件 xxx.ps1，因为在此系统上禁止运行脚本
```

**解决方案**:
```powershell
# 方案 1: 设置用户级别策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 方案 2: 临时绕过策略
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# 方案 3: 直接执行（一次性）
powershell -ExecutionPolicy Bypass -File "PowerShell_Config_Installer.ps1"
```

### 问题 2: 配置文件不生效

**症状**: 新开 PowerShell 窗口没有看到欢迎信息，Linux 命令不可用

**检查步骤**:
```powershell
# 1. 检查配置文件是否存在
Test-Path $PROFILE
Write-Host "配置文件路径: $PROFILE"

# 2. 检查配置文件内容
Get-Content $PROFILE | Select-String "PowerShell Compatibility"

# 3. 手动加载配置文件
. $PROFILE
```

**解决方案**:
```powershell
# 重新安装配置
.\PowerShell_Config_Installer.ps1 -Force

# 或手动复制
Copy-Item -Path "PowerShell_Profile_Fixed.ps1" -Destination $PROFILE -Force
```

### 问题 3: 权限不足

**错误信息**:
```
拒绝访问路径 'xxx'
```

**解决方案**:
1. **以管理员身份运行** PowerShell
2. **检查文件夹权限**:
   ```powershell
   $profileDir = Split-Path $PROFILE -Parent
   Get-Acl $profileDir
   ```
3. **创建目录**（如果不存在）:
   ```powershell
   $profileDir = Split-Path $PROFILE -Parent
   New-Item -ItemType Directory -Path $profileDir -Force
   ```

### 问题 4: 编码问题

**症状**: 中文字符显示乱码

**解决方案**:
```powershell
# 设置控制台编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 重新安装配置
.\PowerShell_Config_Installer.ps1 -Force
```

### 问题 5: Linux 命令不工作

**症状**: `touch`、`cat` 等命令提示 "无法识别"

**检查方案**:
```powershell
# 检查函数是否定义
Get-Command touch -ErrorAction SilentlyContinue
Get-Command cat -ErrorAction SilentlyContinue

# 检查别名是否设置
Get-Alias ls -ErrorAction SilentlyContinue
Get-Alias rm -ErrorAction SilentlyContinue
```

**解决方案**:
```powershell
# 手动加载配置
. $PROFILE

# 或重新安装
.\PowerShell_Config_Installer.ps1 -Force
```

### 问题 6: PowerShell 版本不兼容

**检查版本**:
```powershell
$PSVersionTable
```

**要求**: PowerShell 3.0 或更高版本

**解决方案**:
- **Windows 7/8**: 升级到 PowerShell 5.1
- **Windows 10/11**: 通常已内置合适版本
- **下载地址**: https://github.com/PowerShell/PowerShell

### 问题 7: 配置文件路径问题

**不同 PowerShell 版本的配置文件路径**:

```powershell
# Windows PowerShell 5.x
$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

# PowerShell Core 6+
$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# 当前会话的配置文件路径
$PROFILE
```

**解决方案**:
```powershell
# 为所有版本创建配置文件
$profiles = @(
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
)

foreach ($profile in $profiles) {
    $dir = Split-Path $profile -Parent
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force
    }
    Copy-Item -Path "PowerShell_Profile_Fixed.ps1" -Destination $profile -Force
}
```

## 🛠️ 诊断工具

### 自动诊断脚本

创建并运行以下诊断脚本：

```powershell
# 保存为 diagnose.ps1
Write-Host "=== PowerShell 配置诊断 ===" -ForegroundColor Cyan

# 1. 系统信息
Write-Host "`n1. 系统信息:" -ForegroundColor Yellow
Write-Host "   操作系统: $($env:OS)"
Write-Host "   PowerShell 版本: $($PSVersionTable.PSVersion)"
Write-Host "   当前用户: $($env:USERNAME)"

# 2. 执行策略
Write-Host "`n2. 执行策略:" -ForegroundColor Yellow
Write-Host "   当前用户: $(Get-ExecutionPolicy -Scope CurrentUser)"
Write-Host "   本地计算机: $(Get-ExecutionPolicy -Scope LocalMachine)"

# 3. 配置文件
Write-Host "`n3. 配置文件:" -ForegroundColor Yellow
Write-Host "   路径: $PROFILE"
Write-Host "   存在: $(Test-Path $PROFILE)"
if (Test-Path $PROFILE) {
    Write-Host "   大小: $((Get-Item $PROFILE).Length) 字节"
    Write-Host "   修改时间: $((Get-Item $PROFILE).LastWriteTime)"
}

# 4. 函数测试
Write-Host "`n4. 函数测试:" -ForegroundColor Yellow
$testFunctions = @("touch", "cat", "grep", "find")
foreach ($func in $testFunctions) {
    $exists = Get-Command $func -ErrorAction SilentlyContinue
    Write-Host "   $func`: $(if($exists){'✅'}else{'❌'})"
}

# 5. 别名测试
Write-Host "`n5. 别名测试:" -ForegroundColor Yellow
$testAliases = @("ls", "rm", "mv", "cp")
foreach ($alias in $testAliases) {
    $exists = Get-Alias $alias -ErrorAction SilentlyContinue
    Write-Host "   $alias`: $(if($exists){'✅'}else{'❌'})"
}

Write-Host "`n=== 诊断完成 ===" -ForegroundColor Cyan
```

## 📞 获取帮助

如果以上方案都无法解决问题：

1. **运行诊断脚本** 收集系统信息
2. **尝试验证安装**:
   ```powershell
   .\PowerShell_Config_Installer.ps1 -Verify
   ```
3. **收集错误信息** 并联系技术支持
4. **邮箱**: junhaol@mail.bnu.edu.cn

## 🔄 重置到默认状态

如果需要完全重置：

```powershell
# 1. 备份当前配置
if (Test-Path $PROFILE) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Copy-Item $PROFILE "$PROFILE.backup_$timestamp"
}

# 2. 删除配置文件
Remove-Item $PROFILE -Force -ErrorAction SilentlyContinue

# 3. 重置执行策略（可选）
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser -Force

# 4. 重新启动 PowerShell
``` 