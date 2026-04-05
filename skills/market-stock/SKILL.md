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

Version: v2.3.0

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

## Endpoint Blacklist — 禁止调用

| ❌ 不存在的端点 | ✅ 替代方案 |
|-----------------|------------|
| `/api/v2/cnstock/klines` | `/api/v2/cnstock/stocks`（参数名 `symbol`） |
| `/api/v2/cnstock/industry/daily` | 不支持行业日行情 |
| `/api/v2/cnstock/sector` | 不支持板块查询 |
| `/api/v2/cnstock/industry` | 不支持行业分类 |
| `/api/v2/cnstock/summary` | `daily-basic` 获取市场概览 |
| `/api/v2/cnstock/financial` | 不支持财报数据 |
| `/api/v2/cnstock/report` | 内置 Report Workflow 生成研报 |
| `/api/v2/cnstock/profile` | `/api/v2/cnstock/company` |
| `/api/v2/cnstock/info` | `/api/v2/cnstock/company` |
| `/api/v2/hkstock/daily` | `/api/v2/hkstock/stocks`（参数名 `symbol`） |

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
| 指数行情 | `GET /api/v2/cnstock/index/daily` | `tsCode` | `000001.SH` |
| 申万行业分类 | `GET /api/v2/cnstock/index/classify` | — | — |

### 技术指标

| 用户意图 | Endpoint |
|----------|----------|
| 批量指标（推荐） | `POST /api/v2/indicators` |
| 指标信息 | `GET /api/v2/indicators/info` |

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

### 3. 指标必需参数

`market` **必填**: `cn`(A股), `hk`(港股), `us`(美股)。多指标必须用 `POST /api/v2/indicators` 批量接口。

### 4. 港股 limit 已知问题

`/api/v2/hkstock/stocks` 的 `limit` 可能不返回最新交易日。改用 `startDate` + `endDate`。

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

### 规则 2：多指标用批量接口

```bash
# ✅ 一次请求：RSI + MACD + BOLL + KDJ
curl -sS "${AUTH[@]}" -X POST "$BASE/api/v2/indicators" -d '{
  "market": "cn", "symbol": "000001.SZ", "interval": "1d", "limit": 100,
  "indicators": [
    {"type": "rsi", "params": [14]},
    {"type": "macd", "params": [12, 26, 9]},
    {"type": "boll", "params": [20, 2.0]},
    {"type": "kdj", "params": [9, 3, 3]}
  ]
}'
```

### 规则 3：404 立即停止

收到 404 → 检查黑名单，不重试，不推测新端点。

---

## Report Generation Workflow

### Step 1: Cluster Signals — 将散乱信号聚类为 3-5 个核心主题

```json
{"clusters": [{"theme_title": "主题", "signal_ids": [1, 3], "rationale": "理由"}]}
```

### Step 2: Write Sections — 对每个主题写深度分析（宏观/行业 → 传导 → 个股影响）

### Step 3: Final Assembly — 组装报告（H2/H3 + References + Risk Factors + Executive Summary）

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
| BOLL 结果错误 | V1 习惯 `nbdev_up`/`nbdev_dn` | V2 用单个 `nbdev`（默认 2.0） |

**Error Codes:** `400` 参数错误 · `401` API key 无效 · `404` 标的不存在 · `500` 内部错误

---

## References

- `references/CNSTOCK-API.md` — A股行情 + 指数
- `references/HKSTOCK-API.md` — 港股行情 + 港股通
- `references/USSTOCK-API.md` — 美股行情
- `references/INDICATORS-API.md` — 27种技术指标详参

> 参数不确定时：`grep -r "关键词" references/`
