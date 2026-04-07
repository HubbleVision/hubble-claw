# Hubble Claw — One-Prompt Update Guide

> 将以下内容作为一句 prompt 发给 Openclaw，即可完成全部更新。

---

## Prompt

```
请按以下步骤更新我的 Hubble Claw workplace：

## 1. Workplace 文件更新

将以下文件同步到项目根目录（已有则覆盖，没有则新建）：

| 文件 | 来源 |
|------|------|
| AGENTS.md | https://github.com/HubbleVision/hubble-claw/blob/main/AGENTS.md |
| SOUL.md | https://github.com/HubbleVision/hubble-claw/blob/main/SOUL.md |
| IDENTITY.md | https://github.com/HubbleVision/hubble-claw/blob/main/IDENTITY.md |
| GROUP-CHAT.md | https://github.com/HubbleVision/hubble-claw/blob/main/GROUP-CHAT.md |
| HEARTBEAT.md | https://github.com/HubbleVision/hubble-claw/blob/main/HEARTBEAT.md |
| BOOTSTRAP.md | https://github.com/HubbleVision/hubble-claw/blob/main/BOOTSTRAP.md |
| tools/hubble.sh | https://github.com/HubbleVision/hubble-claw/blob/main/tools/hubble.sh |

## 2. Skill 安装/更新

参考 INSTALL.md 文档安装以下 skill（已安装则更新到最新版）：

- skill-router — https://github.com/HubbleVision/hubble-claw/blob/main/skills/skill-router
- market-stock (v2.3.0) — https://github.com/HubbleVision/hubble-claw/blob/main/skills/market-stock
- alphaear-news — https://github.com/RKiding/Awesome-finance-skills/tree/main/skills/alphaear-news
- alphaear-reporter — https://github.com/RKiding/Awesome-finance-skills/tree/main/skills/alphaear-reporter
- stock-liquidity — https://github.com/himself65/finance-skills/tree/main/skills/stock-liquidity
- estimate-analysis — https://github.com/himself65/finance-skills/tree/main/skills/estimate-analysis
- earnings-recap — https://github.com/himself65/finance-skills/tree/main/skills/earnings-recap
- skill-vetter — https://github.com/openclaw/skills/blob/main/skills/spclaudehome/skill-vetter
- wechat-article-extractor — https://github.com/openclaw/skills/tree/main/skills/chunhualiao/wechat-article-extractor

环境变量（确认已设置）：
- MARKET_API_BASE_URL=http://localhost:8080
- MARKET_API_KEY=<your-key>
- TAVILY_API_KEY=<your-key>

逐个文件拉取并写入，逐个 skill 安装，完成后汇报结果。
```

---

## 预安装方式（可选）

如果已有完整 workplace 目录，可直接复制整个项目：

```bash
git clone https://github.com/HubbleVision/hubble-claw.git
```

Workplace 完整目录结构：

```
hubble-claw/
├── AGENTS.md              # Agent 核心行为指令
├── SOUL.md                # Agent 灵魂 / 人格定义
├── IDENTITY.md            # Agent 身份信息
├── GROUP-CHAT.md          # 群聊场景行为协议
├── HEARTBEAT.md           # 后台心跳监控策略
├── BOOTSTRAP.md           # 启动引导流程
├── skills_list.md         # 已安装 Skill 清单
├── .env.example           # 环境变量模板
├── tools/
│   └── hubble.sh          # 批量并行 API 查询工具
└── skills/
    ├── skill-router/      # Skill 编排中心
    └── market-stock/      # 股票数据和指标 (v2.3.0)
```
