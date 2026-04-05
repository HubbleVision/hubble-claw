# A股 & 指数 API Reference

## Part 1: A股 (Chinese Stocks)

### Action: Get A股 Stock List

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

### Action: Get A股 K-line Data

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

### Action: Get Company Information

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

### Action: Get Daily Basic Indicators

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

### Action: Get Adjustment Factors

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

### Action: Get Name Change History

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

### Action: Get IPO New Shares

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

### Action: Get Daily Price Limits

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

### Action: Get Suspend/Resume Info

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

### Action: Get A股 Trade Calendar

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

## Part 2: A股 Index (指数数据)

### Action: Get Index Basic Info

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

### Action: Get Index Daily Data

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

### Action: Get Index Weekly Data

- `GET /api/v2/cnstock/index/weekly`

**Query Parameters:** Same as index daily.

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/index/weekly?tsCode=000001.SH&limit=100"
```

---

### Action: Get Index Monthly Data

- `GET /api/v2/cnstock/index/monthly`

**Query Parameters:** Same as index daily.

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/cnstock/index/monthly?tsCode=000001.SH&limit=100"
```

---

### Action: Get Index Daily Basic

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

### Action: Get Index Component Weights

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

### Action: Get Industry Classification

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
