# Hubble Claw — Skills Installation Guide

1. 将以下配置文件同步到你的 workspace：

| 文件 | 说明 | 来源 |
|------|------|------|
| `AGENTS.md` | Agent 核心行为指令 | https://github.com/HubbleVision/hubble-claw/blob/main/AGENTS.md |
| `SOUL.md` | Agent 灵魂 / 人格定义 | https://github.com/HubbleVision/hubble-claw/blob/main/SOUL.md |
| `IDENTITY.md` | Agent 身份信息 | https://github.com/HubbleVision/hubble-claw/blob/main/IDENTITY.md |
| `GROUP-CHAT.md` | 群聊场景行为协议 | https://github.com/HubbleVision/hubble-claw/blob/main/GROUP-CHAT.md |
| `HEARTBEAT.md` | 后台心跳监控策略 | https://github.com/HubbleVision/hubble-claw/blob/main/HEARTBEAT.md |
| `BOOTSTRAP.md` | 启动引导流程 | https://github.com/HubbleVision/hubble-claw/blob/main/BOOTSTRAP.md |

2. 将以下工具同步到对应目录：

| 文件 | 目标路径 | 说明 | 来源 |
|------|----------|------|------|
| `hubble.sh` | `tools/hubble.sh` | 批量并行 API 查询工具 | https://github.com/HubbleVision/hubble-claw/blob/main/tools/hubble.sh |


3. 安装以下 skill

## Environment Variables

Set the following environment variables before use:

```bash
# Hubble Market Stock (必需)
export MARKET_API_BASE_URL="http://localhost:8080"
export MARKET_API_KEY="your-market-api-key"

# Tavily 深度搜索 (必需)
export TAVILY_API_KEY="tvly-your-key-here"
```

---

## Skills Installation

### 1. Skill Router — Skill 编排中心
- Source: https://github.com/HubbleVision/hubble-claw/blob/main/skills/skill-router

---

### 2. Market Stock — 股票数据和指标
需升级到最新版 v2.4.0
- Source: https://github.com/HubbleVision/hubble-claw/blob/main/skills/market-stock
- Env: `MARKET_API_BASE_URL`, `MARKET_API_KEY`

---

### 3. AlphaEar News — 财经新闻聚合
- Source: https://github.com/RKiding/Awesome-finance-skills/tree/main/skills/alphaear-news

---

### 4. AlphaEar Reporter — 研报生成
- Source: https://github.com/RKiding/Awesome-finance-skills/tree/main/skills/alphaear-reporter

---

### 5. Stock Liquidity — 股票流动性分析
- Source: https://github.com/himself65/finance-skills/tree/main/skills/stock-liquidity

---

### 6. Estimate Analysis — 分析师预期分析
- Source: https://github.com/himself65/finance-skills/tree/main/skills/estimate-analysis

---

### 7. Earnings Recap — 财报回顾
- Source: https://github.com/himself65/finance-skills/tree/main/skills/earnings-recap

---

### 8. Skill Vetter — 技能安全审计
- Source: https://github.com/openclaw/skills/blob/main/skills/spclaudehome/skill-vetter

---

### 9. Tavily — 深度网页搜索

**方式一：自动配置**

```bash
openclaw configure --section web
# 选择 Tavily，输入 API key
```

**方式二：手动配置**

在 OpenClaw config 中添加：

```json5
{
  plugins: {
    entries: {
      tavily: {
        enabled: true,
        config: {
          webSearch: {
            apiKey: "tvly-...",
            baseUrl: "https://api.tavily.com"
          }
        }
      }
    }
  },
  tools: {
    web: {
      search: {
        provider: "tavily"
      }
    }
  }
}
```

- Docs: https://docs.openclaw.ai/tools/tavily
- Env: `TAVILY_API_KEY`


---

### 10. WeChat Article Extractor — 微信公众号文章读取

- Source: https://github.com/openclaw/skills/tree/main/skills/chunhualiao/wechat-article-extractor


