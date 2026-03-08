# OpenClaw 部署助手

🦞 面向纯小白用户的 OpenClaw (小龙虾) 跨平台一键部署桌面软件

[![Electron](https://img.shields.io/badge/Electron-28.0+-blue.svg)](https://electronjs.org/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS-lightgrey.svg)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 项目简介

OpenClaw 部署助手是一款基于 Electron 开发的跨平台桌面应用程序，专为纯小白用户设计，提供零代码、可视化的 OpenClaw AI 智能体一键部署体验。

### 核心特性

- **跨平台支持**: 一套代码同时兼容 Windows 和 macOS 双系统
- **零代码操作**: 全程可视化界面，无需手动敲任何命令
- **国内镜像加速**: 所有下载均使用国内镜像源，杜绝网络超时
- **自动环境检测**: 实时检测系统环境，智能提示缺失依赖
- **一键安装修复**: 自动安装/修复 Node.js、Git 等依赖
- **服务全生命周期管理**: 一键启动/停止/升级 OpenClaw 服务
- **实时日志系统**: 全流程实时输出带时间戳的执行日志

## 技术栈

- **框架**: Electron 28.0+
- **前端**: 原生 HTML5 / CSS3 / JavaScript (ES6+)
- **构建**: electron-builder
- **脚本**: PowerShell (Windows) / Bash (macOS)

## 项目结构

```
openclaw-deployer/
├── src/
│   ├── main.js              # 主进程 - 窗口管理、系统操作
│   ├── preload.js           # 预加载脚本 - 安全桥接
│   └── renderer/            # 渲染进程
│       ├── index.html       # 主界面
│       ├── styles.css       # 样式表
│       └── app.js           # 前端逻辑
├── scripts/                 # 安装脚本
│   ├── install-nodejs-win.ps1   # Windows Node.js 安装
│   ├── install-git-win.ps1      # Windows Git 安装
│   └── install-deps-mac.sh      # macOS 依赖安装
├── assets/                  # 图标资源
├── build/                   # 构建配置
├── package.json             # 项目配置
└── README.md               # 说明文档
```

## 快速开始

### 环境要求

- **Node.js**: >= 18.0.0
- **npm**: >= 9.0.0

### 安装依赖

```bash
# 克隆项目
git clone https://github.com/your-org/openclaw-deployer.git
cd openclaw-deployer

# 安装依赖
npm install
```

### 开发运行

```bash
# 开发模式
npm run dev

# 或
npm start
```

### 构建打包

```bash
# 构建所有平台
npm run build

# 仅构建 Windows
npm run build:win

# 仅构建 macOS
npm run build:mac
```

构建输出目录: `dist/`

## 功能模块

### 1. 系统环境一键检测

实时检测以下环境状态：
- ✅ 管理员权限状态
- ✅ Node.js 版本 (>= 22)
- ✅ Git 安装状态
- ✅ OpenClaw 安装状态
- ✅ macOS Homebrew 状态

### 2. 依赖环境一键安装

自动安装/修复：
- 🚀 Node.js >= 22 (使用国内 npmmirror 镜像)
- 🚀 Git 版本控制工具
- 🚀 Homebrew (macOS 可选)

### 3. OpenClaw 核心管理

- ⬇️ 一键安装 OpenClaw 最新版本
- ⬆️ 一键升级 OpenClaw
- 🗑️ 一键卸载 OpenClaw

### 4. 可视化配置面板

支持配置：
- 🔑 大模型 API Key
- 🌐 Base URL
- 🤖 模型名称 (gpt-4, claude-3 等)
- 🔌 服务端口
- 🌡️ Temperature 参数

### 5. 服务全生命周期管理

- ▶️ 一键启动 OpenClaw 服务
- ⏹️ 一键停止服务
- 🌐 自动打开浏览器访问管理面板
- 📊 实时显示运行时间和状态

### 6. 实时日志系统

- 📝 全流程实时输出执行日志
- ⏰ 带时间戳的日志记录
- 🔍 日志过滤 (全部/信息/错误)
- 💾 日志导出功能

## 双平台深度适配

### Windows 端

- ✅ 自动检测并申请管理员权限
- ✅ 静默安装 Node.js 和 Git
- ✅ 自动写入系统环境变量
- ✅ 全程使用国内镜像源加速

### macOS 端

- ✅ 自动处理 sudo 权限弹窗
- ✅ 优先使用 Homebrew 安装依赖
- ✅ 无 Homebrew 时引导一键安装
- ✅ 自动配置 zsh/bash 环境变量
- ✅ 同时适配 Apple Silicon 和 Intel 芯片

## 国内镜像源配置

项目默认使用以下国内镜像源：

| 资源 | 镜像地址 |
|------|----------|
| npm | https://registry.npmmirror.com |
| Node.js (Win) | https://npmmirror.com/mirrors/node |
| Git (Win) | https://npmmirror.com/mirrors/git-for-windows |
| GitHub | https://gh.api.99988866.xyz/https://github.com |

## 界面预览

### 环境检测页面
- 可视化展示所有环境检测状态
- 状态卡片实时更新
- 一键修复按钮

### 一键安装页面
- 安装向导步骤指示器
- 实时进度条显示
- 安装日志实时输出

### 配置面板页面
- 表单配置大模型参数
- 快速预设按钮 (OpenAI/Azure/Claude)
- 配置保存和重置

### 服务管理页面
- 服务状态指示器
- 启动/停止/打开面板按钮
- 运行时间统计

### 运行日志页面
- 实时日志输出
- 日志级别过滤
- 日志导出功能

## 开发指南

### 添加新的 IPC 通信

1. 在主进程 `src/main.js` 中添加处理程序：
```javascript
ipcMain.handle('your-channel', async (event, data) => {
  // 处理逻辑
  return { success: true, data: result };
});
```

2. 在预加载脚本 `src/preload.js` 中暴露 API：
```javascript
contextBridge.exposeInMainWorld('electronAPI', {
  yourMethod: (data) => ipcRenderer.invoke('your-channel', data)
});
```

3. 在前端 `src/renderer/app.js` 中调用：
```javascript
const result = await window.electronAPI.yourMethod(data);
```

### 添加新的页面区块

1. 在 `index.html` 中添加 section：
```html
<section id="your-section" class="section">
  <!-- 页面内容 -->
</section>
```

2. 在 `styles.css` 中添加样式

3. 在 `app.js` 中添加页面逻辑和导航切换

## 打包配置

### Windows 打包

```json
{
  "win": {
    "target": ["nsis", "portable"],
    "icon": "assets/icon.ico",
    "requestedExecutionLevel": "requireAdministrator"
  }
}
```

生成文件：
- `OpenClaw 部署助手 Setup.exe` - 安装包
- `OpenClaw 部署助手.exe` - 便携版

### macOS 打包

```json
{
  "mac": {
    "target": ["dmg", "zip"],
    "icon": "assets/icon.icns",
    "hardenedRuntime": true
  }
}
```

生成文件：
- `OpenClaw 部署助手.dmg` - 磁盘镜像
- `OpenClaw 部署助手-mac.zip` - 压缩包

## 常见问题

### Q: Windows 安装时提示需要管理员权限？
A: 右键点击安装程序，选择"以管理员身份运行"。

### Q: macOS 安装后无法打开？
A: 前往"系统偏好设置" -> "安全性与隐私" -> 允许从以下位置下载的应用，点击"仍要打开"。

### Q: 安装过程中网络超时？
A: 所有下载均使用国内镜像，如遇超时请检查网络连接或稍后重试。

### Q: 如何查看详细日志？
A: 切换到"运行日志"页面，可以查看所有操作的详细日志输出。

### Q: 服务启动失败？
A: 请检查：
1. OpenClaw 是否已正确安装
2. 端口是否被占用
3. 配置文件是否正确

## 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目基于 [MIT](LICENSE) 许可证开源。

## 致谢

- [Electron](https://electronjs.org/) - 跨平台桌面应用框架
- [OpenClaw](https://github.com/openclaw-org/openclaw) - 小龙虾 AI 智能体
- [npmmirror](https://npmmirror.com/) - 国内 npm 镜像

---

<p align="center">
  Made with ❤️ for OpenClaw Community
</p>
