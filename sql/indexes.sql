CREATE INDEX idx_trade_date ON trades(trade_date);
CREATE INDEX idx_exchange ON trades(exchange_id);
CREATE INDEX idx_instrument ON trades(instrument_id);
CREATE INDEX brin_trade_date ON trades USING BRIN(trade_date);


SELECT indexname, tablename
FROM pg_indexes
WHERE tablename = 'trades';
