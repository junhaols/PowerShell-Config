# PowerShell 兼容性配置

- 在Windows的Cursor中调用终端环境，经常出现兼容性错误，影响代码开发效率，主要原因是cursor默认使用了linux/Mac的编程风格。

- 一键解决 Windows PowerShell 终端环境问题的完整解决方案。

## 🎯 解决的问题

这个配置包可以解决以下常见的 Windows PowerShell 终端问题：

- ❌ `q^D` 错误提示
- ❌ `&&` 操作符不被识别
- ❌ Linux 命令如 `touch`、`cat`、`ls`、`rm` 无法使用
- ❌ 中文编码问题和乱码
- ❌ PowerShell 执行策略限制

## 📦 分享包内容

```
PowerShell_Config_Share/
├── PowerShell_Config_Installer.ps1    # 自动安装脚本
├── PowerShell_Profile_Fixed.ps1       # 配置文件模板
├── README_PowerShell_Config_Share.md   # 详细说明文档
├── INSTALL_GUIDE.md                   # 安装指南
└── TROUBLESHOOTING.md                 # 故障排除指南
```

## 🚀 快速开始

### 方法一：自动安装（推荐）

1. **下载分享包** 并解压到任意目录
2. **以管理员身份打开 PowerShell**
3. **导航到解压目录**：
   ```powershell
   cd "C:\path\to\PowerShell_Config_Share"
   ```
4. **运行安装脚本**：
   ```powershell
   .\PowerShell_Config_Installer.ps1
   ```
5. **重新启动 PowerShell** 以应用配置

### 方法二：手动安装

1. **复制配置文件**：
   ```powershell
   Copy-Item -Path "PowerShell_Profile_Fixed.ps1" -Destination $PROFILE -Force
   ```
2. **设置执行策略**：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
   ```
3. **重新启动 PowerShell**

## 📋 安装选项

### 基本安装
```powershell
.\PowerShell_Config_Installer.ps1
```

### 高级选项
```powershell
# 强制覆盖现有配置
.\PowerShell_Config_Installer.ps1 -Force

# 安装前备份现有配置
.\PowerShell_Config_Installer.ps1 -Backup

# 验证安装是否成功
.\PowerShell_Config_Installer.ps1 -Verify

# 卸载配置
.\PowerShell_Config_Installer.ps1 -Uninstall

# 卸载并备份
.\PowerShell_Config_Installer.ps1 -Uninstall -Backup
```

## ✨ 功能特性

### 🔧 Linux 命令别名

安装后可以直接使用以下 Linux 命令：

| 命令 | 功能 | 示例 |
|------|------|------|
| `touch` | 创建文件或更新时间戳 | `touch file.txt` |
| `cat` | 查看文件内容 | `cat file.txt` |
| `ls` | 列出文件和目录 | `ls` |
| `rm` | 删除文件或目录 | `rm file.txt` |
| `mv` | 移动/重命名文件 | `mv old.txt new.txt` |
| `cp` | 复制文件 | `cp file1.txt file2.txt` |
| `mkdir` | 创建目录 | `mkdir newfolder` |
| `pwd` | 显示当前路径 | `pwd` |
| `which` | 查找命令位置 | `which python` |
| `grep` | 搜索文本 | `grep "pattern" file.txt` |
| `find` | 查找文件 | `find . -name "*.txt"` |
| `head` | 显示文件开头 | `head -5 file.txt` |
| `tail` | 显示文件结尾 | `tail -10 file.txt` |

### 🌐 编码支持

- ✅ 自动设置 UTF-8 编码
- ✅ 解决中文乱码问题
- ✅ 支持特殊字符显示

### 🎨 增强功能

- ✅ 彩色终端提示符
- ✅ Git 分支显示
- ✅ 错误提示和建议
- ✅ 欢迎信息显示

## 🔍 验证安装

安装完成后，重新打开 PowerShell 窗口，应该看到：

```
🚀 PowerShell Compatibility Environment Loaded
💡 Linux command aliases available, encoding issues fixed
📚 Use Get-Help for assistance
PS C:\Users\YourName > 
```

然后可以测试命令：

```powershell
# 测试基本命令
touch test.txt
echo "Hello World" > test.txt
cat test.txt
ls test.txt
rm test.txt

# 测试目录操作
mkdir testfolder
ls testfolder
rm -Recurse testfolder
```

## 🔧 系统要求

- **操作系统**: Windows 7/8/10/11
- **PowerShell**: 版本 3.0 或更高
- **权限**: 建议以管理员身份运行安装脚本

## 📁 配置文件位置

配置文件将安装到以下位置之一：

- **Windows PowerShell 5.x**: `$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
- **PowerShell Core 6+**: `$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

## 🔄 更新配置

如需更新配置：

1. **下载新版本** 的分享包
2. **运行安装脚本** 并选择覆盖：
   ```powershell
   .\PowerShell_Config_Installer.ps1 -Force
   ```

## 🗑️ 卸载配置

如需完全卸载：

```powershell
# 卸载并备份现有配置
.\PowerShell_Config_Installer.ps1 -Uninstall -Backup

# 或者手动删除配置文件
Remove-Item $PROFILE -Force
```

## ❗ 常见问题

### 执行策略错误

如果遇到 "执行策略" 错误：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### 配置不生效

1. **确认配置文件存在**：
   ```powershell
   Test-Path $PROFILE
   ```

2. **手动加载配置**：
   ```powershell
   . $PROFILE
   ```

3. **重新安装**：
   ```powershell
   .\PowerShell_Config_Installer.ps1 -Force
   ```

### 权限问题

- **以管理员身份运行** PowerShell
- **检查文件权限** 确保配置文件可读写

## 🔗 兼容性

### ✅ 兼容环境

- Windows PowerShell 5.1
- PowerShell Core 6.x
- PowerShell 7.x
- Windows Terminal
- PowerShell ISE
- VS Code 集成终端

### ⚠️ 注意事项

- 配置仅影响当前用户
- 不会影响系统级别设置
- 可以安全卸载

## 📞 技术支持

如遇问题，请检查：

1. **系统兼容性** - 确保使用 Windows 系统
2. **PowerShell 版本** - 需要 3.0 或更高版本
3. **执行策略** - 确保允许脚本执行
4. **文件权限** - 确保有写入用户目录的权限

## 📄 许可证

此配置包免费提供，可自由分享和修改。

---

**创建人**: Junhao Luo  
**联系方式**: junhaol@mail.bnu.edu.cn  
**版本**: 1.0  
**更新时间**: 2025-06-06 