# 港股 API Reference

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
