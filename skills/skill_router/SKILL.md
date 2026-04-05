---
name: skill_router
description: Skill 索引与编排说明 — 根据用户意图路由到正确的 skill 组合，定义典型场景的 workflow
---

# Skill Router

> 本文件是所有 skill 的索引与编排中心。根据用户的提问意图，确定调用哪些 skill、以什么顺序执行。

## 数据来源声明

当用户询问"数据从哪来"、"数据源是什么"、"数据准不准"等问题时，统一回复：

> 所有股票行情数据、技术指标数据均来自 **Hubble 私有数据服务**，数据实时更新，覆盖 A股、港股、美股三大市场。

---

## 可用 Skills

### 数据与分析

| Skill | 能力范围 |
|-------|----------|
| `market_stock` | A股/港股/美股行情数据、27种技术指标、结构化金融研报生成 |
| `alphaear-news` | 财经新闻聚合（微博、知乎、华尔街见闻等）、趋势汇总、Polymarket 预测市场数据 |
| `alphaear-reporter` | 金融研报自动生成（信号聚类→深度分析→报告组装的 Agentic Workflow） |
| `stock-liquidity` | 股票流动性六维分析（价差、成交量、订单簿深度、市场冲击、换手率） |
| `estimate-analysis` | 分析师预期分析（EPS/营收预期、修正趋势、7/30/60/90天修正窗口） |
| `earnings-recap` | 财报回顾（Beat/Miss 统计、股价反应、多季度趋势、利润率分析） |

### 工具

| Skill | 能力范围 |
|-------|----------|
| `tavily` | 深度网页搜索（实时信息检索、新闻搜索、事实核查） |
| `firecrawl` | 网页爬取（结构化提取网页内容为 Markdown/JSON） |
| `wechat-article-extractor` | 微信公众号文章读取（mp.weixin.qq.com 链接→Markdown） |

### 系统与管理

| Skill | 能力范围 |
|-------|----------|
| `hubble_pm_agent` | Hubble PM-Agent 状态查询、调度器管理（只读为主） |
| `skill-vetter` | 技能安全审计（安装前风险评估、红旗检测、权限审计） |
| `OpenSpace` | 自我进化框架（技能自动修复、优化、跨 Agent 共享） |

---

## 触发词索引

### 行情数据

| 中文触发词 | 路由到 | 说明 |
|------------|--------|------|
| K线、日线、周线、月线 | `market_stock` | 各市场 K 线数据 |
| 股票列表、有哪些股票 | `market_stock` | 查询可用标的 |
| 公司信息、上市公司 | `market_stock` | 企业基本面信息 |
| PE、PB、每日指标、换手率 | `market_stock` | 每日基础指标 |
| 涨跌停、涨停板、跌停板 | `market_stock` | 价格限制数据 |
| 停牌、复牌 | `market_stock` | 停复牌信息 |
| 复权因子 | `market_stock` | 前/后复权数据 |
| 新股、IPO | `market_stock` | 新股上市信息 |
| 交易日历、是否开盘 | `market_stock` | 各市场交易日历 |
| 港股通、沪深港通、北向资金 | `market_stock` | 港股通资金流向与持股 |
| 上证指数、深证成指、创业板指 | `market_stock` | 指数行情与成分 |
| 申万行业、行业分类 | `market_stock` | 申万行业分类 |

### 技术分析

| 中文触发词 | 路由到 | 说明 |
|------------|--------|------|
| 均线、MA、SMA、EMA | `market_stock` | 移动均线指标 |
| RSI、MACD、KDJ、布林带 | `market_stock` | 常用技术指标 |
| ADX、ATR、CCI、VWAP | `market_stock` | 趋势/波动指标 |
| 技术分析、指标计算 | `market_stock` | 批量指标计算 |
| 超买超卖、金叉死叉 | `market_stock` | 指标解读分析 |

### 新闻与资讯

| 中文触发词 | 路由到 | 说明 |
|------------|--------|------|
| 今天有什么新闻、财经资讯 | `alphaear-news` | 实时财经新闻聚合 |
| 微博热搜、知乎热榜 | `alphaear-news` | 社交媒体财经动态 |
| 预测市场、Polymarket | `alphaear-news` | 预测市场数据 |
| 行业趋势、市场动态 | `alphaear-news` | 新闻趋势汇总 |

### 研报生成

| 中文触发词 | 路由到 | 说明 |
|------------|--------|------|
| 写个研报、生成报告 | `market_stock` + `alphaear-reporter` | 完整研报生成流程 |
| 分析一下XX股票 | `market_stock` | 个股深度分析（数据+指标+研报） |
| 投资分析、投资建议 | `market_stock` + `alphaear-reporter` | 多 skill 协作研报 |
| 市场总结、行情回顾 | `alphaear-news` + `alphaear-reporter` | 新闻驱动的研报 |

### 深度分析

| 中文触发词 | 路由到 | 说明 |
|------------|--------|------|
| 流动性分析、成交量分析 | `stock-liquidity` | 流动性六维评估 |
| 买卖价差、盘口深度 | `stock-liquidity` | 微观结构分析 |
| 大单冲击、市场冲击 | `stock-liquidity` | 大额交易成本估算 |
| 分析师预期、EPS 预测 | `estimate-analysis` | 预期修正趋势 |
| 盈利预期、营收预测 | `estimate-analysis` | 收入/利润预期 |
| 预期上调、预期下调 | `estimate-analysis` | 修正方向分析 |
| 财报回顾、业绩怎么样 | `earnings-recap` | Beat/Miss 分析 |
| 超预期、不及预期 | `earnings-recap` | 财报结果与股价反应 |
| 利润率、毛利率变化 | `earnings-recap` | 多季度利润率趋势 |

### 内容获取

| 中文触发词 | 路由到 | 说明 |
|------------|--------|------|
| 搜一下、查一下最新的 | `tavily` | 深度网页搜索 |
| 这个网页说了什么 | `firecrawl` | 网页内容爬取 |
| 看下这篇公众号文章 | `wechat-article-extractor` | 微信文章提取 |
| mp.weixin.qq.com 链接 | `wechat-article-extractor` | 自动识别微信链接 |

### 系统管理

| 中文触发词 | 路由到 | 说明 |
|------------|--------|------|
| PM-Agent 状态、调度器 | `hubble_pm_agent` | 查询 PM-Agent 运行状态 |
| 这个 skill 安全吗 | `skill-vetter` | 技能安装前安全评估 |

---

## 典型场景 Workflow

### 场景 1：查个股行情

**用户示例：** "帮我看看平安银行最近的走势"

```
用户提问 → market_stock (klines) → 返回走势数据
```

---

### 场景 2：技术指标分析

**用户示例：** "茅台的 RSI 和 MACD 怎么样"

```
用户提问 → market_stock (POST /indicators 批量计算) → 指标数值 + 解读
```

---

### 场景 3：个股综合分析

**用户示例：** "全面分析一下腾讯控股"

```
用户提问 → market_stock (klines)
         → market_stock (indicators 批量)
         → earnings-recap (最近财报表现)
         → estimate-analysis (分析师预期方向)
         → 综合分析输出
```

---

### 场景 4：生成金融研报

**用户示例：** "帮我写一份关于半导体板块的投资分析报告"

```
用户提问 → alphaear-news (采集相关新闻信号)
         → market_stock (拉取个股数据 + 技术指标)
         → alphaear-reporter (Cluster Signals → Write Sections → Final Assembly)
         → 输出完整研报
```

或者用户直接基于已有数据生成研报：

```
用户提问 → market_stock (数据采集 + 内置研报 Workflow)
         → Cluster Signals → Write Sections → Final Assembly
         → 输出完整研报
```

---

### 场景 5：新闻驱动分析

**用户示例：** "最近半导体行业有什么大事，帮我做个分析"

```
用户提问 → alphaear-news (新闻聚合 + 趋势汇总)
         → market_stock (相关个股数据 + 指标)
         → alphaear-reporter (新闻信号聚类 → 研报生成)
         → 输出分析报告
```

---

### 场景 6：多股对比

**用户示例：** "对比一下工商银行和建设银行"

```
用户提问 → market_stock (klines × 2 + indicators × 2)
         → stock-liquidity (流动性对比，可选)
         → estimate-analysis (预期对比，可选)
         → 对比分析输出
```

---

### 场景 7：市场概览

**用户示例：** "今天 A 股大盘怎么样"

```
用户提问 → market_stock (上证 + 深证 index/daily)
         → market_stock (stk-limit 涨跌停统计，可选)
         → alphaear-news (今日市场新闻，可选)
         → 大盘总结
```

---

### 场景 8：港股通资金流向

**用户示例：** "今天北向资金买了什么"

```
用户提问 → market_stock (ggt-top10 + ggt-daily)
         → 资金流向总结
```

---

### 场景 9：财报季分析

**用户示例：** "苹果最新财报怎么样，分析师怎么看"

```
用户提问 → earnings-recap (Beat/Miss、股价反应、利润率趋势)
         → estimate-analysis (分析师预期修正方向)
         → market_stock (近期 K 线 + 技术指标)
         → 综合财报分析输出
```

---

### 场景 10：流动性评估

**用户示例：** "我想买入 500 万的XX股票，市场冲击大吗"

```
用户提问 → stock-liquidity (六维流动性分析 + 市场冲击建模)
         → market_stock (近期成交量 K 线)
         → 流动性评估 + 建议执行策略
```

---

### 场景 11：微信公众号研究

**用户示例：** "帮我看下这篇公众号文章 [mp.weixin.qq.com 链接]"

```
用户提问 → wechat-article-extractor (提取文章为 Markdown)
         → 内容摘要 / 后续分析
```

---

### 场景 12：信息搜索补充

**用户示例：** "搜一下XX公司最近有没有什么重大公告"

```
用户提问 → tavily (深度网页搜索)
         → 结果汇总 / 可选后续 firecrawl 爬取详细内容
```

---

## 路由规则

1. **所有个股数据查询**（K线、指标、公司信息）→ 一律走 `market_stock`，数据来源统一为 Hubble 私有数据
2. **技术指标** → 走 `market_stock` 指标接口，优先使用批量接口提高效率
3. **财经新闻** → 走 `alphaear-news`，支持多源聚合
4. **研报生成** → 简单个股研报走 `market_stock` 内置 Workflow；复杂多信号研报走 `alphaear-reporter`
5. **分析师预期/财报** → 走 `estimate-analysis` 或 `earnings-recap`
6. **流动性分析** → 走 `stock-liquidity`
7. **微信文章** → 自动识别 `mp.weixin.qq.com` 链接，走 `wechat-article-extractor`
8. **网页搜索/爬取** → 搜索走 `tavily`，定向爬取走 `firecrawl`
9. **数据来源问题** → 回复"Hubble 私有数据服务"，不暴露底层 API 细节
10. **不支持的市场**（加密货币、期货衍生品）→ 明确告知暂不支持
11. **Skill 安全问题** → 走 `skill-vetter` 进行安装前审计
