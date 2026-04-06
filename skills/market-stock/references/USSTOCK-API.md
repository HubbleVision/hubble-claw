# 美股 API Reference

## 美股证券实时行情

### Action: Get US Securities Quote

- `GET /api/v2/usstock/securities`

批量查询美股实时报价。价格字段已按 power 动态换算，百分比字段已除以 100。单次最多 500 个代码。

美股使用 Ticker 符号（如 `AAPL`），与其他接口格式一致，无混淆风险。

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `codes` | string | **Yes** | 证券代码，逗号分隔（如 `AAPL,TSLA,MSFT`） |
| `fields` | string | No | 指定返回字段，逗号分隔（不传则返回全部） |

**请求示例：**
```bash
# 查询单只股票
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/securities?codes=AAPL"

# 批量查询
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/securities?codes=AAPL,TSLA,MSFT"

# 只查指定字段
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/securities?codes=AAPL&fields=price,chgPct,volume"
```

**响应：**
```json
{
  "success": true,
  "data": {
    "AAPL": {
      "name": "Apple Inc.",
      "price": 178.50,
      "chgPct": 0.85,
      "volume": 52000000
    }
  },
  "timestamp": 1710865200000
}
```

---

## Action: Get US Stock List

- `GET /api/v2/usstock/symbols`

No parameters required.

**Request:**
```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/symbols"
```

---

## Action: Get US Stock Daily Data

- `GET /api/v2/usstock/stocks`

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
  "$BASE/api/v2/usstock/stocks?symbol=AAPL&startDate=20240101&endDate=20240131&limit=500"
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
