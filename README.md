# fno-database-design
# Futures & Options (F&O) Database Design

## Overview
This project implements a scalable and performance-optimized relational database to store and analyze high-volume Futures & Options (F&O) trading data from Indian exchanges. The solution is designed for time-series analytics, multi-exchange extensibility, and efficient querying on millions of records.

The database is built using PostgreSQL and validated using real-world market data from the National Stock Exchange (NSE).

---

## Dataset
- **Source:** Kaggle – NSE Future and Options Dataset (3 Months)
- **Rows:** ~2.53 million
- **Date Range:** August 2019 – November 2019
- **Instruments:** Index futures, stock futures, and options
- **Key Fields:** Symbol, expiry date, strike price, option type, OHLC prices, volume, open interest, timestamp

> **Note:** The raw CSV dataset is not included in this repository due to GitHub file size limits. The dataset can be downloaded directly from Kaggle using the provided link in the assignment.

---

## Technology Stack
- **Database:** PostgreSQL
- **Programming Language:** SQL, Python
- **Data Ingestion:** Pandas, SQLAlchemy
- **Optimization Techniques:** Indexing, partitioning
- **Tools:** pgAdmin, VS Code, Git

---

## Database Design
The schema follows **Third Normal Form (3NF)** to minimize redundancy and maintain data integrity. The design supports ingestion of data from multiple exchanges (NSE, BSE, MCX) without requiring schema changes.

### Core Tables
- `exchanges` – Exchange master table
- `instruments` – Tradable instruments per exchange
- `expiries` – Expiry date, strike price, option type combinations
- `trades` – Fact table storing daily OHLC prices, volume, and open interest

An ER diagram illustrating table relationships is provided in the `er_diagram/` directory.

---

## Data Ingestion
- Raw CSV data is first loaded into a staging table
- Chunked inserts are used to manage memory efficiently
- Data is normalized into dimension and fact tables
- Row-count validation is performed to ensure correctness

---

## Performance Optimization
The following optimizations were applied:
- B-tree indexes on frequently filtered columns
- BRIN index on `trade_date` for efficient time-range queries
- Monthly range partitioning on the `trades` table
- Default partition to handle out-of-range dates safely

---

## Analytical Queries Implemented
The project includes advanced SQL queries for:
- Open interest (OI) change using window functions
- 7-day rolling volatility analysis
- Option chain summary grouped by expiry and strike price
- Performance-optimized recent volume analysis
- Query performance validation using `EXPLAIN ANALYZE`

All queries are available in `sql/queries.sql`.

---

## Performance Validation
Query performance was evaluated using `EXPLAIN ANALYZE`. The execution plan confirmed:
- Effective partition pruning
- Index-only scans on recent data
- Execution time of approximately 340 ms for recent-date queries on a 2.5M+ row fact table

```
## Repository Structure

fno-database-design/
├── README.md
├── sql/
│ ├── ddl.sql
│ ├── indexes.sql
│ └── queries.sql
├── ingestion/
│ └── load_data.ipynb
├── er_diagram/
│ └── er_diagram.png
├── explain/
│ └── explain_analyze.txt
└── docs/
└── design_reasoning.pdf


```
