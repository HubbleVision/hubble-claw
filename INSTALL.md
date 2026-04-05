# Hubble Claw — Skills Installation Guide

1. 
- 更新你的 AGENTS.md 为这个 repo 里的内容： https://github.com/HubbleVision/hubble-claw/blob/main/AGENTS.md
- 更新你的 SOUL.md 为这个 repo 里的内容： https://github.com/HubbleVision/hubble-claw/blob/main/SOUL.md


2. 安装以下 skill

## Environment Variables

Set the following environment variables before use:

```bash
# Hubble Market Stock (必需)
export MARKET_API_BASE_URL="http://localhost:8080"
export MARKET_API_KEY="your-market-api-key"

# Hubble PM Agent (必需)
export HUBBLE_API_BASE_URL="https://market-v2.bedev.hubble-rpc.xyz"
export HUBBLE_API_KEY="hb_sk_your-key-here"

# Tavily 深度搜索 (必需)
export TAVILY_API_KEY="tvly-your-key-here"
```

---

## Skills Installation

### 1. Skill Router — Skill 编排中心
- Source: https://github.com/HubbleVision/hubble-claw/blob/main/skills/skill-router

---

### 2. Market Stock — 股票数据和指标
需升级到最新版 v2.3.0
- Source: https://github.com/HubbleVision/hubble-claw/blob/main/skills/market-stock
- Env: `MARKET_API_BASE_URL`, `MARKET_API_KEY`

---

### 3. Hubble PM Agent — PM-Agent 管理
- Source: https://github.com/HubbleVision/hubble-skills/tree/main/openclaw/skills/hubble_pm_agent
- Env: `HUBBLE_API_BASE_URL`, `HUBBLE_API_KEY`
- 这个key还没拿到，先跳过安装

---

### 4. AlphaEar News — 财经新闻聚合
- Source: https://github.com/RKiding/Awesome-finance-skills/tree/main/skills/alphaear-news

---

### 5. AlphaEar Reporter — 研报生成
- Source: https://github.com/RKiding/Awesome-finance-skills/tree/main/skills/alphaear-reporter

---

### 6. Stock Liquidity — 股票流动性分析
- Source: https://github.com/himself65/finance-skills/tree/main/skills/stock-liquidity

---

### 7. Estimate Analysis — 分析师预期分析
- Source: https://github.com/himself65/finance-skills/tree/main/skills/estimate-analysis

---

### 8. Earnings Recap — 财报回顾
- Source: https://github.com/himself65/finance-skills/tree/main/skills/earnings-recap

---

### 9. Skill Vetter — 技能安全审计
- Source: https://github.com/openclaw/skills/blob/main/skills/spclaudehome/skill-vetter

---

### 10. Tavily — 深度网页搜索

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

### 11. WeChat Article Extractor — 微信公众号文章读取

- Source: https://github.com/openclaw/skills/tree/main/skills/chunhualiao/wechat-article-extractor


