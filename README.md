# Duka Smart Electronics | Retail Sales Analysis

## Project overview

This project uses PostgreSQL to analyze sales and customer activity for
Duka Smart Electronics, a fictional Kenyan electronics retailer. The analysis
covers sales trends, product profitability, customer spending, and purchasing
activity.

## Dataset

The `retail_analytics` database contains two tables.

| Table | Rows | Description |
|---|---:|---|
| `customers` | 150 | Customer records, including city, segment, and registration date |
| `orders` | 800 | Order records, including product, quantity, price, discount, and status |

The tables connect through `customer_id`. One customer can have multiple
orders.

## Tools used

- PostgreSQL for storing and querying the data
- DBeaver for running SQL scripts and reviewing results

## Setup

1. Create a PostgreSQL database named `retail_analytics` if it does not exist.
2. Connect to `retail_analytics` in DBeaver and run `schema.sql` to create
   the tables.
3. Run the supplied `03_insert_customers.sql` and `04_insert_orders.sql`
   scripts in that order. These scripts are provided with the assignment.
4. Run the supplied `05_verify_data.sql` script. Check that it reports
   150 customers, 800 orders, and zero orders without a matching customer.

## Run the analysis

Open `queries.sql` in DBeaver and connect the editor to `retail_analytics`.
The file contains 46 numbered queries covering SQL fundamentals, aggregation,
joins, CTEs, window functions, and business reporting.

Run Q43 before Q46d because Q46d uses the `monthly_sales_summary` view.
For Q44, run the function definition before running its two test queries.

## Business rules

- Revenue, cost, profit, and customer spending use completed orders.
- General order counts include all statuses.
- Discounts are percentages, and monetary results are shown to two decimal places.
- Inactivity is measured from the latest order date in the dataset.

## Key findings

See [insights.md](insights.md) for the findings, their business implications,
and the recommended actions.

## Repository files

| File or folder | Contents |
|---|---|
| `README.md` | Project overview and setup instructions |
| `schema.sql` | Table definitions copied from `02_create_tables.sql` |
| `queries.sql` | Answers to Q1–Q46 |
| `insights.md` | At least five business findings supported by query results |
| `screenshots/` | Data verification output and 3–5 selected query results |
