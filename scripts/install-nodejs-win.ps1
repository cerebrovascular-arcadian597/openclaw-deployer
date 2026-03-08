# OpenClaw 部署助手 - Windows Node.js 安装脚本
# 使用国内镜像源静默安装 Node.js >= 22

param(
    [string]$NodeVersion = "22.0.0",
    [string]$MirrorUrl = "https://npmmirror.com/mirrors/node"
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
        return "x64"
    } else {
        return "x86"
    }
}

function Install-NodeJS {
    Write-Info "开始安装 Node.js v$NodeVersion"
    
    # 检测系统架构
    $arch = Get-SystemArchitecture
    Write-Info "检测到系统架构: $arch"
    
    # 构建下载 URL
    $installerName = "node-v$NodeVersion-win-$arch.msi"
    $downloadUrl = "$MirrorUrl/v$NodeVersion/$installerName"
    $tempPath = Join-Path $env:TEMP $installerName
    
    Write-Info "下载地址: $downloadUrl"
    Write-Info "临时文件: $tempPath"
    
    # 下载安装包
    try {
        Write-Info "正在下载 Node.js 安装包..."
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($downloadUrl, $tempPath)
        Write-Success "下载完成"
    } catch {
        Write-Error "下载失败: $_"
        exit 1
    }
    
    # 验证文件是否存在
    if (-not (Test-Path $tempPath)) {
        Write-Error "下载的文件不存在"
        exit 1
    }
    
    # 静默安装
    try {
        Write-Info "正在安装 Node.js (静默安装)..."
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "`"$tempPath`"", "/qn", "/norestart", "ADDLOCAL=ALL" -Wait -PassThru
        
        if ($process.ExitCode -ne 0) {
            Write-Error "安装失败，退出码: $($process.ExitCode)"
            exit 1
        }
        
        Write-Success "Node.js 安装完成"
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
        Write-Info "验证 Node.js 安装..."
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $nodeVersion = & node --version 2>$null
        $npmVersion = & npm --version 2>$null
        
        if ($nodeVersion) {
            Write-Success "Node.js 版本: $nodeVersion"
            Write-Success "npm 版本: $npmVersion"
            
            # 配置国内 npm 镜像
            Write-Info "配置 npm 使用国内镜像源..."
            & npm config set registry https://registry.npmmirror.com
            Write-Success "npm 镜像已设置为: https://registry.npmmirror.com"
        } else {
            Write-Error "Node.js 安装验证失败"
            exit 1
        }
    } catch {
        Write-Error "验证失败: $_"
        exit 1
    }
}

# 主程序
Write-Info "=========================================="
Write-Info "OpenClaw 部署助手 - Node.js 安装程序"
Write-Info "=========================================="

# 检查管理员权限
if (-not (Test-Admin)) {
    Write-Error "需要管理员权限才能安装 Node.js"
    Write-Info "请右键点击此脚本，选择"以管理员身份运行""
    exit 1
}

Write-Success "已获取管理员权限"

# 检查是否已安装
$existingNode = Get-Command node -ErrorAction SilentlyContinue
if ($existingNode) {
    $currentVersion = & node --version
    Write-Info "检测到已安装的 Node.js: $currentVersion"
    
    # 解析版本号
    $currentMajor = [int]($currentVersion -replace 'v', '').Split('.')[0]
    $requiredMajor = [int]$NodeVersion.Split('.')[0]
    
    if ($currentMajor -ge $requiredMajor) {
        Write-Success "当前版本已满足要求 (>= $requiredMajor)，跳过安装"
        exit 0
    } else {
        Write-Info "当前版本过低，需要升级"
    }
}

# 执行安装
Install-NodeJS

Write-Info "=========================================="
Write-Success "Node.js 安装程序执行完毕"
Write-Info "=========================================="
