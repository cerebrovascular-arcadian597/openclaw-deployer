#!/bin/bash
#
# OpenClaw 部署助手 - macOS 依赖安装脚本
# 自动安装 Node.js 和 Git，支持 Apple Silicon 和 Intel 芯片
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

log_error() {
    echo -e "${RED}[错误]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

# 检测架构
detect_arch() {
    local arch=$(uname -m)
    if [[ "$arch" == "arm64" ]]; then
        echo "arm64"
    else
        echo "x64"
    fi
}

# 检测是否使用 Apple Silicon
is_apple_silicon() {
    [[ $(detect_arch) == "arm64" ]]
}

# 检测 Homebrew 安装路径
get_brew_prefix() {
    if is_apple_silicon; then
        echo "/opt/homebrew"
    else
        echo "/usr/local"
    fi
}

# 检查 Homebrew
check_homebrew() {
    if command -v brew &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 安装 Homebrew
install_homebrew() {
    log_info "开始安装 Homebrew..."
    
    # 使用国内镜像加速安装
    export HOMEBREW_INSTALL_FROM_API=1
    export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 配置环境变量
    local brew_prefix=$(get_brew_prefix)
    if [[ -f "$brew_prefix/bin/brew" ]]; then
        eval "$("$brew_prefix/bin/brew" shellenv)"
        
        # 添加到 shell 配置文件
        local shell_rc=""
        if [[ "$SHELL" == *"zsh"* ]]; then
            shell_rc="$HOME/.zshrc"
        else
            shell_rc="$HOME/.bash_profile"
        fi
        
        echo "eval \"\$($brew_prefix/bin/brew shellenv)\"" >> "$shell_rc"
        log_success "Homebrew 安装完成并已配置环境变量"
    fi
}

# 使用 Homebrew 安装 Node.js
install_nodejs_brew() {
    log_info "使用 Homebrew 安装 Node.js..."
    
    # 配置国内镜像
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    
    brew install node@22
    
    # 链接 Node.js
    brew link node@22 --force
    
    log_success "Node.js 安装完成"
}

# 使用官方安装包安装 Node.js
install_nodejs_pkg() {
    log_info "使用官方安装包安装 Node.js..."
    
    local arch=$(detect_arch)
    local node_version="22.0.0"
    local pkg_name="node-v${node_version}.pkg"
    
    if [[ "$arch" == "arm64" ]]; then
        pkg_name="node-v${node_version}.pkg"
    fi
    
    local download_url="https://npmmirror.com/mirrors/node/v${node_version}/${pkg_name}"
    local temp_path="/tmp/${pkg_name}"
    
    log_info "下载地址: $download_url"
    
    # 下载
    curl -fsSL "$download_url" -o "$temp_path"
    
    # 安装
    sudo installer -pkg "$temp_path" -target /
    
    # 清理
    rm -f "$temp_path"
    
    log_success "Node.js 安装完成"
}

# 安装 Node.js
install_nodejs() {
    log_info "检查 Node.js 安装..."
    
    if command -v node &> /dev/null; then
        local current_version=$(node --version | sed 's/v//')
        local major_version=$(echo "$current_version" | cut -d. -f1)
        
        if [[ $major_version -ge 22 ]]; then
            log_success "Node.js 已安装 (v$current_version)，满足要求"
            return 0
        else
            log_warn "Node.js 版本过低 (v$current_version)，需要升级"
        fi
    fi
    
    # 优先使用 Homebrew 安装
    if check_homebrew; then
        install_nodejs_brew
    else
        install_nodejs_pkg
    fi
    
    # 配置 npm 国内镜像
    log_info "配置 npm 使用国内镜像..."
    npm config set registry https://registry.npmmirror.com
    log_success "npm 镜像配置完成"
}

# 使用 Homebrew 安装 Git
install_git_brew() {
    log_info "使用 Homebrew 安装 Git..."
    
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    
    brew install git
    
    log_success "Git 安装完成"
}

# 安装 Xcode Command Line Tools
install_git_xcode() {
    log_info "安装 Xcode Command Line Tools..."
    
    xcode-select --install
    
    log_warn "请按照弹出的提示完成安装，然后重新运行此脚本"
    exit 0
}

# 安装 Git
install_git() {
    log_info "检查 Git 安装..."
    
    if command -v git &> /dev/null; then
        local git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        log_success "Git 已安装 (v$git_version)"
        
        # 配置 Git 使用国内镜像
        git config --global url."https://gh.api.99988866.xyz/https://github.com/".insteadOf "https://github.com/"
        return 0
    fi
    
    # 优先使用 Homebrew
    if check_homebrew; then
        install_git_brew
    else
        install_git_xcode
    fi
}

# 配置环境变量
configure_env() {
    log_info "配置环境变量..."
    
    local shell_rc=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bash_profile"
    fi
    
    # 确保 Homebrew 在 PATH 中
    local brew_prefix=$(get_brew_prefix)
    if [[ -d "$brew_prefix/bin" ]]; then
        if ! grep -q "$brew_prefix/bin" "$shell_rc" 2>/dev/null; then
            echo "export PATH=\"$brew_prefix/bin:\$PATH\"" >> "$shell_rc"
            log_success "已更新 $shell_rc"
        fi
    fi
    
    # 配置 npm 全局安装路径
    if command -v npm &> /dev/null; then
        local npm_global="$HOME/.npm-global"
        mkdir -p "$npm_global/bin"
        npm config set prefix "$npm_global"
        
        if ! grep -q "$npm_global/bin" "$shell_rc" 2>/dev/null; then
            echo "export PATH=\"$npm_global/bin:\$PATH\"" >> "$shell_rc"
        fi
    fi
}

# 主函数
main() {
    echo "=========================================="
    echo "OpenClaw 部署助手 - macOS 依赖安装"
    echo "=========================================="
    
    log_info "检测到系统架构: $(detect_arch)"
    
    # 检查 sudo 权限
    if [[ $EUID -ne 0 ]]; then
        log_warn "某些操作可能需要 sudo 权限"
    fi
    
    # 安装 Homebrew (如果不存在)
    if ! check_homebrew; then
        log_info "未检测到 Homebrew，准备安装..."
        read -p "是否安装 Homebrew? (推荐) [Y/n]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            install_homebrew
        else
            log_warn "跳过 Homebrew 安装"
        fi
    else
        log_success "Homebrew 已安装"
    fi
    
    # 安装 Node.js
    install_nodejs
    
    # 安装 Git
    install_git
    
    # 配置环境变量
    configure_env
    
    echo "=========================================="
    log_success "所有依赖安装完成！"
    echo "=========================================="
    
    log_info "请运行以下命令刷新环境变量:"
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "  source ~/.zshrc"
    else
        echo "  source ~/.bash_profile"
    fi
}

# 运行主函数
main "$@"
