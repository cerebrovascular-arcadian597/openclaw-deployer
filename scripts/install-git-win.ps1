# OpenClaw 部署助手 - Windows Git 安装脚本
# 使用国内镜像源静默安装 Git

param(
    [string]$GitVersion = "2.43.0",
    [string]$MirrorUrl = "https://npmmirror.com/mirrors/git-for-windows"
)

$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host "[信息] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[成功] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[错误] $Message" -ForegroundColor Red
}

function Test-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-SystemArchitecture {
    if ([Environment]::Is64BitOperatingSystem) {
        return "64-bit"
    } else {
        return "32-bit"
    }
}

function Install-Git {
    Write-Info "开始安装 Git"
    
    # 检测系统架构
    $arch = Get-SystemArchitecture
    $archSuffix = if ($arch -eq "64-bit") { "64-bit" } else { "32-bit" }
    
    Write-Info "检测到系统架构: $arch"
    
    # 构建下载 URL (Git for Windows 使用 v2.x.x 格式)
    $versionTag = "v$GitVersion.windows.1"
    $installerName = "Git-$GitVersion-$archSuffix.exe"
    $downloadUrl = "$MirrorUrl/$versionTag/$installerName"
    $tempPath = Join-Path $env:TEMP $installerName
    
    Write-Info "下载地址: $downloadUrl"
    Write-Info "临时文件: $tempPath"
    
    # 下载安装包
    try {
        Write-Info "正在下载 Git 安装包..."
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($downloadUrl, $tempPath)
        Write-Success "下载完成"
    } catch {
        Write-Error "下载失败: $_"
        # 尝试备用下载地址
        $backupUrl = "https://github.com/git-for-windows/git/releases/download/$versionTag/$installerName"
        Write-Info "尝试备用下载地址..."
        try {
            $webClient.DownloadFile($backupUrl, $tempPath)
            Write-Success "备用地址下载成功"
        } catch {
            Write-Error "备用地址也失败: $_"
            exit 1
        }
    }
    
    # 验证文件是否存在
    if (-not (Test-Path $tempPath)) {
        Write-Error "下载的文件不存在"
        exit 1
    }
    
    # 静默安装参数
    # /VERYSILENT - 静默安装，不显示界面
    # /NORESTART - 安装完成后不重启
    # /NOCANCEL - 不允许取消
    # /SP- - 不显示安装进度页
    # /COMPONENTS - 安装的组件
    $installArgs = @(
        "/VERYSILENT"
        "/NORESTART"
        "/NOCANCEL"
        "/SP-"
        "/COMPONENTS=icons,ext,gitlfs,assoc,autoupdate"
    )
    
    # 执行安装
    try {
        Write-Info "正在安装 Git (静默安装)..."
        $process = Start-Process -FilePath $tempPath -ArgumentList $installArgs -Wait -PassThru
        
        if ($process.ExitCode -ne 0) {
            Write-Error "安装失败，退出码: $($process.ExitCode)"
            exit 1
        }
        
        Write-Success "Git 安装完成"
    } catch {
        Write-Error "安装过程出错: $_"
        exit 1
    }
    
    # 清理临时文件
    try {
        Remove-Item $tempPath -Force
        Write-Info "已清理临时文件"
    } catch {
        Write-Info "清理临时文件失败 (可忽略): $_"
    }
    
    # 验证安装
    try {
        Write-Info "验证 Git 安装..."
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # 刷新环境变量
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "Machine"), "Process")
        
        $gitVersion = & git --version 2>$null
        
        if ($gitVersion) {
            Write-Success "Git 版本: $gitVersion"
            
            # 配置 Git 使用国内镜像
            Write-Info "配置 Git 使用国内镜像加速..."
            & git config --global url."https://gh.api.99988866.xyz/https://github.com/".insteadOf "https://github.com/"
            Write-Success "Git 镜像配置完成"
        } else {
            Write-Error "Git 安装验证失败，请手动重启程序"
        }
    } catch {
        Write-Error "验证失败: $_"
        Write-Info "提示：可能需要重启程序才能使用 Git"
    }
}

# 主程序
Write-Info "=========================================="
Write-Info "OpenClaw 部署助手 - Git 安装程序"
Write-Info "=========================================="

# 检查管理员权限
if (-not (Test-Admin)) {
    Write-Error "需要管理员权限才能安装 Git"
    Write-Info "请右键点击此脚本，选择"以管理员身份运行""
    exit 1
}

Write-Success "已获取管理员权限"

# 检查是否已安装
$existingGit = Get-Command git -ErrorAction SilentlyContinue
if ($existingGit) {
    $currentVersion = & git --version
    Write-Info "检测到已安装的 Git: $currentVersion"
    Write-Success "Git 已安装，跳过安装"
    exit 0
}

# 执行安装
Install-Git

Write-Info "=========================================="
Write-Success "Git 安装程序执行完毕"
Write-Info "=========================================="
