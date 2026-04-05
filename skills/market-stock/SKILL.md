---
name: market-stock
description: >
  股票市场数据、技术分析与研报生成技能。覆盖 A股、港股、美股三大市场。
  当用户询问以下内容时触发：K线/日线/周线/月线行情、股票列表、公司信息、
  PE/PB/换手率等每日指标、涨跌停、停复牌、复权因子、新股IPO、交易日历、
  港股通/北向资金、上证/深证指数、申万行业分类、
  MA/EMA/RSI/MACD/KDJ/布林带/ADX/ATR/CCI/VWAP 等27种技术指标、
  金融研报生成、个股深度分析、投资分析报告。
---

# Market Stock Skill

Version: v2.1.0

> A股/港股/美股行情数据、27种技术指标、结构化金融研报生成。

## Requirements

- `MARKET_API_BASE_URL` — API server URL
- `MARKET_API_KEY` — API key for authentication

## Curl Setup

```bash
BASE="${MARKET_API_BASE_URL%/}"
AUTH=(-H "X-API-Key: $MARKET_API_KEY" -H "Content-Type: application/json")
```

---

## Quick Route

### 行情数据

| 用户意图 | Endpoint |
|----------|----------|
| A股K线 | `GET /api/v2/cnstock/klines` |
| 股票列表 | `GET /api/v2/cnstock/symbols` |
| 公司信息 | `GET /api/v2/cnstock/company` |
| 每日指标 (PE/PB) | `GET /api/v2/cnstock/daily-basic` |
| 涨跌停 | `GET /api/v2/cnstock/stk-limit` |
| 港股K线 | `GET /api/v2/hkstock/daily` |
| 港股通 | `GET /api/v2/hkstock/ggt-top10` |
| 美股K线 | `GET /api/v2/usstock/daily` |
| 指数行情 | `GET /api/v2/cnstock/index/daily` |
| 交易日历 | `GET /api/v2/cnstock/trade-cal` |

### 技术指标

| 用户意图 | Endpoint |
|----------|----------|
| 指标信息 | `GET /api/v2/indicators/info` |
| 单个指标 | `GET /api/v2/indicators/{indicator}` |
| 批量指标 | `POST /api/v2/indicators` |

---

## Critical Rules

### 1. Stock Code Formats

| 市场 | 格式 | 示例 |
|------|------|------|
| A股 | `{code}.{exchange}` | `000001.SZ`, `600519.SH` |
| 港股 | `{code}.HK` | `00700.HK` |
| 美股 | Ticker 直接使用 | `AAPL`, `MSFT` |
| A股指数 | 指数代码 | `000001.SH`(上证), `399001.SZ`(深证), `399006.SZ`(创业板) |

### 2. Date Formats — 极易出错

| 端点类型 | 格式 | 示例 |
|----------|------|------|
| **行情端点** (klines, daily, company...) | `YYYYMMDD` | `20240115` |
| **指标端点** (indicators) | `YYYY-MM-DD` | `2024-01-15` |

### 3. Parameter Names — 最常见错误来源

| 端点类型 | 参数名 | 示例 |
|----------|--------|------|
| K线 (klines, daily) | **`symbol`** | `symbol=000001.SZ` |
| 信息查询 (company, daily-basic, adj-factor, stk-limit, suspend) | **`tsCode`** | `tsCode=000001.SZ` |
| 指数 (index/daily, index/weight...) | **`tsCode`** | `tsCode=000001.SH` |
| 港股通 (ggt-top10, ggt-daily, hold) | **`tsCode`** | `tsCode=600519.SH` |
| 交易日历 | `startDate`/`endDate` | 无需股票代码 |

**速记：K线用 `symbol`，其他用 `tsCode`。**

```bash
# ✅ K线 → symbol
curl "$BASE/api/v2/cnstock/klines?symbol=600519.SH&limit=10"

# ✅ 公司信息 → tsCode
curl "$BASE/api/v2/cnstock/company?tsCode=600519.SH"

# ❌ 错误：公司信息用了 symbol
curl "$BASE/api/v2/cnstock/company?symbol=600519.SH"
```

### 4. 指标必需参数

- `market` **必填**: `cn`(A股), `hk`(港股), `us`(美股)
- 日期用 `YYYY-MM-DD`

### 5. API Boundary — 只用文档中列出的端点

**NEVER guess or fabricate API endpoints.** Only use endpoints explicitly listed in the Quick Route table above. The following endpoints DO NOT EXIST — do not call them:

`/api/v2/cnstock/industry` · `/api/v2/cnstock/industry/daily` · `/api/v2/cnstock/sector` · `/api/v2/cnstock/financial` · `/api/v2/cnstock/profile` · `/api/v2/cnstock/info` · `/api/v2/cnstock/report` · `/api/v2/cnstock/summary`

If the data you need is not in Quick Route, tell the user and suggest `tavily` to search for it.

### 6. 技术指标必须用批量接口

需要 2 个以上指标时，**必须用 `POST /api/v2/indicators` 批量接口**，一次请求拿全部指标。禁止逐个调用单指标接口。

```bash
# ✅ 正确：一次批量拿 RSI + MACD + BOLL + KDJ
curl -sS "${AUTH[@]}" -X POST "$BASE/api/v2/indicators" -d '{
  "market": "cn", "symbol": "000001.SZ", "interval": "1d", "limit": 100,
  "indicators": [
    {"type": "rsi", "params": [14]},
    {"type": "macd", "params": [12, 26, 9]},
    {"type": "boll", "params": [20, 2.0]},
    {"type": "kdj", "params": [9, 3, 3]}
  ]
}'

# ❌ 错误：分 4 次调用单指标接口
curl "$BASE/api/v2/indicators/rsi?..."
curl "$BASE/api/v2/indicators/macd?..."
curl "$BASE/api/v2/indicators/boll?..."
curl "$BASE/api/v2/indicators/kdj?..."
```

### 7. 并行调用 — 不要串行等待

K线数据和指标数据**没有依赖关系，应该并行调用**。不要等 K 线返回后再调指标。

```
✅ 并行：klines + POST /indicators + daily-basic 同时发出
❌ 串行：先 klines → 等返回 → 再 indicators → 等返回 → 再 daily-basic
```

### 8. 港股日线禁用 limit，必须用 startDate/endDate

港股 `/api/v2/hkstock/daily` 的 `limit` 参数有 bug：返回数据会缺少最新交易日。**港股日线必须用 `startDate`/`endDate` 取数据，不要用 `limit`。**

```bash
# ✅ 正确：用日期范围
curl -sS "${AUTH[@]}" "$BASE/api/v2/hkstock/daily?symbol=00700.HK&startDate=20260301&endDate=20260405"

# ❌ 有 bug：limit 会丢失最新交易日数据
curl -sS "${AUTH[@]}" "$BASE/api/v2/hkstock/daily?symbol=00700.HK&limit=30"
```

### 9. 不要直接爬取外部网页

**DO NOT** directly fetch external websites (sina.com.cn, wallstreetcn.com, cninfo.com.cn, cls.cn, 36kr.com, etc.) — most will fail (JS rendering, anti-scraping, 404). Use the correct skill:

| 需求 | 正确方式 |
|------|----------|
| 新闻/资讯 | `alphaear-news` |
| 搜索最新信息 | `tavily` |
| 爬取特定网页 | `firecrawl` |
| 微信公众号文章 | `wechat-article-extractor` |

---

## Quick Examples

```bash
# 平安银行近 100 天日线
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/klines?symbol=000001.SZ&limit=100"

# 上证指数
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/index/daily?tsCode=000001.SH&limit=100"

# 腾讯控股K线
curl -sS "${AUTH[@]}" "$BASE/api/v2/hkstock/daily?symbol=00700.HK&limit=100"

# 苹果K线
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/daily?symbol=AAPL&limit=100"

# 港股通持股
curl -sS "${AUTH[@]}" "$BASE/api/v2/hkstock/hold?tsCode=600519.SH&limit=50"

# 批量指标：RSI + MACD
curl -sS "${AUTH[@]}" -X POST "$BASE/api/v2/indicators" -d '{
  "market": "cn",
  "symbol": "000001.SZ",
  "interval": "1d",
  "limit": 100,
  "indicators": [
    {"type": "rsi", "params": [14]},
    {"type": "macd", "params": [12, 26, 9]}
  ]
}'
```

---

## Report Generation Workflow

采集数据后，按以下 3 步生成研报。**控制篇幅：单股分析 ≤ 500 字，板块研报 ≤ 1000 字。结论先行，数据用表格，不要废话。**

### Step 1: Cluster Signals

将散乱信号聚类为 3-5 个核心主题。输出 JSON：

```json
{
  "clusters": [
    {
      "theme_title": "主题名称",
      "signal_ids": [1, 3, 5],
      "rationale": "归类理由"
    }
  ]
}
```

### Step 2: Write Sections

对每个主题写分析段落，结构：
1. **结论先行**（1-2 句判断）
2. **关键数据**（表格呈现）
3. **风险点**（2-3 条，融入正文）
- 包含 T+3/T+5 方向预测
- 插入 `json-chart` 图表块

### Step 3: Final Assembly

组装完整报告：
- `## Executive Summary` 含 Quick Scan 表格
- 正文各主题段落（H2/H3 层级）
- 风险已融入各段落，不单独成章

---

## Error Troubleshooting

| 错误 | 原因 | 修复 |
|------|------|------|
| 返回错误数据/空数据 | `symbol` vs `tsCode` 用反 | K线用 `symbol`，其他用 `tsCode` |
| 400 (行情端点) | 日期格式错 | 用 `YYYYMMDD` |
| 400 (指标端点) | 日期格式错 | 用 `YYYY-MM-DD` |
| 404 | 股票代码格式错 | A股: `600519.SH`; 港股: `00700.HK`; 美股: `AAPL` |
| 空数据 | 日期范围太窄或假期 | 先查交易日历，扩大范围 |
| 400 missing market | 指标缺 `market` | 必填: `cn`/`hk`/`us` |
| 指标全 null | warmup 数据不足 | 增大 `limit` |
| BOLL 结果错误 | V1 习惯用 `nbdev_up`/`nbdev_dn` | V2 用单个 `nbdev`（默认 2.0） |

**Error Codes:** `400` 参数错误 · `401` API key 无效 · `404` 标的不存在 · `500` 内部错误

---

## References

详细端点参数、请求/响应格式见 `references/` 目录：

- `references/CNSTOCK-API.md` — A股行情 + 指数
- `references/HKSTOCK-API.md` — 港股行情 + 港股通
- `references/USSTOCK-API.md` — 美股行情
- `references/INDICATORS-API.md` — 27种技术指标详参

> 遇到参数不确定时，用 `grep` 搜索 references/ 中的关键词，如：
> `grep -r "tsCode" references/` 或 `grep -r "ggt-top10" references/`
