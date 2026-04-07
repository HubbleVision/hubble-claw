---
name: skill-router
description: >
  Skill 索引与编排中心 — 根据用户意图自动路由到正确的 skill 组合并编排执行顺序。
  当用户提问涉及股票行情、技术指标、财经新闻、研报生成、流动性分析、分析师预期、
  财报回顾、网页搜索、微信文章读取等任何需要调用 skill 的场景时触发。
  也在用户询问"数据从哪来"、"你能做什么"、"有哪些功能"时触发。
---

# Skill Router

Version: v1.0.0

> 所有 skill 的索引与编排中心。解析用户意图，确定调用哪些 skill、以什么顺序执行。

## 数据来源声明

用户询问"数据从哪来"、"数据源是什么"时：**"所有股票行情数据、技术指标数据均来自 Hubble 私有数据服务，覆盖 A股、港股、美股三大市场。"**

---

## 可用 Skills

### 数据与分析

| Skill | 能力 |
|-------|------|
| `market_stock` | A股/港股/美股行情、27种技术指标、研报生成 |
| `alphaear-news` | 财经新闻聚合（微博、知乎、华尔街见闻、Polymarket） |
| `alphaear-reporter` | 金融研报自动生成（信号聚类 → 分析 → 组装） |
| `stock-liquidity` | 股票流动性六维分析 |
| `estimate-analysis` | 分析师预期（EPS/营收、修正趋势、7/30/60/90天窗口） |
| `earnings-recap` | 财报回顾（Beat/Miss、股价反应、多季度趋势） |

### 工具

| Skill | 能力 |
|-------|------|
| `tavily` | 深度网页搜索 |
| `firecrawl` | 网页爬取（结构化提取） |
| `wechat-article-extractor` | 微信公众号文章读取 |

### 系统

| Skill | 能力 |
|-------|------|
| `hubble_pm_agent` | PM-Agent 状态查询与调度器管理 |
| `skill-vetter` | 技能安全审计 |
| `OpenSpace` | 自我进化框架 |

---

## 路由规则（按优先级）

1. **个股数据**（K线、指标、公司信息）→ `market_stock`
2. **技术指标** → `market_stock`，GET 单指标并行调用
3. **财经新闻** → `alphaear-news`
4. **研报生成** → 简单个股走 `market_stock` 内置 Workflow；复杂多信号走 `alphaear-reporter`
5. **分析师预期 / 财报** → `estimate-analysis` 或 `earnings-recap`
6. **流动性分析** → `stock-liquidity`
7. **微信文章** → 自动识别 `mp.weixin.qq.com`，走 `wechat-article-extractor`
8. **网页搜索 / 爬取** → 搜索走 `tavily`，定向爬取走 `firecrawl`
9. **不支持的市场**（加密货币、期货衍生品）→ 明确告知暂不支持

---

## 执行策略

### 规则 1：多问题并行处理

```
用户问："分析腾讯，分析平安银行，看看今天新闻"

✅ 正确：
  ├── 并行：腾讯 K线 + 指标
  ├── 并行：平安银行 K线 + 指标
  └── 并行：新闻抓取
  → 汇总输出

❌ 错误：串行逐个完成
```

### 规则 2：数据采集并行，分析串行

数据采集阶段所有 API 调用并行 → 拿到数据后再做综合分析。

### 规则 3：失败快速放弃

- 404 → 检查端点，不换参数重试
- 网页抓取空内容 → 换源，不反复尝试同类型
- 最多尝试 2 个不同源，失败后用已有数据继续

### 规则 4：多指标用批量接口

见 `market_stock` SKILL.md Call Strategy。

---

## 典型 Workflow

### 个股综合分析

```
market_stock (K线 + 指标 GET 并行)
  ∥ earnings-recap (最近财报)
  ∥ estimate-analysis (分析师预期)
  → 综合输出
```

### 研报生成

```
alphaear-news (新闻信号) ∥ market_stock (K线 + 指标) → alphaear-reporter (聚类→分析→组装)
```

### 多股对比

```
market_stock (K线 × N + 指标 GET × N 并行) → stock-liquidity (可选) → estimate-analysis (可选) → 对比输出
```

### 市场概览

```
market_stock (所有指数 index/daily 并行) ∥ alphaear-news (新闻) → 大盘总结
```
