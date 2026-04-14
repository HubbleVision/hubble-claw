---
name: market-stock
description: >
  股票市场数据、技术分析与研报生成技能。覆盖 A股、港股、美股三大市场。
  当用户询问以下内容时触发：K线/日线/周线/月线行情、股票列表、公司信息、
  PE/PB/换手率等每日指标、涨跌停、停复牌、复权因子、新股IPO、交易日历、
  港股通/北向资金、上证/深证指数、申万行业分类、
  MA/EMA/RSI/MACD/KDJ/布林带/ADX/ATR/CCI/VWAP 等27种技术指标、
  美股财务报表（利润表/资产负债表/现金流量表）、股息/拆股/盈利预估、
  内部人士交易、机构持仓、财报电话会议、ETF档案、市场涨跌排行、盈利日历、
  金融研报生成、个股深度分析、投资分析报告。
---

# Market Stock Skill

Version: v2.4.0

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

## 不要自己编造接口

**核心规则：只能调用下方 Quick Route 表和 references/ 中列出的端点。不确定时先查 references/，不要猜。**

---

## Quick Route

### 行情数据

| 用户意图 | Endpoint | 参数名 | 代码格式 |
|----------|----------|--------|----------|
| A股实时行情 | `GET /api/v2/cnstock/securities` | `codes` | 纯数字 `600519` |
| A股K线 | `GET /api/v2/cnstock/stocks` | `symbol` | `000001.SZ` |
| 股票列表 | `GET /api/v2/cnstock/symbols` | `listStatus` | — |
| 公司信息 | `GET /api/v2/cnstock/company` | `tsCode` | `000001.SZ` |
| 每日指标 (PE/PB) | `GET /api/v2/cnstock/daily-basic` | `tsCode` | `000001.SZ` |
| 涨跌停 | `GET /api/v2/cnstock/stk-limit` | `tsCode` | `000001.SZ` |
| 复权因子 | `GET /api/v2/cnstock/adj-factor` | `tsCode` | `000001.SZ` |
| 停复牌 | `GET /api/v2/cnstock/suspend` | `tsCode` | `000001.SZ` |
| 新股IPO | `GET /api/v2/cnstock/new-share` | `startDate/endDate` | — |
| 交易日历 | `GET /api/v2/cnstock/trade-cal` | `startDate/endDate` | — |
| 港股实时行情 | `GET /api/v2/hkstock/securities` | `codes` | 纯数字 `00700` |
| 港股K线 | `GET /api/v2/hkstock/stocks` | `symbol` | `00700.HK` |
| 港股通Top10 | `GET /api/v2/hkstock/ggt-top10` | `tsCode` | `600519.SH` |
| 港股通持仓 | `GET /api/v2/hkstock/hold` | `tsCode` | `600519.SH` |
| 美股实时行情 | `GET /api/v2/usstock/securities` | `codes` | `AAPL` |
| 美股K线 | `GET /api/v2/usstock/stocks` | `symbol` | `AAPL` |
| 美股市场状态 | `GET /api/v2/usstock/market-status` | — | — |
| 美股涨跌排行 | `GET /api/v2/usstock/top-movers` | — | — |
| 美股盈利日历 | `GET /api/v2/usstock/calendar/earnings` | `symbol`, `horizon` | `AAPL` |
| 美股IPO日历 | `GET /api/v2/usstock/calendar/ipo` | — | — |
| 美股市场概览 | `GET /api/v2/usstock/market-overview` | — | — |
| 美股利润表 | `GET /api/v2/usstock/finance/income` | `symbol` | `AAPL` |
| 美股资产负债表 | `GET /api/v2/usstock/finance/balancesheet` | `symbol` | `AAPL` |
| 美股现金流量表 | `GET /api/v2/usstock/finance/cashflow` | `symbol` | `AAPL` |
| 美股股息历史 | `GET /api/v2/usstock/finance/dividend` | `symbol` | `AAPL` |
| 美股盈利预估 | `GET /api/v2/usstock/finance/forecast` | `symbol` | `AAPL` |
| 美股拆股历史 | `GET /api/v2/usstock/finance/splits` | `symbol` | `AAPL` |
| 美股流通股 | `GET /api/v2/usstock/finance/shares` | `symbol` | `AAPL` |
| 美股内部人士交易 | `GET /api/v2/usstock/finance/insider` | `symbol` | `AAPL` |
| 美股机构持仓 | `GET /api/v2/usstock/finance/institutional` | `symbol` | `AAPL` |
| 美股财报电话会议 | `GET /api/v2/usstock/finance/transcript` | `symbol`, `quarter` | `AAPL` |
| 美股ETF档案 | `GET /api/v2/usstock/etf-profile` | `symbol` | `SPY` |
| 指数行情 | `GET /api/v2/cnstock/index/daily` | `tsCode` | `000001.SH` |
| 申万行业分类 | `GET /api/v2/cnstock/index/classify` | — | — |

### 技术指标

| 用户意图 | Endpoint | 备注 |
|----------|----------|------|
| 股票指标（推荐） | `GET /api/v2/indicators/{type}` | 多个指标并行调用，参数用 `market` |
| Crypto 批量指标 | `POST /api/v2/indicators` | 仅 crypto，参数用 `exchange` |
| 指标信息 | `GET /api/v2/indicators/info` | — |

---

## Critical Rules

### 1. 代码格式 — 最常见错误来源

| 接口类型 | 参数名 | A股 | 港股 | 美股 |
|----------|--------|-----|------|------|
| **securities**（实时报价） | `codes` | 纯数字 `600519` | 纯数字 `00700` | `AAPL` |
| **K线**（stocks） | `symbol` | `600519.SH` | `00700.HK` | `AAPL` |
| **其他所有接口** | `tsCode` | `600519.SH` | `00700.HK` | `AAPL` |

**速记：securities 用纯代码 + `codes`，K线用 `symbol`，其余用 `tsCode`。**

```bash
# ✅ securities → 纯代码，codes
curl "$BASE/api/v2/cnstock/securities?codes=600519,000001"
# ✅ K线 → 带后缀，symbol
curl "$BASE/api/v2/cnstock/stocks?symbol=600519.SH&limit=10"
# ✅ 公司信息 → 带后缀，tsCode
curl "$BASE/api/v2/cnstock/company?tsCode=600519.SH"
```

### 2. 日期格式

| 端点类型 | 格式 | 示例 |
|----------|------|------|
| 行情端点（stocks, daily, company...） | `YYYYMMDD` | `20240115` |
| 指标端点（indicators） | `YYYY-MM-DD` | `2024-01-15` |

### 3. 指标参数对照 — exchange vs market vs codes

三套接口使用**不同的交易所标识方式**，混用会报错（如 "unknown exchange"）：

| 接口 | 交易所参数 | 代码参数 | 示例 |
|------|-----------|---------|------|
| **指标** `GET /api/v2/indicators/{type}` | `market=cn\|hk\|us` | `symbol=600519.SH` | `?market=cn&symbol=600519.SH` |
| **实时行情** `GET /api/v2/cnstock/securities` | 无（通过端点路径区分） | `codes=600519` | `?codes=600519` |
| **K线/其他** `GET /api/v2/cnstock/stocks` 等 | 无（通过端点路径区分） | `symbol` 或 `tsCode` | `?symbol=600519.SH` |

**⚠️ 指标接口没有 `exchange` 参数。** 传 `exchange=SSE` / `exchange=SZSE` 等会返回 "unknown exchange" 错误。正确做法是用 `market` 参数：

```bash
# ✅ 正确：用 market
curl "$BASE/api/v2/indicators/rsi?market=cn&symbol=600519.SH&period=14&limit=100"

# ❌ 错误：指标接口没有 exchange 参数
curl "$BASE/api/v2/indicators/rsi?exchange=SSE&symbol=600519.SH&period=14&limit=100"
```

`market` **必填**: `cn`（A股）、`hk`（港股）、`us`（美股）。

### 4. 港股 limit 已知问题

`/api/v2/hkstock/stocks` 的 `limit` 可能不返回最新交易日。改用 `startDate` + `endDate`。

```bash
# ✅ 港股指标：只传 market=hk，不传 exchange
curl "$BASE/api/v2/indicators/rsi?market=hk&symbol=00700.HK&period=14&limit=100"

# ❌ 错误：股票不需要 exchange
curl "$BASE/api/v2/indicators/rsi?market=hk&symbol=00700.HK&exchange=HKEX&period=14&limit=100"
```

### 5. API Boundary — 只用文档中列出的端点

**NEVER guess or fabricate API endpoints.** Only use endpoints explicitly listed in the Quick Route table above. The following endpoints DO NOT EXIST — do not call them:

`/api/v2/cnstock/industry` · `/api/v2/cnstock/industry/daily` · `/api/v2/cnstock/sector` · `/api/v2/cnstock/financial` · `/api/v2/cnstock/profile` · `/api/v2/cnstock/info` · `/api/v2/cnstock/report` · `/api/v2/cnstock/summary`

If the data you need is not in Quick Route, tell the user and suggest `tavily` to search for it.

### 6. 技术指标：股票用 GET 并行，不要用 POST 批量

**`POST /api/v2/indicators` 批量接口只支持 crypto（参数是 `exchange` 不是 `market`），不支持股票。** 股票指标必须用 `GET /api/v2/indicators/{type}` 单指标接口，多个指标**并行调用**。

```bash
# ✅ 正确：股票用 GET 单指标，多个并行发出
curl "$BASE/api/v2/indicators/rsi?market=hk&symbol=00700.HK&period=14&limit=100" &
curl "$BASE/api/v2/indicators/macd?market=hk&symbol=00700.HK&limit=100" &
curl "$BASE/api/v2/indicators/boll?market=hk&symbol=00700.HK&period=20&nbdev=2.0&limit=100" &
wait

# ❌ 错误：股票用 POST 批量接口（会报 422，要求 exchange）
curl -X POST "$BASE/api/v2/indicators" -d '{"market":"hk","symbol":"00700.HK",...}'
```

### 7. 并行调用 — 不要串行等待

K线数据和指标数据**没有依赖关系，应该并行调用**。不要等 K 线返回后再调指标。

```
✅ 并行：klines + GET /indicators/{type} + daily-basic 同时发出
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

## Call Strategy — 性能关键

### 规则 1：并行优先

无依赖关系的 API 调用**必须并行**：

```bash
# 多股票K线并行
curl "$BASE/api/v2/cnstock/stocks?symbol=002594.SZ&limit=10" &
curl "$BASE/api/v2/cnstock/stocks?symbol=300750.SZ&limit=10" &
wait

# 多指数并行
curl "$BASE/api/v2/cnstock/index/daily?tsCode=000001.SH&limit=5" &
curl "$BASE/api/v2/cnstock/index/daily?tsCode=399001.SZ&limit=5" &
wait
```

并行场景：多只股票K线、多个指数、不同股票指标、行情+新闻、同股K线+指标。

### 规则 2：多指标用 GET 并行（股票）

**股票指标不支持 POST 批量接口**（POST 只支持 crypto）。多个指标用 GET 单接口并行调用：

```bash
# ✅ 股票：GET 并行，多个指标同时发出
curl "$BASE/api/v2/indicators/rsi?market=cn&symbol=000001.SZ&period=14&limit=100" &
curl "$BASE/api/v2/indicators/macd?market=cn&symbol=000001.SZ&limit=100" &
curl "$BASE/api/v2/indicators/boll?market=cn&symbol=000001.SZ&period=20&nbdev=2.0&limit=100" &
curl "$BASE/api/v2/indicators/kdj?market=cn&symbol=000001.SZ&limit=100" &
wait

# ❌ 错误：股票用 POST 批量会报错（要求 exchange 参数，股票没有）
curl -X POST "$BASE/api/v2/indicators" -d '{"market":"cn","symbol":"000001.SZ",...}'
```

### 规则 3：404 立即停止

收到 404 → 检查黑名单，不重试，不推测新端点。

---

## Report Generation Workflow

**原则：有数据有观点，不要废话。总字数不超过 800 字。**

### Step 1: Cluster — 聚类为 2-3 个核心主题（不要超过 3 个）

### Step 2: Write — 每个主题：数据表格/图表 + 1-2 段分析（带观点）

### Step 3: Assemble — 组装格式：
- 开头一句话结论（带 🟢🔴🟡 标签）
- 2-3 个主题段落（每段含表格或 `json-chart`）
- 风险提示（1-2 句）
- **没有 Executive Summary，开头结论就是 Summary**

---

## Error Troubleshooting

详细排错表见 `references/ERRORS.md`。常见错误速查：

| 错误 | 原因 | 修复 |
|------|------|------|
| 404 | 调用了黑名单端点或代码格式错 | 查上方黑名单；A股 `600519.SH`，港股 `00700.HK` |
| 空数据 | `symbol` vs `tsCode` 用反 | K线用 `symbol`，其他用 `tsCode` |
| 400 (行情) | 日期格式错 | 用 `YYYYMMDD` |
| 400 (指标) | 日期格式错或缺 `market` | 用 `YYYY-MM-DD`，`market` 必填 |
| securities 返回空 | codes 带了后缀 | A股 `600519`，港股 `00700`，不要带交易所后缀 |
| 港股无最新数据 | limit bug | 改用 `startDate` + `endDate` |
| "unknown exchange" | 指标接口传了 `exchange` 参数 | 指标接口用 `market=cn\|hk\|us`，没有 `exchange` 参数 |
| 指标 422 错误 | 股票用了 POST 批量接口 | POST 只支持 crypto；股票用 `GET /api/v2/indicators/{type}` 并行调用 |
| BOLL 结果错误 | V1 习惯 `nbdev_up`/`nbdev_dn` | V2 用单个 `nbdev`（默认 2.0） |

**Error Codes:** `400` 参数错误 · `401` API key 无效 · `404` 标的不存在 · `500` 内部错误

---

## References

- `references/CNSTOCK-API.md` — A股行情 + 指数
- `references/HKSTOCK-API.md` — 港股行情 + 港股通
- `references/USSTOCK-API.md` — 美股行情 + 市场信息 + 财务数据
- `references/INDICATORS-API.md` — 27种技术指标详参

> 参数不确定时：`grep -r "关键词" references/`
