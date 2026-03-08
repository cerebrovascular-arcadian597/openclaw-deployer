# OpenClaw 部署助手启动脚本
# Windows PowerShell 启动器

$Host.UI.RawUI.WindowTitle = "OpenClaw 部署助手"

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$exePath = Join-Path $scriptPath "release\win-unpacked\OpenClaw 部署助手.exe"

if (Test-Path $exePath) {
    Start-Process $exePath
} else {
    Write-Host "未找到 OpenClaw 部署助手，请先运行 npm run build 构建" -ForegroundColor Red
    Write-Host "按任意键退出..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
