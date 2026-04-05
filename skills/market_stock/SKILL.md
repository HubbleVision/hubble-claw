---
name: market_stock
description: 股票市场数据、技术分析与研报生成 — A股/港股/美股 K线、公司信息、指数、交易日历、27种技术指标、结构化金融研报
---

# Stock Market Skill

Version: v2.0.0

> Load this skill when you need stock market data, technical indicators, or structured financial reports for A股 (Chinese stocks), 港股 (HK stocks), or 美股 (US stocks).

## When to use

Use this skill when the user asks about:

**行情数据：**
- **A股** — K线、公司信息、每日指标、涨跌停、停复牌、复权因子
- **港股** — K线、港股通数据、持股明细
- **美股** — K线、标的列表
- **指数** — 上证/深证指数、指数成分权重、申万行业分类
- **交易日历** — A股/港股/美股交易日历
- **新股** — IPO 新股上市信息
- **股票列表** — 查询可用的股票代码

**技术分析：**
- 均线 (MA/EMA/SMA) / RSI / MACD / 布林带 / KDJ
- ADX / ATR / CCI / VWAP / OBV / NATR / MFI / WILLR / STDDEV
- Aroon / TRIX / MOM / ROC / CMO / SAR / Stoch / ULTOSC / ADOSC / AD
- HT Trendline / PPO / 批量指标计算

**研报生成：**
- 金融研报 / 投资分析报告
- 信号聚类 / 主题归纳
- 深度分析 / 股票预测
- 研报组装 / 报告编辑

## Requirements

- `MARKET_API_BASE_URL` — API server URL (e.g., `http://localhost:8080`)
- `MARKET_API_KEY` — API key for authentication

## Tools

Use the `bash` tool to call the API with `curl`.

### Curl base setup

```bash
BASE="${MARKET_API_BASE_URL%/}"
AUTH=(-H "X-API-Key: $MARKET_API_KEY" -H "Content-Type: application/json")
```

---

## Fast Path (Quick Reference)

### 行情数据

| User Request | API Endpoint |
|--------------|--------------|
| "A股K线" / "A股日线" | `GET /api/v2/cnstock/klines` |
| "股票列表" / "有哪些股票" | `GET /api/v2/cnstock/symbols` |
| "公司信息" / "上市公司" | `GET /api/v2/cnstock/company` |
| "每日指标" / "PE/PB" | `GET /api/v2/cnstock/daily-basic` |
| "涨跌停" / "涨停板" | `GET /api/v2/cnstock/stk-limit` |
| "港股K线" / "港股日线" | `GET /api/v2/hkstock/daily` |
| "港股通" / "沪深港通" | `GET /api/v2/hkstock/ggt-top10` |
| "美股K线" / "美股日线" | `GET /api/v2/usstock/daily` |
| "指数" / "上证指数" | `GET /api/v2/cnstock/index/daily` |
| "交易日历" | `GET /api/v2/cnstock/trade-cal` |

### 技术指标

| User Request | API Endpoint |
|--------------|--------------|
| "支持哪些指标" / "指标信息" | `GET /api/v2/indicators/info` |
| "均线" / "SMA" / "EMA" | `GET /api/v2/indicators/sma` or `ema` |
| "RSI" / "MACD" / "布林带" | `GET /api/v2/indicators/{rsi\|macd\|boll}` |
| "KDJ" / "ADX" / "ATR" | `GET /api/v2/indicators/{kdj\|adx\|atr}` |
| "批量指标" | `POST /api/v2/indicators` |

---

## Critical Rules

### Stock Code Formats

- A股: `{code}.{exchange}` (e.g., `000001.SZ`, `600519.SH`)
- 港股: `{code}.HK` (e.g., `00700.HK`)
- 美股: Ticker symbol directly (e.g., `AAPL`, `MSFT`, `GOOGL`)
- A股 index codes: `000001.SH` (上证指数), `399001.SZ` (深证成指), `399006.SZ` (创业板指)

### Date Formats

| Endpoint Type | Date Format | Example |
|---------------|-------------|---------|
| **股票行情端点** (klines, daily, company...) | **YYYYMMDD** | `20240115` |
| **技术指标端点** (indicators) | **YYYY-MM-DD** | `2024-01-15` |

### Parameter Name Rules (行情数据)

Stock endpoints use **different parameter names** depending on the endpoint type. **This is the most common source of errors.**

| Endpoint Type | Parameter Name | Example |
|---------------|---------------|---------|
| **K-line data** (klines, daily) | `symbol` | `symbol=000001.SZ` |
| **Stock info queries** (company, daily-basic, adj-factor, name-change, stk-limit, suspend) | **`tsCode`** | `tsCode=000001.SZ` |
| **Index data** (index/daily, index/weekly, index/monthly, index/daily-basic, index/weight) | **`tsCode`** | `tsCode=000001.SH` |
| **HK Connect** (ggt-top10, ggt-daily, hold) | **`tsCode`** | `tsCode=600519.SH` |
| **Trade calendar** | `startDate` / `endDate` | No stock code needed |

Quick check: When in doubt, use `tsCode` for A股 non-K-line endpoints.

```bash
# ✅ CORRECT — K-line uses `symbol`
curl "$BASE/api/v2/cnstock/klines?symbol=600519.SH&limit=10"

# ❌ WRONG — company uses `tsCode`, NOT `symbol`
curl "$BASE/api/v2/cnstock/company?symbol=600519.SH"

# ✅ CORRECT
curl "$BASE/api/v2/cnstock/company?tsCode=600519.SH"
```

### 技术指标必需参数

- `market` 参数**必填**: `cn` (A股), `hk` (港股), `us` (美股)
- 日期格式用 **YYYY-MM-DD**，不是 YYYYMMDD 或 RFC3339

---

## Generate Structured Reports (Default Workflow)

**YOU (the Agent)** are the Report Generator. After gathering data via the APIs above, **always** follow this 3-step workflow to produce the final report.

**Workflow:**
1. Gather data using the market data APIs (K-lines, indicators, etc.)
2. **Cluster Signals** — group scattered signals into themes
3. **Write Sections** — for each theme, write deep analysis
4. **Final Assembly** — compile into a complete report

---

### Step 1: Cluster Signals (Planner)

```markdown
You are a senior financial report editor. Your task is to cluster the following scattered financial signals into 3-5 core logical themes for a structured report.

### Input Signals
{signals_text}

### Requirements
1. **Theme Aggregation**: Group highly correlated signals (e.g., all related to "supply chain restructuring" or "policy tightening").
2. **Narrative Logic**: Generate only theme titles and list of signal IDs.
3. **Quantity Control**: 3-5 major themes.

### Output Format (JSON)
{
    "clusters": [
        {
            "theme_title": "Theme Name (e.g. Supply Chain Shock)",
            "signal_ids": [1, 3, 5],
            "rationale": "These signals all point to..."
        },
        ...
    ]
}
```

### Step 2: Write Section (Writer)

```markdown
You are a senior financial analyst. Write a deep analysis section for the core theme **"{theme_title}"**.

### Input Signals (Cluster)
{signal_cluster_text}

### Requirements
1. **Narrative**: Weave signals into a coherent story. Start with Macro/Industry background, then transmission mechanism, finally stock impact.
2. **Quantification**: Cite ISQ scores (Confidence, Intensity) to support views.
3. **Citations**: Use `[@CITE_KEY]` format. Keys are provided in input.
4. **Predictions**: detailed predictions for affected tickers (T+3/T+5 direction).

### Formatting
- Main Title: `## {theme_title}`
- Subtitles: `###`
- **Charts**: Insert at least 1-2 `json-chart` blocks.

**Chart Example:**
```json-chart
{"type": "forecast", "ticker": "002371.SZ", "title": "Forecast", "pred_len": 5}
```
```

### Step 3: Final Assembly (Editor)

```markdown
You are a professional editor. Assemble the drafted sections into a final report.

### Draft Sections
{draft_sections}

### Requirements
1. **Structure**: Ensure H2/H3 hierarchy is correct.
2. **References**: Generate `## References` section from source list.
3. **Risk**: Generate `## Risk Factors`.
4. **Summary**: Generate `## Executive Summary` with a "Quick Scan" table.

Output strictly Markdown.
```

---

## References (详细文档)

详细的端点参数、请求示例和响应格式，请参考 `references/` 目录：

- **`references/CNSTOCK-API.md`** — A股行情 + 指数数据（symbols, klines, company, daily-basic, adj-factor, name-change, new-share, stk-limit, suspend, trade-cal, index）
- **`references/HKSTOCK-API.md`** — 港股行情（symbols, daily, trade-cal, ggt-top10, ggt-daily, hold）
- **`references/USSTOCK-API.md`** — 美股行情（symbols, daily, trade-cal）
- **`references/INDICATORS-API.md`** — 27种技术指标（单个指标 GET + 批量 POST，含参数映射表和指标解读）

---

## Quick Examples

### 平安银行最近 100 天日线
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/klines?symbol=000001.SZ&limit=100"
```

### 上证指数近期走势
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/index/daily?tsCode=000001.SH&limit=100"
```

### 腾讯控股近期K线
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/hkstock/daily?symbol=00700.HK&limit=100"
```

### 苹果公司近期K线
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/daily?symbol=AAPL&limit=100"
```

### 沪深股通持股详情
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/hkstock/hold?tsCode=600519.SH&limit=50"
```

### 涨跌停价格
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/stk-limit?tradeDate=20240115"
```

### 平安银行 RSI + MACD 批量计算
```bash
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

## Common Errors & Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| API returns wrong stock data or empty data | Used `symbol` instead of `tsCode` on non-K-line endpoints | Check the Parameter Name Rules — use `tsCode` for company, daily-basic, adj-factor, etc. |
| 400 Bad Request on stock endpoints | Wrong date format | Stock endpoints use **YYYYMMDD** (e.g., `20240115`), NOT `2024-01-15` |
| 400 Bad Request on indicator endpoints | Wrong date format | Indicator endpoints use **YYYY-MM-DD** (e.g., `2024-01-15`), NOT `20240115` |
| 404 Stock not found | Wrong stock code format | A股: `600519.SH` not `600519`; 港股: `00700.HK`; 美股: `AAPL` |
| Empty data returned | Query date range too narrow or holiday | Check trade calendar first; expand date range |
| 400 missing market (indicators) | Forgot `market` parameter | `market` is **required** for all indicators: `cn`, `hk`, `us` |
| Empty indicator values (all null) | Insufficient warmup data | Increase `limit` or expand time range |
| Wrong BOLL result | V1 habits: used `nbdev_up`/`nbdev_dn` | V2 uses a single `nbdev` parameter (default 2.0) |
| Batch POST returns 400 | Wrong body structure | Batch endpoint uses POST with JSON body, check `indicators` array format |

## Error Codes

- `400`: Invalid parameter (wrong param name, stock code format, date format)
- `401`: API key missing or invalid
- `404`: Symbol not found
- `500`: Internal error

---

## Notes

- All single indicator endpoints use **GET method** with query parameters
- Batch indicator endpoint uses **POST method**: `POST /api/v2/indicators`
- Indicator values are returned as arrays aligned with K-line data
- Leading values may be `null` for indicators that require warmup data
- For ADX, the service automatically fetches extra warmup data (period * 2)
