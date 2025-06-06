# PowerShell 配置安装指南

## 🚀 快速安装（推荐）

### 步骤 1: 准备
1. 下载并解压分享包到任意目录
2. 以**管理员身份**打开 PowerShell

### 步骤 2: 安装
```powershell
# 导航到解压目录
cd "C:\path\to\PowerShell_Config_Share"

# 运行安装脚本
.\PowerShell_Config_Installer.ps1
```

### 步骤 3: 验证
重新打开 PowerShell，应该看到：
```
🚀 PowerShell Compatibility Environment Loaded
💡 Linux command aliases available, encoding issues fixed
```

## 🔧 手动安装

如果自动安装失败，可以手动安装：

```powershell
# 1. 设置执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 2. 复制配置文件
Copy-Item -Path "PowerShell_Profile_Fixed.ps1" -Destination $PROFILE -Force

# 3. 重新启动 PowerShell
```

## 🧪 测试命令

安装完成后测试以下命令：

```powershell
touch test.txt          # 创建文件
echo "Hello" > test.txt  # 写入内容
cat test.txt            # 查看内容
ls test.txt             # 列出文件
rm test.txt             # 删除文件
```

## ❗ 常见错误解决

### 执行策略错误
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

### 配置不生效
```powershell
# 手动加载配置
. $PROFILE

# 或重新安装
.\PowerShell_Config_Installer.ps1 -Force
```

### 权限不足
- 以管理员身份运行 PowerShell
- 确保有写入用户目录的权限

## 📞 需要帮助？

如果遇到问题：
1. 查看详细的 README 文档
2. 运行验证命令：`.\PowerShell_Config_Installer.ps1 -Verify`
3. 联系技术支持：junhaol@mail.bnu.edu.cn 