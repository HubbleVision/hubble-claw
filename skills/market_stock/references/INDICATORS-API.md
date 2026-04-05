# Technical Indicators API Reference

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

## Time Range Selection

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
