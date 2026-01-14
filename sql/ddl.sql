CREATE TABLE exchanges (
    exchange_id SERIAL PRIMARY KEY,
    exchange_code VARCHAR(10) UNIQUE NOT NULL
);

INSERT INTO exchanges (exchange_code)
VALUES ('NSE'), ('BSE'), ('MCX');

CREATE TABLE instruments (
    instrument_id SERIAL PRIMARY KEY,
    instrument_type VARCHAR(10),
    symbol VARCHAR(20),
    exchange_id INT REFERENCES exchanges(exchange_id),
    UNIQUE(symbol, exchange_id)
);

CREATE TABLE expiries (
    expiry_id SERIAL PRIMARY KEY,
    expiry_dt DATE,
    strike_pr NUMERIC(10,2),
    option_typ VARCHAR(2),
    instrument_id INT REFERENCES instruments(instrument_id)
);

CREATE TABLE trades (
    trade_id BIGSERIAL,
    instrument_id INT REFERENCES instruments(instrument_id),
    expiry_id INT REFERENCES expiries(expiry_id),
    trade_date DATE NOT NULL,
    open NUMERIC(10,2),
    high NUMERIC(10,2),
    low NUMERIC(10,2),
    close NUMERIC(10,2),
    volume BIGINT,
    open_int BIGINT,
    exchange_id INT REFERENCES exchanges(exchange_id),
    PRIMARY KEY (trade_id, trade_date)
) PARTITION BY RANGE (trade_date);



SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';
