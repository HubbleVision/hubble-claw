---
name: market_stock
description: 股票市场数据与技术分析 — A股/港股/美股 K线、公司信息、指数、交易日历、27种技术指标
---

# Market Stock Skill

Version: v2.0.0

> Load this skill when you need stock market data or technical indicators for A股 (Chinese stocks), 港股 (HK stocks), or 美股 (US stocks).

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
- 均线 (MA/EMA/SMA)
- RSI / MACD / 布林带 / KDJ
- ADX / ATR / CCI / VWAP / OBV
- NATR / MFI / WILLR / STDDEV
- Aroon / TRIX / MOM / ROC / CMO
- SAR / Stoch / ULTOSC / ADOSC / AD
- HT Trendline / PPO
- 批量指标计算

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
| "NATR" / "MFI" / "WILLR" | `GET /api/v2/indicators/{natr\|mfi\|willr}` |
| "STDDEV" / "Aroon" / "TRIX" | `GET /api/v2/indicators/{stddev\|aroon\|trix}` |
| "批量指标" | `POST /api/v2/indicators` |

---

## ⚠️ Critical Rules

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

# Part 1: A股 (Chinese Stocks)

## Action: Get A股 Stock List

- `GET /api/v2/cnstock/symbols`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `listStatus` | string | No | Listing status: `L` (listed, default), `D` (delisted), `P` (suspended) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/symbols"
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/symbols?listStatus=L"
```

**Response:**
```json
{
  "market": "cn",
  "symbols": [
    {"symbol": "000001.SZ", "name": "平安银行", "industry": "银行", "area": "深圳", "listDate": "19910403"}
  ],
  "total": 5000
}
```

---

## Action: Get A股 K-line Data

- `GET /api/v2/cnstock/klines`

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `symbol` | string | **Yes** | Stock code | `000001.SZ` |
| `interval` | string | No | Period: `daily`, `weekly`, `monthly` (default: `daily`) | `daily` |
| `startDate` | string | No | Start date YYYYMMDD | `20240101` |
| `endDate` | string | No | End date YYYYMMDD | `20240131` |
| `limit` | int | No | Max 1-5000 (default: 100) | `500` |

**Request:**
```bash
# Get recent 500 daily candles
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/cnstock/klines?symbol=000001.SZ&interval=daily&limit=500"

# Get weekly data for Jan 2024
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/cnstock/klines?symbol=000001.SZ&interval=weekly&startDate=20240101&endDate=20240131"
```

**Response:**
```json
{
  "symbol": "000001.SZ",
  "interval": "daily",
  "data": [
    {
      "time": 1704067200000,
      "open": 10.50,
      "high": 10.80,
      "low": 10.40,
      "close": 10.70,
      "volume": 1234567,
      "adjFactor": 1.0
    }
  ],
  "total": 500
}
```

---

## Action: Get Company Information

- `GET /api/v2/cnstock/company`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tsCode` | string | No | Stock code (e.g., `000001.SZ`) |
| `exchange` | string | No | Exchange: `SSE`, `SZSE` |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/company?tsCode=000001.SZ"
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/company?exchange=SSE&limit=100"
```

---

## Action: Get Daily Basic Indicators

- `GET /api/v2/cnstock/daily-basic`

Daily indicators including PE, PB, turnover rate, etc.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tsCode` | string | No | Stock code |
| `tradeDate` | string | No | Trade date YYYYMMDD |
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/daily-basic?tsCode=000001.SZ&limit=100"
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/daily-basic?tradeDate=20240115"
```

---

## Action: Get Adjustment Factors

- `GET /api/v2/cnstock/adj-factor`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tsCode` | string | No | Stock code |
| `tradeDate` | string | No | Trade date YYYYMMDD |
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/adj-factor?tsCode=000001.SZ&limit=100"
```

---

## Action: Get Name Change History

- `GET /api/v2/cnstock/name-change`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tsCode` | string | No | Stock code |
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/name-change?tsCode=000001.SZ"
```

---

## Action: Get IPO New Shares

- `GET /api/v2/cnstock/new-share`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/new-share?startDate=20240101&endDate=20240630"
```

---

## Action: Get Daily Price Limits

- `GET /api/v2/cnstock/stk-limit`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tsCode` | string | No | Stock code |
| `tradeDate` | string | No | Trade date YYYYMMDD |
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/stk-limit?tradeDate=20240115"
```

---

## Action: Get Suspend/Resume Info

- `GET /api/v2/cnstock/suspend`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tsCode` | string | No | Stock code |
| `tradeDate` | string | No | Trade date YYYYMMDD |
| `suspendDate` | string | No | Suspension date YYYYMMDD |
| `resumeDate` | string | No | Resume date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/suspend?tsCode=000001.SZ"
```

---

## Action: Get A股 Trade Calendar

- `GET /api/v2/cnstock/trade-cal`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `exchange` | string | No | `SSE` or `SZSE` |
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-10000 (default: 1000) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/trade-cal?exchange=SSE&startDate=20240101&endDate=20240331"
```

---

# Part 2: A股 Index (指数数据)

## Action: Get Index Basic Info

- `GET /api/v2/cnstock/index/basic`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `market` | string | No | Market: `SSE` (Shanghai), `SZSE` (Shenzhen) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/index/basic?market=SSE"
```

---

## Action: Get Index Daily Data

- `GET /api/v2/cnstock/index/daily`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tsCode` | string | **Yes** | Index code (e.g., `000001.SH`) |
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/index/daily?tsCode=000001.SH&limit=100"
```

---

## Action: Get Index Weekly Data

- `GET /api/v2/cnstock/index/weekly`

**Query Parameters:** Same as index daily.

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/index/weekly?tsCode=000001.SH&limit=100"
```

---

## Action: Get Index Monthly Data

- `GET /api/v2/cnstock/index/monthly`

**Query Parameters:** Same as index daily.

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/index/monthly?tsCode=000001.SH&limit=100"
```

---

## Action: Get Index Daily Basic

- `GET /api/v2/cnstock/index/daily-basic`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tsCode` | string | No | Index code |
| `tradeDate` | string | No | Trade date YYYYMMDD |
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/index/daily-basic?tsCode=000001.SH&limit=100"
```

---

## Action: Get Index Component Weights

- `GET /api/v2/cnstock/index/weight`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `indexCode` | string | No | Index code (e.g., `000001.SH`) |
| `tradeDate` | string | No | Trade date YYYYMMDD |
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/index/weight?indexCode=000001.SH&limit=100"
```

---

## Action: Get Industry Classification

- `GET /api/v2/cnstock/index/classify`

Shenwan (申万) industry classification.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `src` | string | No | Source type |
| `version` | string | No | Version |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/index/classify"
```

---

# Part 3: 港股 (HK Stocks)

## Action: Get HK Stock List

- `GET /api/v2/hkstock/symbols`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `listStatus` | string | No | `L` (listed, default), `D` (delisted) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/hkstock/symbols"
```

---

## Action: Get HK Stock Daily Data

- `GET /api/v2/hkstock/daily`

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `symbol` | string | **Yes** | HK stock code | `00700.HK` |
| `startDate` | string | No | Start date YYYYMMDD | `20240101` |
| `endDate` | string | No | End date YYYYMMDD | `20240131` |
| `limit` | int | No | Max 1-5000 (default: 100) | `500` |

**Request:**
```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/hkstock/daily?symbol=00700.HK&startDate=20240101&endDate=20240131&limit=500"
```

---

## Action: Get HK Trade Calendar

- `GET /api/v2/hkstock/trade-cal`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-10000 (default: 1000) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/hkstock/trade-cal?startDate=20240101&endDate=20240630"
```

---

## Action: Get HK Connect Top 10

- `GET /api/v2/hkstock/ggt-top10`

Stock Connect top 10 active stocks.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tradeDate` | string | No | Trade date YYYYMMDD |
| `tsCode` | string | No | Stock code |
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/hkstock/ggt-top10?tradeDate=20240115"
```

---

## Action: Get HK Connect Daily Trading

- `GET /api/v2/hkstock/ggt-daily`

Stock Connect daily trading summary.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tradeDate` | string | No | Trade date YYYYMMDD |
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/hkstock/ggt-daily?startDate=20240101&endDate=20240131"
```

---

## Action: Get HK Connect Holdings

- `GET /api/v2/hkstock/hold`

Stock Connect holdings details.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tsCode` | string | No | Stock code |
| `tradeDate` | string | No | Trade date YYYYMMDD |
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-5000 (default: 100) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/hkstock/hold?tsCode=600519.SH"
```

---

# Part 4: 美股 (US Stocks)

## Action: Get US Stock List

- `GET /api/v2/usstock/symbols`

No parameters required.

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/symbols"
```

---

## Action: Get US Stock Daily Data

- `GET /api/v2/usstock/daily`

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `symbol` | string | **Yes** | US stock code | `AAPL` |
| `startDate` | string | No | Start date YYYYMMDD | `20240101` |
| `endDate` | string | No | End date YYYYMMDD | `20240131` |
| `limit` | int | No | Max 1-5000 (default: 100) | `500` |

**Request:**
```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/usstock/daily?symbol=AAPL&startDate=20240101&endDate=20240131&limit=500"
```

---

## Action: Get US Trade Calendar

- `GET /api/v2/usstock/trade-cal`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `startDate` | string | No | Start date YYYYMMDD |
| `endDate` | string | No | End date YYYYMMDD |
| `limit` | int | No | Max 1-10000 (default: 1000) |

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/trade-cal?startDate=20240101&endDate=20240630"
```

---

# Part 5: Technical Indicators (技术指标)

## Supported Indicators (27 total)

| # | Indicator | Type | Endpoint | Key Parameters |
|---|-----------|------|----------|----------------|
| 1 | SMA | Trend | `/api/v2/indicators/sma` | `period` |
| 2 | EMA | Trend | `/api/v2/indicators/ema` | `period` |
| 3 | RSI | Oscillator | `/api/v2/indicators/rsi` | `period` |
| 4 | MACD | Trend | `/api/v2/indicators/macd` | `fast_period`, `slow_period`, `signal_period` |
| 5 | BOLL | Volatility | `/api/v2/indicators/boll` | `period`, `nbdev` |
| 6 | KDJ | Oscillator | `/api/v2/indicators/kdj` | `fastk_period`, `slowk_period`, `slowd_period` |
| 7 | ADX | Trend | `/api/v2/indicators/adx` | `period` |
| 8 | ATR | Volatility | `/api/v2/indicators/atr` | `period` |
| 9 | CCI | Oscillator | `/api/v2/indicators/cci` | `period` |
| 10 | VWAP | Volume | `/api/v2/indicators/vwap` | `period` |
| 11 | OBV | Volume | `/api/v2/indicators/obv` | — |
| 12 | NATR | Volatility | `/api/v2/indicators/natr` | `period` |
| 13 | MFI | Volume | `/api/v2/indicators/mfi` | `period` |
| 14 | WILLR | Oscillator | `/api/v2/indicators/willr` | `period` |
| 15 | STDDEV | Volatility | `/api/v2/indicators/stddev` | `period` |
| 16 | Aroon | Trend | `/api/v2/indicators/aroon` | `period` |
| 17 | TRIX | Trend | `/api/v2/indicators/trix` | `period` |
| 18 | MOM | Momentum | `/api/v2/indicators/mom` | `period` |
| 19 | ROC | Momentum | `/api/v2/indicators/roc` | `period` |
| 20 | CMO | Momentum | `/api/v2/indicators/cmo` | `period` |
| 21 | AD | Volume | `/api/v2/indicators/ad` | — |
| 22 | HT Trendline | Trend | `/api/v2/indicators/ht_trendline` | — |
| 23 | PPO | Trend | `/api/v2/indicators/ppo` | `fast_period`, `slow_period` |
| 24 | SAR | Trend | `/api/v2/indicators/sar` | `acceleration`, `maximum` |
| 25 | Stoch | Oscillator | `/api/v2/indicators/stoch` | `k_period`, `d_period`, `smooth_period` |
| 26 | ULTOSC | Oscillator | `/api/v2/indicators/ultosc` | `period1`, `period2`, `period3` |
| 27 | ADOSC | Volume | `/api/v2/indicators/adosc` | `fast_period`, `slow_period` |

## Common Parameters (all indicators)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `market` | string | **Yes** | — | Market: `cn` (A股), `hk` (港股), `us` (美股) |
| `symbol` | string | **Yes** | — | Symbol code |
| `interval` | string | No | `1d` | K-line period: `1m`, `5m`, `15m`, `1h`, `4h`, `1d`, `1w` |
| `limit` | int | No | `100` | Max number of records |
| `start` | string | No | — | Start date **YYYY-MM-DD** |
| `end` | string | No | — | End date **YYYY-MM-DD** |

---

## Action: Get Indicators Info

- `GET /api/v2/indicators/info`

```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/indicators/info"
```

---

## Action: Batch Calculate Indicators

- `POST /api/v2/indicators`

Calculate multiple technical indicators in a single request.

**Request:**
```bash
curl -sS "${AUTH[@]}" -X POST "$BASE/api/v2/indicators" -d '{
  "market": "cn",
  "symbol": "000001.SZ",
  "interval": "1d",
  "limit": 500,
  "indicators": [
    {"type": "sma", "params": [20]},
    {"type": "ema", "params": [50]},
    {"type": "macd", "params": [12, 26, 9]},
    {"type": "rsi", "params": [14]},
    {"type": "boll", "params": [20, 2.0]}
  ]
}'
```

**Parameter Mapping (by index):**

| Indicator | params[0] | params[1] | params[2] | params[3] | Default |
|-----------|-----------|-----------|-----------|-----------|---------|
| sma | period | - | - | - | 20 |
| ema | period | - | - | - | 20 |
| rsi | period | - | - | - | 14 |
| macd | fast | slow | signal | - | 12, 26, 9 |
| boll | period | nbdev | - | - | 20, 2.0 |
| kdj | fastk | slowk | slowd | - | 9, 3, 3 |
| adx | period | - | - | - | 14 |
| atr | period | - | - | - | 14 |
| cci | period | - | - | - | 14 |
| vwap | period | - | - | - | 20 |
| obv | none | - | - | - | - |
| natr | period | - | - | - | 14 |
| mfi | period | - | - | - | 14 |
| willr | period | - | - | - | 14 |
| stddev | period | - | - | - | 20 |
| aroon | period | - | - | - | 14 |
| trix | period | - | - | - | 9 |
| mom | period | - | - | - | 10 |
| roc | period | - | - | - | 12 |
| cmo | period | - | - | - | 14 |
| ppo | fast | slow | - | - | 12, 26 |
| sar | acceleration | maximum | - | - | 0.02, 0.2 |
| stoch | k | d | smooth | - | 14, 3, 3 |
| ultosc | period1 | period2 | period3 | - | 7, 14, 28 |
| adosc | fast | slow | - | - | 3, 10 |

---

## Single-Period Indicators

All use the same pattern: `GET /api/v2/indicators/{type}?market=&symbol=&period=&...`

### SMA — Simple Moving Average

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/sma?market=cn&symbol=000001.SZ&interval=1d&period=20&limit=100"
```

### EMA — Exponential Moving Average

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/ema?market=cn&symbol=000001.SZ&interval=1d&period=20&limit=100"
```

### RSI — Relative Strength Index

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/rsi?market=cn&symbol=000001.SZ&interval=1d&period=14&limit=100"
```

**RSI Interpretation:**
- Above 70: Overbought
- Below 30: Oversold
- 30-70: Normal range

### ATR — Average True Range

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/atr?market=cn&symbol=000001.SZ&interval=1d&period=14&limit=100"
```

### NATR — Normalized ATR

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/natr?market=cn&symbol=000001.SZ&interval=1d&period=14&limit=100"
```

### CCI — Commodity Channel Index

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/cci?market=cn&symbol=000001.SZ&interval=1d&period=14&limit=100"
```

**CCI Interpretation:**
- Above 100: Overbought
- Below -100: Oversold
- -100 to 100: Normal range

### VWAP — Volume Weighted Average Price

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/vwap?market=cn&symbol=000001.SZ&interval=1d&period=20&limit=100"
```

### MFI — Money Flow Index

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/mfi?market=cn&symbol=000001.SZ&interval=1d&period=14&limit=100"
```

### WILLR — Williams %R

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/willr?market=cn&symbol=000001.SZ&interval=1d&period=14&limit=100"
```

### STDDEV — Standard Deviation

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/stddev?market=cn&symbol=000001.SZ&interval=1d&period=20&limit=100"
```

### Aroon — Aroon Indicator

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/aroon?market=cn&symbol=000001.SZ&interval=1d&period=14&limit=100"
```

### TRIX

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/trix?market=cn&symbol=000001.SZ&interval=1d&period=9&limit=100"
```

### MOM — Momentum

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/mom?market=cn&symbol=000001.SZ&interval=1d&period=10&limit=100"
```

### ROC — Rate of Change

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/roc?market=cn&symbol=000001.SZ&interval=1d&period=12&limit=100"
```

### CMO — Chande Momentum Oscillator

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/cmo?market=cn&symbol=000001.SZ&interval=1d&period=14&limit=100"
```

---

## Multi-Value Indicators

### MACD — Moving Average Convergence Divergence

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/macd?market=cn&symbol=000001.SZ&interval=1d&fast_period=12&slow_period=26&signal_period=9&limit=100"
```

**MACD Components:**
- `dif`: MACD line (fast EMA - slow EMA)
- `dea`: Signal line (EMA of MACD)
- `macd`: MACD histogram (MACD - Signal)

### BOLL — Bollinger Bands

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/boll?market=cn&symbol=000001.SZ&interval=1d&period=20&nbdev=2.0&limit=100"
```

**Bollinger Bands Components:**
- `upper`: Upper band (middle + nbdev * std)
- `middle`: Middle band (SMA)
- `lower`: Lower band (middle - nbdev * std)

### KDJ — Stochastic Oscillator

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/kdj?market=cn&symbol=000001.SZ&interval=1d&fastk_period=9&slowk_period=3&slowd_period=3&limit=100"
```

**KDJ Interpretation:**
- K > D > J: Bullish
- K < D < J: Bearish
- K > 80: Overbought
- K < 20: Oversold

### ADX — Average Directional Index

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/adx?market=cn&symbol=000001.SZ&interval=1d&period=14&limit=100"
```

**ADX Interpretation:**
- Above 25: Strong trend
- Below 20: Weak trend / ranging
- ADX rising: Trend strengthening
- PDI > MDI: Bullish trend
- MDI > PDI: Bearish trend

### PPO — Percentage Price Oscillator

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/ppo?market=cn&symbol=000001.SZ&interval=1d&fast_period=12&slow_period=26&limit=100"
```

### SAR — Parabolic SAR

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/sar?market=cn&symbol=000001.SZ&interval=1d&acceleration=0.02&maximum=0.2&limit=100"
```

### Stoch — Stochastic

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/stoch?market=cn&symbol=000001.SZ&interval=1d&k_period=14&d_period=3&smooth_period=3&limit=100"
```

### ULTOSC — Ultimate Oscillator

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/ultosc?market=cn&symbol=000001.SZ&interval=1d&period1=7&period2=14&period3=28&limit=100"
```

### ADOSC — Accumulation/Distribution Oscillator

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/adosc?market=cn&symbol=000001.SZ&interval=1d&fast_period=3&slow_period=10&limit=100"
```

---

## No-Parameter Indicators

### OBV — On Balance Volume

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/obv?market=cn&symbol=000001.SZ&interval=1d&limit=100"
```

**OBV Interpretation:**
- Rising OBV + Rising price: Bullish (confirmation)
- Rising OBV + Falling price: Bearish divergence
- Falling OBV + Falling price: Bearish (confirmation)
- Falling OBV + Rising price: Bullish divergence

### AD — Accumulation/Distribution

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/ad?market=cn&symbol=000001.SZ&interval=1d&limit=100"
```

### HT Trendline — Hilbert Transform Trendline

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/ht_trendline?market=cn&symbol=000001.SZ&interval=1d&limit=100"
```

---

## Multi-Market Indicator Examples

### A股 RSI

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/rsi?market=cn&symbol=000001.SZ&interval=daily&period=14&limit=100"
```

### 港股 MACD

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/macd?market=hk&symbol=00700.HK&interval=daily&limit=100"
```

### 美股 BOLL

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/boll?market=us&symbol=AAPL&interval=daily&period=20&nbdev=2.0&limit=100"
```

---

## Time Range Selection (Indicators)

### Mode 1: Using Limit

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/sma?market=cn&symbol=000001.SZ&interval=1d&period=20&limit=500"
```

### Mode 2: Using Time Range

```bash
curl -sS "${AUTH[@]}" \
  "$BASE/api/v2/indicators/sma?market=cn&symbol=000001.SZ&interval=1d&period=20&start=2024-01-01&end=2024-01-31"
```

---

# Quick Examples

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

# Common Errors & Troubleshooting

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
