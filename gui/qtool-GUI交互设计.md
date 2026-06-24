# qtool GUI 交互重设计

日期: 2026-06-23
状态: 已实现
关联: gui/qtool-GUI安装包-PRD.md

## 1. 背景

当前 `gui/main.swift` 使用 NavigationSplitView + List 展示菜单项，每个条目仅显示编号和 name（如 `1.1 docHome`），用户无法直接知道该操作的作用，需点击后才看到描述。虽然点击后自动执行，但这导致"先选再知"的体验问题。

## 2. 目标

- 所有操作在列表中**一目了然**：name + 描述同时可见
- **点击 = 直接执行**：没有"先选中再点执行"的中间步骤
- 保留 Terminal-launcher 架构：弹 Terminal 执行，不碰 PTY
- 搜索框支持实时过滤
- 右侧悬浮索引支持快速分类定位

## 3. 交互设计

### 3.1 整体布局

多源模式（有分段选择器）：
```
┌──────────────────────────────────────────┐
│ [ qbase ] [ qtool ]   ← 多源分段选择器    │
├──────────────────────────────────────────┤
│ 🔍 搜索操作...    /path/to/json           │  ← 搜索框 + 可点击路径
├──────────────────────────────────┬───────┤
│ doc 文档                      (6)│ doc   │  ← 右侧悬浮索引
│  📄 docHome — 打开文档主页       │ 5     │
│  📋 docVersionPlan — 版本需求    │ code  │
├──────────────────────────────────┤ 4     │
│ branchInfo 分支               (5)│ pack  │
│  🌿 gitBranch — 创建分支...      │ 4     │
│  ...                             │ cust  │
├──────────────────────────────────┤ 1     │
│ code 代码                     (4)│       │
├──────────────────────────────────┤       │
│ pack 打包                     (4)│       │
├──────────────────────────────────┤       │
│ custom 自定义                 (1)│       │
├──────────────────────────────────┴───────┤
│ 📄 /path/to/json [catalog]               │  ← 底部路径栏
└──────────────────────────────────────────┘
```

- 单窗口，无左右分栏
- 多源时顶部显示分段选择器切换菜单源（如 qbase / qtool）
- 所有操作按 JSON 顶层 key（如 `catalog`、`custom`）分组展示
- 每行：`图标 name — 描述`
- 搜索框中可点击显示当前 JSON 全路径，点击在 Finder 中打开
- 底部状态栏显示当前 JSON 路径和类型
- 搜索时：过滤所有行，匹配分类标题保留

### 3.2 搜索框

- 输入即过滤，按 name 和 des 匹配
- 无搜索结果时显示空状态
- 清空恢复全量显示

### 3.3 右侧分类索引

- 列表右侧悬浮半透明面板，显示所有分类
- 每行：分类名 | 操作数量（如 `doc 6`）
- 顶部「全部」项，点击回到列表顶部、取消高亮
- 点击某分类 → 列表滚动定位到该 section、索引对应项高亮、列表 header 变蓝色
- 所有行的整个空白区域均可点击（`.frame(maxWidth: .infinity)` + `.contentShape(Rectangle())`）
- VStack spacing = 0，行间无不可点击间隙

### 3.4 交互流程

1. 用户打开应用，看到全部分类 + 操作列表
2. 每项显示 `name — 描述`，一目了然
3. 用户可：
   - 输入文字搜索
   - 点击右侧索引快速定位分类
   - 直接滚动浏览
4. 点击任意操作 → 行高亮 → 弹 Terminal 自动执行
5. 选中状态 0.8s 后自动复位，同一项可重复点击

### 3.5 视觉设计

- 分类 header：灰色 + 数量 badge，选中时蓝色粗体
- 操作行：`图标 name 粗体 — des 灰色`
- 鼠标悬停行浅灰背景
- 点击行显示绿色 ✓ 动画后恢复
- 右侧索引：超薄毛玻璃背景，选中项蓝色高亮
- 窗口尺寸：minWidth 500, minHeight 400

### 3.6 操作行样式

```
📄 docHome — 打开《移动端文档主页》
🌿 gitBranch — 分支相关:创建分支(且创建完可选择继续2操作)
📦 jenkins — 打包相关(Jenkins):执行Jenkins打包任务
```

所有 `des` 直接来自 JSON 原文，不做截断。

## 4. 技术方案

### 4.1 架构（不变）

```
点击操作 → 临时 .command 文件 → NSWorkspace.open() → Terminal 执行
→ wrapper qtool_run_action.sh → source qtool_menu.sh（剥离 showMenu/exit）→ eval action
```

**零修改原则**：不改 `.sh` 文件、不改 `qtool_menu_public.json`。JSON 支持 `command` 和 `execSourceFunAndArgs` 两种 action 类型。

### 4.2 main.swift 改动

| 改动项 | 当前 | 改为 |
|--------|------|------|
| 布局 | NavigationSplitView | 单栏 ZStack(List + 悬浮索引) |
| 列表展示 | 仅 name | 图标 + name + `—` + des |
| 搜索 | 无 | 顶部搜索框 + 实时过滤 |
| 分类导航 | 无 | 右侧悬浮索引，点击滚动定位到 section |
| 交互 | 选中即弹 Terminal | 点击弹 Terminal + checkmark 反馈 |
| 窗口尺寸 | minWidth 900 | minWidth 500 |

### 4.3 新增组件

- `ActionRowView`：操作行视图，图标 + name + des + checkmark
- `CategoryIndexView`：右侧分类索引面板
- `iconForAction()`：操作名 → emoji 图标映射表

## 5. 不使用

- 收藏/最近使用
- 内嵌结果面板
- PTY/伪终端
- 设置页面
- 全局快捷键

## 6. 实现参考

代码入口：`gui/main.swift`，单文件编译。
