/* =========================================================
   QUERY 1: Top 10 Symbols by Open Interest (OI) Change
   Uses window functions (LAG) to compute day-over-day OI change
   ========================================================= */

WITH daily_oi AS (
    SELECT
        i.symbol,
        t.trade_date,
        SUM(t.open_int) AS total_oi
    FROM trades t
    JOIN instruments i ON t.instrument_id = i.instrument_id
    GROUP BY i.symbol, t.trade_date
),
oi_change_calc AS (
    SELECT
        symbol,
        trade_date,
        total_oi
        - LAG(total_oi) OVER (
            PARTITION BY symbol
            ORDER BY trade_date
        ) AS oi_change
    FROM daily_oi
)
SELECT
    symbol,
    trade_date,
    oi_change
FROM oi_change_calc
WHERE oi_change IS NOT NULL
ORDER BY oi_change DESC
LIMIT 10;



/* =========================================================
   QUERY 2: 7-Day Rolling Volatility for NIFTY
   Uses STDDEV window function for time-series volatility
   ========================================================= */

SELECT
    t.trade_date,
    STDDEV(t.close) OVER (
        ORDER BY t.trade_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS volatility_7d
FROM trades t
JOIN instruments i ON t.instrument_id = i.instrument_id
WHERE i.symbol = 'NIFTY'
ORDER BY t.trade_date
LIMIT 20;



/* =========================================================
   QUERY 3: Cross-Exchange Comparison
   Average settle (close) price across exchanges
   Schema supports NSE / BSE / MCX
   ========================================================= */

SELECT
    e.exchange_code,
    AVG(t.close) AS avg_settle_price
FROM trades t
JOIN exchanges e ON t.exchange_id = e.exchange_id
JOIN instruments i ON t.instrument_id = i.instrument_id
WHERE i.symbol IN ('NIFTY', 'GOLD')
GROUP BY e.exchange_code;



/* =========================================================
   QUERY 4: Option Chain Summary
   Aggregates volume by expiry date and strike price
   ========================================================= */

SELECT
    e.expiry_dt,
    e.strike_pr,
    SUM(t.volume) AS total_volume
FROM trades t
JOIN expiries e ON t.expiry_id = e.expiry_id
GROUP BY e.expiry_dt, e.strike_pr
ORDER BY e.expiry_dt, e.strike_pr
LIMIT 20;



/* =========================================================
   QUERY 5: Performance-Optimized Query
   Max volume per symbol in the last 30 trading days
   Uses indexed and partitioned trade_date
   ========================================================= */

SELECT
    i.symbol,
    MAX(t.volume) AS max_volume
FROM trades t
JOIN instruments i ON t.instrument_id = i.instrument_id
WHERE t.trade_date >= (
    SELECT MAX(trade_date) FROM trades
) - INTERVAL '30 days'
GROUP BY i.symbol
ORDER BY max_volume DESC
LIMIT 10;



/* =========================================================
    PERFORMANCE VALIDATION (EXPLAIN ANALYZE)
   This section validates optimization for the
   performance-optimized recent volume query above
   ========================================================= */

EXPLAIN ANALYZE
SELECT *
FROM trades
WHERE trade_date >= (
    SELECT MAX(trade_date) FROM trades
) - INTERVAL '30 days';
