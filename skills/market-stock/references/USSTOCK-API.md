# 美股 API Reference

> 代码格式规则、日期格式、并行调用模板见 `SKILL.md` Critical Rules 部分。本文档仅补充各端点的详细参数。
> 美股所有接口代码格式统一使用 Ticker（如 `AAPL`），无后缀。

## 美股实时行情

### Get US Securities Quote
`GET /api/v2/usstock/securities`

批量查询美股实时报价。价格字段已按 power 动态换算，百分比字段已除以 100。单次最多 500 个代码。

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `codes` | string | **Yes** | 股票代码，逗号分隔（如 `AAPL,TSLA,MSFT`） |
| `fields` | string | No | 指定返回字段，逗号分隔（不传则返回全部） |

```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/securities?codes=AAPL"
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/securities?codes=AAPL,TSLA,MSFT"
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/securities?codes=AAPL&fields=price,chgPct,volume"
```

```json
{"success": true, "data": {"AAPL": {"name": "Apple Inc.", "price": 178.50, "chgPct": 0.85, "volume": 52000000}}, "timestamp": 1710865200000}
```

---

## 美股 K线数据

### Get US Stock K-line
`GET /api/v2/usstock/stocks`

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `symbol` | string | **Yes** | US stock code | `AAPL` |
| `startDate` | string | No | Start date YYYYMMDD | `20240101` |
| `endDate` | string | No | End date YYYYMMDD | `20240131` |
| `limit` | int | No | Max 1-5000 (default: 100) | `500` |
| `adjusted` | bool | No | 是否复权（默认 false） | `true` |

```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/stocks?symbol=AAPL&startDate=20240101&endDate=20240131&limit=500"
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/stocks?symbol=AAPL&adjusted=true&limit=200"
```

---

## 美股基础数据

| Endpoint | 代码参数 | 额外参数 | 说明 |
|----------|----------|----------|------|
| `/api/v2/usstock/symbols` | — | — | 美股股票列表 |
| `/api/v2/usstock/trade-cal` | — | `startDate`, `endDate`, `limit`(最大10000) | 交易日历 |

```bash
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/symbols"
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/trade-cal?startDate=20240101&endDate=20240630"
```

---

## 美股市场信息

> 数据源：Alpha Vantage

| Endpoint | 代码参数 | 额外参数 | 说明 |
|----------|----------|----------|------|
| `/api/v2/usstock/market-status` | — | — | 交易所状态（开/收盘） |
| `/api/v2/usstock/top-movers` | — | — | 涨跌排行（涨幅/跌幅榜） |
| `/api/v2/usstock/calendar/earnings` | — | `symbol`, `horizon`: 3month/6month/12month | 盈利日历 |
| `/api/v2/usstock/calendar/ipo` | — | — | IPO 日历 |
| `/api/v2/usstock/market-overview` | — | — | 市场全局概览（耗时较长，约120s） |

```bash
# 交易所状态 + 涨跌排行 — 并行
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/market-status" &
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/top-movers" &
wait

# 盈利日历（指定时间范围或特定股票）
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/calendar/earnings?horizon=3month"
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/calendar/earnings?symbol=AAPL&horizon=6month"

# IPO 日历
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/calendar/ipo"

# 市场全局概览（编排接口，约120s）
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/market-overview"
```

---

## 美股财务数据

> 数据源：Alpha Vantage。参数统一用 `symbol`。

| Endpoint | 额外参数 | 说明 |
|----------|----------|------|
| `/api/v2/usstock/finance/income` | `limit`(1-500, 默认50) | 利润表 |
| `/api/v2/usstock/finance/balancesheet` | `limit`(1-500, 默认50) | 资产负债表 |
| `/api/v2/usstock/finance/cashflow` | `limit`(1-500, 默认50) | 现金流量表 |
| `/api/v2/usstock/finance/dividend` | `limit`(1-500, 默认50) | 股息历史 |
| `/api/v2/usstock/finance/forecast` | `limit`(1-500, 默认50) | 盈利预估（EPS/Revenue consensus） |
| `/api/v2/usstock/finance/splits` | `limit`(1-500, 默认50) | 拆股历史 |
| `/api/v2/usstock/finance/shares` | `limit`(1-500, 默认50) | 流通股数量 |
| `/api/v2/usstock/finance/insider` | `limit`(1-500, 默认50) | 内部人士交易 |
| `/api/v2/usstock/finance/institutional` | `limit`(1-500, 默认50) | 机构持仓 |
| `/api/v2/usstock/finance/transcript` | `quarter`: 如 `2024-Q1` | 财报电话会议（Premium） |
| `/api/v2/usstock/etf-profile` | `limit`(1-500, 默认50) | ETF 档案 |

```bash
# 三大报表并行查询
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/finance/income?symbol=AAPL" &
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/finance/balancesheet?symbol=AAPL" &
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/finance/cashflow?symbol=AAPL" &
wait

# 其他财务数据并行
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/finance/dividend?symbol=AAPL" &
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/finance/forecast?symbol=AAPL" &
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/finance/shares?symbol=AAPL" &
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/finance/insider?symbol=AAPL" &
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/finance/institutional?symbol=AAPL" &
wait

# 财报电话会议（Premium，需要订阅）
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/finance/transcript?symbol=AAPL&quarter=2024-Q1"

# ETF 档案
curl -sS "${AUTH[@]}" "$BASE/api/v2/usstock/etf-profile?symbol=SPY"
```
