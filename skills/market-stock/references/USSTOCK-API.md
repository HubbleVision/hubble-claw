# 美股 API Reference

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
