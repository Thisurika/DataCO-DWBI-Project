# DataCo Smart Supply Chain — Data Warehousing and Business Intelligence

## 1. Project Overview

This project develops an end-to-end Data Warehousing and Business Intelligence (DWBI) solution using the DataCo Smart Supply Chain dataset. The main objective is to analyse supply-chain operations, sales, customers, products, shipping, and delivery performance to support better business decision-making.

The project transforms raw transactional data into a structured data warehouse, a delivery-performance data mart, and interactive Power BI dashboards.

## 2. Project Objectives

- Build a staging layer to store the source dataset.
- Perform data profiling and data quality validation.
- Design and implement a dimensional data warehouse using a star schema.
- Implement the ETL (Extract, Transform, Load) process.
- Create a delivery-performance data mart.
- Analyse sales, profit, shipping, and delivery performance.
- Develop interactive Power BI dashboards.
- Generate business insights and recommendations.

## 3. Dataset

**Dataset:** DataCo SMART SUPPLY CHAIN FOR BIG DATA ANALYSIS

The dataset contains supply-chain information related to orders, customers, products, categories, dates, locations, sales, profit, and shipping activities.

**Dataset source:** [Mendeley Data — DataCo Smart Supply Chain](https://doi.org/10.17632/8gx2fvg2k6.5)

## 4. Technologies Used

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- Microsoft Power BI
- SQL

## 5. Data Warehouse Architecture

The project follows a layered architecture:

1. **Source Layer:** Original DataCo dataset in CSV format.
2. **Staging Layer:** Stores the imported source data in `dbo.Stg_DataCoSupplyChain`.
3. **Data Warehouse Layer:** Contains dimension tables and the central fact table in the `DW` schema.
4. **Data Mart Layer:** Contains the delivery-performance data mart in the `DM` schema.
5. **Business Intelligence Layer:** Uses Power BI for reporting and interactive analysis.

## 6. Dimensional Model

The warehouse uses a star-schema design with one central fact table and five dimension tables.

### Dimension Tables

- `DW.DimCustomer` — stores customer information and customer segments.
- `DW.DimProduct` — stores product, category, department, and price information.
- `DW.DimDate` — supports order-date and shipping-date analysis.
- `DW.DimLocation` — stores geographical information about markets and order locations.
- `DW.DimShipping` — stores shipping modes, delivery statuses, and late-delivery risk.

### Fact Table

`DW.FactOrderItem`

The fact table stores order-item transactions, including quantity, sales, discounts, profit, and shipping-duration measures.

Each row represents one order-item transaction.

### Data Mart

`DM.FactDeliveryPerformance`

This table provides aggregated delivery-performance information for business analysis and Power BI reporting.

## 7. ETL Process

The ETL process consists of the following steps:

1. Extract and import the source CSV into SQL Server.
2. Profile and validate the staging data.
3. Check product identifiers, category identifiers, and order-level consistency.
4. Create and populate the dimension tables.
5. Validate relationships between staging records and dimension tables.
6. Load the order-item fact table.
7. Validate row counts and reconcile business measures.
8. Create and populate the delivery-performance data mart.
9. Connect Power BI to the reporting data and develop dashboards.

## 8. Data Quality and Validation

Data profiling and validation were performed before loading records into the warehouse.

A location-dimension issue was identified because including latitude and longitude in the uniqueness criteria created duplicate records for logical locations. The dimension was corrected using the logical business location attributes.

The final validation reported successful lookup coverage for customer, product, order date, shipping date, location, and shipping dimensions.

## 9. Project Results

The following results are documented in the project report.

| Metric | Result |
|---|---:|
| Staging records | 180,519 |
| Customers | 20,652 |
| Products | 118 |
| Dates | 1,133 |
| Logical locations | 3,800 |
| Shipping dimension records | 12 |
| Warehouse fact records | 180,519 |
| Data mart records | 154,874 |
| Total quantity | 384,079 |
| Total sales | 36,784,734.31 |
| Total profit | 3,966,902.97 |
| Late shipments | 98,977 |
| On-time shipments | 32,196 |
| Advance shipments | 41,592 |
| Cancelled shipments | 7,754 |

## 10. Power BI Dashboards

The project includes five dashboard pages designed to support supply-chain analysis and business decision-making.

### Dashboard 1: Executive Overview

![Executive Overview Dashboard](images/dashboard-1.png)

Provides an overview of key performance indicators, sales, profit, and shipment status.

### Dashboard 2: Shipping & Customer Performance

![Shipping and Customer Performance Dashboard](power bi sc/dashboard-2.png)

Analyses shipping modes, customer segments, and delivery performance.

### Dashboard 3: Product & Category Performance

![Product and Category Performance Dashboard](images/dashboard-3.png)

Examines product categories, sales, profit, and delivery risk.

### Dashboard 4: Time & Trends

![Time and Trends Dashboard](images/dashboard-4.png)

Analyses changes in sales and delivery performance over time.

### Dashboard 5: Geographic Analysis

![Geographic Analysis Dashboard](images/dashboard-5.png)

Compares supply-chain and delivery performance across markets and geographical regions.

**Note:** Upload your actual PNG screenshots into the `images` folder using the filenames shown above. The images will appear on GitHub when the file paths match.

## 11. Key Business Insights

The project report identifies several important findings:

- Late shipments represent approximately 54.83% of the analysed order-item records.
- On-time shipments represent approximately 17.84%.
- Advance shipments represent approximately 23.04%.
- Delivery performance should be analysed together with sales and profitability.
- Shipping mode, product category, customer segment, time, and geography provide useful perspectives for investigating delivery issues.

### Recommendations

- Monitor late and on-time delivery rates regularly.
- Investigate shipping modes and geographical areas with high delivery risk.
- Analyse delivery performance alongside sales and profit.
- Use Power BI dashboards to monitor operational performance and support data-driven decisions.

## 12. Project Structure

```text
DataCo-Supply-Chain-DWBI/
├── README.md
├── images/
│   ├── dashboard-1.png
│   ├── dashboard-2.png
│   ├── dashboard-3.png
│   ├── dashboard-4.png
│   └── dashboard-5.png
├── sql/
│   └── SQL scripts
└── powerbi/
    └── Power BI report (.pbix)
```

*This is a suggested structure. Adjust the filenames and folders to match your actual project.*

## 13. Conclusion

This project demonstrates the development of an end-to-end data warehousing and business intelligence solution, from source-data preparation and ETL to dimensional modelling, data mart creation, validation, and Power BI reporting.

The solution provides a structured environment for analysing supply-chain performance and generating insights that can support operational and business decision-making.

## 14. References

1. Constante, F., Silva, F., and Pereira, A. *DataCo SMART SUPPLY CHAIN FOR BIG DATA ANALYSIS*. Mendeley Data, Version 5. [https://doi.org/10.17632/8gx2fvg2k6.5](https://doi.org/10.17632/8gx2fvg2k6.5)
2. Kimball, R., and Ross, M. *The Data Warehouse Toolkit: The Definitive Guide to Dimensional Modeling*, 3rd edition, Wiley, 2013.
3. Microsoft Learn. [Power BI Documentation](https://learn.microsoft.com/power-bi/).
4. Microsoft Learn. [SQL Server Documentation](https://learn.microsoft.com/sql/sql-server/).

---

**Course:** IT3101 – Data Warehousing and Business Intelligence

**Project Reference:** 2026-DS-65
