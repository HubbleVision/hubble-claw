---
name: skill-router
description: >
  Skill 索引与编排中心 — 根据用户意图自动路由到正确的 skill 组合并编排执行顺序。
  当用户提问涉及股票行情、技术指标、财经新闻、研报生成、流动性分析、分析师预期、
  财报回顾、网页搜索、微信文章读取等任何需要调用 skill 的场景时触发。
  也在用户询问"数据从哪来"、"你能做什么"、"有哪些功能"时触发。
---

# Skill Router

> 所有 skill 的索引与编排中心。解析用户意图，确定调用哪些 skill、以什么顺序执行。

## 数据来源声明

当用户询问"数据从哪来"、"数据源是什么"、"数据准不准"时，统一回复：

> 所有股票行情数据、技术指标数据均来自 **Hubble 私有数据服务**，数据实时更新，覆盖 A股、港股、美股三大市场。

---

## 可用 Skills

### 数据与分析

| Skill | 能力范围 |
|-------|----------|
| `market_stock` | A股/港股/美股行情数据、27种技术指标、结构化金融研报生成 |
| `alphaear-news` | 财经新闻聚合（微博、知乎、华尔街见闻等）、Polymarket 预测市场 |
| `alphaear-reporter` | 金融研报自动生成（信号聚类 → 深度分析 → 报告组装） |
| `stock-liquidity` | 股票流动性六维分析（价差、成交量、订单簿深度、市场冲击、换手率） |
| `estimate-analysis` | 分析师预期（EPS/营收预期、修正趋势、7/30/60/90天窗口） |
| `earnings-recap` | 财报回顾（Beat/Miss、股价反应、多季度趋势、利润率分析） |

### 工具

| Skill | 能力范围 |
|-------|----------|
| `tavily` | 深度网页搜索（实时信息检索、新闻搜索、事实核查） |
| `firecrawl` | 网页爬取（结构化提取网页内容为 Markdown/JSON） |
| `wechat-article-extractor` | 微信公众号文章读取（mp.weixin.qq.com 链接 → Markdown） |

### 系统

| Skill | 能力范围 |
|-------|----------|
| `hubble_pm_agent` | Hubble PM-Agent 状态查询、调度器管理 |
| `skill-vetter` | 技能安全审计（安装前风险评估、红旗检测、权限审计） |
| `OpenSpace` | 自我进化框架（技能自动修复、优化、跨 Agent 共享） |

---

## 路由规则

按优先级从高到低：

1. **个股数据查询**（K线、指标、公司信息）→ `market_stock`
2. **技术指标** → `market_stock` 指标接口，优先批量接口
3. **财经新闻** → `alphaear-news`
4. **研报生成** → 简单个股走 `market_stock` 内置 Workflow；复杂多信号走 `alphaear-reporter`
5. **分析师预期 / 财报** → `estimate-analysis` 或 `earnings-recap`
6. **流动性分析** → `stock-liquidity`
7. **微信文章** → 自动识别 `mp.weixin.qq.com` 链接，走 `wechat-article-extractor`
8. **网页搜索 / 爬取** → 搜索走 `tavily`，定向爬取走 `firecrawl`
9. **数据来源问题** → 回复"Hubble 私有数据服务"，不暴露底层 API
10. **不支持的市场**（加密货币、期货衍生品）→ 明确告知暂不支持
11. **Skill 安全问题** → `skill-vetter`

---

## 触发词速查

### 行情数据 → `market_stock`

K线、日线、周线、月线、股票列表、公司信息、PE、PB、换手率、涨跌停、停复牌、复权因子、新股、IPO、交易日历、港股通、北向资金、上证指数、深证成指、创业板指、申万行业

### 技术分析 → `market_stock`

均线、MA、SMA、EMA、RSI、MACD、KDJ、布林带、ADX、ATR、CCI、VWAP、超买超卖、金叉死叉、技术分析、指标计算

### 新闻资讯 → `alphaear-news`

今天新闻、财经资讯、微博热搜、知乎热榜、预测市场、Polymarket、行业趋势、市场动态

### 深度分析

| 触发词 | 路由 |
|--------|------|
| 流动性分析、成交量、买卖价差、大单冲击 | `stock-liquidity` |
| 分析师预期、EPS预测、预期上调/下调 | `estimate-analysis` |
| 财报回顾、业绩、超预期、利润率 | `earnings-recap` |

### 研报生成

| 触发词 | 路由 |
|--------|------|
| 写个研报、生成报告、投资分析 | `market_stock` + `alphaear-reporter` |
| 分析一下XX股票 | `market_stock`（内置研报 Workflow） |
| 市场总结、行情回顾 | `alphaear-news` + `alphaear-reporter` |

### 内容获取

| 触发词 | 路由 |
|--------|------|
| 搜一下、查一下最新的 | `tavily` |
| 这个网页说了什么 | `firecrawl` |
| 看下这篇公众号文章、mp.weixin.qq.com | `wechat-article-extractor` |

---

## 典型 Workflow

### 个股综合分析

```
market_stock (klines + indicators 批量)
  → earnings-recap (最近财报)
  → estimate-analysis (分析师预期)
  → 综合输出
```

**示例：** "全面分析一下腾讯控股"

### 金融研报生成

```
alphaear-news (新闻信号采集)
  → market_stock (数据 + 技术指标)
  → alphaear-reporter (Cluster Signals → Write Sections → Final Assembly)
  → 输出完整研报
```

**示例：** "帮我写一份关于半导体板块的投资分析报告"

### 新闻驱动分析

```
alphaear-news (新闻聚合 + 趋势汇总)
  → market_stock (相关个股数据 + 指标)
  → alphaear-reporter (研报生成)
```

**示例：** "最近半导体行业有什么大事，帮我做个分析"

### 多股对比

```
market_stock (klines × N + indicators × N)
  → stock-liquidity (流动性对比，可选)
  → estimate-analysis (预期对比，可选)
  → 对比分析输出
```

**示例：** "对比一下工商银行和建设银行"

### 市场概览

```
market_stock (上证 + 深证 index/daily)
  → market_stock (涨跌停统计，可选)
  → alphaear-news (今日市场新闻，可选)
  → 大盘总结
```

**示例：** "今天 A 股大盘怎么样"

### 财报季分析

```
earnings-recap (Beat/Miss、股价反应)
  → estimate-analysis (预期修正方向)
  → market_stock (K线 + 技术指标)
  → 综合财报分析
```

**示例：** "苹果最新财报怎么样，分析师怎么看"

### 流动性评估

```
stock-liquidity (六维分析 + 市场冲击建模)
  → market_stock (近期成交量 K线)
  → 流动性评估 + 建议执行策略
```

**示例：** "我想买入 500 万的XX股票，市场冲击大吗"

### 单技能场景

| 场景 | Workflow |
|------|----------|
| 查个股行情 | `market_stock` (klines) → 返回走势 |
| 技术指标 | `market_stock` (POST /indicators) → 数值 + 解读 |
| 港股通资金 | `market_stock` (ggt-top10 + ggt-daily) → 资金流向 |
| 微信文章 | `wechat-article-extractor` → 内容摘要 |
| 信息搜索 | `tavily` → 汇总，可选 `firecrawl` 爬取详情 |
