# IKEA Gifting Customer Analytics & RFM Segmentation

A guided learning project that explores customer value, purchasing behaviour, and customer inactivity using SQL, Python, and Power BI. The project follows a business-oriented workflow: prepare transaction data, calculate customer-level RFM metrics, assign customer segments, and present the results in an interactive dashboard.

> **Project transparency:** This is a guided project based on a YouTube tutorial. Credit the original creator and link to the exact video below. The repository documents the workflow and learning outcomes; it should not imply that the original project idea or tutorial was created independently.
>
> **Tutorial:** [Add YouTube video title and URL]  
> **Tutorial creator/channel:** [Add creator or channel name]  
> **My work:** [Briefly describe any changes, additional analysis, validation, or dashboard improvements you personally completed.]

## Table of Contents

- [Business Context](#business-context)
- [Business Objective](#business-objective)
- [Business Questions](#business-questions)
- [Dataset](#dataset)
- [Tools and Technologies](#tools-and-technologies)
- [Project Workflow](#project-workflow)
- [RFM Methodology](#rfm-methodology)
- [Customer Segments](#customer-segments)
- [Power BI Dashboard](#power-bi-dashboard)
- [Initial Dashboard Observations](#initial-dashboard-observations)
- [Data Quality and Validation Notes](#data-quality-and-validation-notes)
- [Repository Structure](#repository-structure)
- [How to Reproduce](#how-to-reproduce)
- [Limitations](#limitations)
- [Potential Improvements](#potential-improvements)
- [Credits and Disclaimer](#credits-and-disclaimer)

## Business Context

The project uses transaction data for an online retailer selling giftware and home décor. The business has both individual customers and wholesale buyers, so customer value can vary significantly. The analysis aims to provide a more structured view of customer purchasing activity, revenue contribution, and inactivity.

The transaction period covered by the project is December 2009 to December 2011.

## Business Objective

Analyze customer purchasing behaviour and segment customers according to Recency, Frequency, and Monetary value (RFM). Use these metrics to identify high-value customers, customers who may need retention attention, and customers with no recorded purchase activity within a defined period.

The Power BI report presents these findings through KPI cards, segment comparisons, geographic summaries, and time-based trends.

## Business Questions

- Which customer segments contribute the most revenue?
- Which segments contain the most customers?
- Which customers have not purchased recently and may need attention?
- How do revenue and customer activity change by month, quarter, and year?
- How do customer value and RFM scores vary by country?
- What retention or engagement actions could be considered for different customer segments?

## Dataset

**Dataset:** Online Retail II  
**Source:** UCI Machine Learning Repository  
**Original donation:** Daqing Chen  
**Period:** December 2009–December 2011

The source dataset contains transaction-level fields such as:

| Field | Description |
|---|---|
| Invoice | Invoice or transaction identifier |
| StockCode | Product/item code |
| Description | Product description |
| Quantity | Quantity recorded on the invoice line |
| InvoiceDate | Date and time of the transaction |
| Price | Unit price |
| Customer_ID | Customer identifier |
| Country | Customer's country field in the source data |

The project SQL script combines two yearly tables. The original BRD describes 1,067,371 rows across the two-year dataset; the actual row count should be confirmed after loading the source files and running the SQL checks.

**Data access:** Obtain the dataset from its original source and follow its terms. The raw dataset is not included in this repository by default.

## Tools and Technologies

- **Microsoft SQL Server / T-SQL** — combining source tables, type conversion, data-quality checks, duplicate detection, and creation of a cleaned table.
- **Python** — customer-level aggregation and RFM calculations.
- **Pandas** — data preparation, grouping, merging, date handling, and CSV export.
- **Jupyter Notebook / Google Colab** — running the Python workflow.
- **Microsoft Power BI** — KPI cards, interactive slicers, trend charts, segment comparisons, and dashboard pages.

## Project Workflow

### 1. SQL: Data preparation and quality checks

The SQL script:

1. Checks the row counts of the two yearly source tables.
2. Combines the tables with `UNION ALL` into `RetailCombined`.
3. Converts invoice dates using `TRY_CONVERT` and converts price to a decimal type.
4. adds a `SourceSheet` field to identify the source year/table.
5. Checks failed date and price conversions.
6. Checks missing `Customer_ID` values.
7. Counts negative-quantity rows.
8. Identifies exact duplicate transaction lines using the available transaction fields.
9. Uses `ROW_NUMBER()` to retain one row per matching transaction-line key and writes the result to `RetailCleaned`.
10. Compares row counts before and after deduplication.

**Output:** `RetailCleaned`, which can be exported as `RetailCleaned.csv` for the notebook.

### 2. Python: Customer-level RFM calculations

The notebook reads `RetailCleaned.csv`, assigns column names, converts `InvoiceDate` to a datetime type, and checks the DataFrame shape and data types.

For the RFM calculations, the notebook keeps rows where `Customer_ID` is present and `Quantity > 0`. It then calculates one record per customer.

### 3. RFM scoring and segmentation

The notebook assigns quintile-based scores for Recency, Frequency, and Monetary value using `pandas.qcut`. Recency scores are reversed so that a more recent purchase receives a higher score. Frequency and Monetary scores increase with higher values.

A rule-based function assigns each customer to one of six segments. A churn flag is also created using the notebook's 90-day inactivity threshold.

### 4. Dashboard dataset export

The notebook adds:
- `InvoiceMonth`, derived from `InvoiceDate`
- `Revenue`, calculated as `Quantity * Price`

It merges the customer-level RFM fields back into the transaction-level data and exports `EcommerceDashboardData.csv` for Power BI.

### 5. Power BI: Interactive reporting

The dashboard contains a home/navigation page, a Business Overview page, and an RFM Analysis page. Slicers allow users to filter by month, quarter, year, country, and segment.

## RFM Methodology

RFM stands for **Recency, Frequency, and Monetary value**.

| Metric | Definition used in the notebook | Interpretation |
|---|---|---|
| Recency | Number of days between the snapshot date (`2011-12-10`) and the customer's latest recorded invoice date | Fewer days means a more recent purchase |
| Frequency | Number of distinct invoice IDs for the customer | More invoices indicate more frequent purchasing |
| Monetary | Sum of `Quantity * Price` across the filtered rows for that customer | Higher values indicate greater recorded transaction value |

### Scoring

- `R_score`: quintile score based on Recency, with labels reversed so lower recency days receive higher scores.
- `F_score`: quintile score based on the customer's distinct invoice count. The notebook ranks Frequency with `method='first'` before applying `qcut` to help create quintiles where values are tied.
- `M_score`: quintile score based on Monetary value.

The scoring rules and thresholds are rule-based and intended to support interpretable customer grouping, not to predict future behaviour.

## Customer Segments

The notebook assigns segments using the following rules:

| Segment | Rule summary in the notebook | General interpretation |
|---|---|---|
| Champions | R, F, and M scores are each at least 4 | Recent, frequent, high-value customers |
| Loyal | R score at least 3 and F score at least 3, after the Champions rule | Customers with relatively recent and repeated purchasing |
| At Risk | R score at most 2 and F score at least 3, after earlier rules | Previously frequent customers whose last purchase was less recent |
| New | R score at least 4 and F score at most 2, after earlier rules | Recent customers with a low purchase frequency |
| Needs Attention | R score equals 3 and F score at most 2, after earlier rules | Customers with limited frequency who may merit engagement |
| Lost | Customers not assigned to any of the preceding rules | Remaining customers under the rule set |

These labels are operational definitions created by the notebook; they are not independently verified customer states.

### Churn flag

The notebook creates `IsChurned` using:

`Recency > 90`

This is a fixed inactivity rule. It does not mean that a predictive churn model has estimated the probability that a customer will leave.

## Power BI Dashboard

### Business Overview — Customer View

![Business Overview customer view](screenshots/business-overview-customers.png)

This view includes:
- Total Customers
- Total Revenue
- Churn %
- Average Customer Value
- Total customers by segment
- Customer retention by segment
- Customer trends by month, quarter, and year

### Business Overview — Revenue View

![Business Overview revenue view](screenshots/business-overview-revenue.png)

This view focuses on:
- Revenue contribution by segment
- Revenue retention by segment
- Revenue trends by month, quarter, and year

### RFM Analysis — Country View

![RFM analysis country view](screenshots/rfm-analysis-country.png)

This view includes a country-level performance table with customer counts, revenue, and average RFM scores, along with a chart of the top five countries by average customer value.

### RFM Analysis — Segment View

![RFM analysis segment view](screenshots/rfm-analysis-segment.png)

This view compares customer counts, revenue, average RFM scores, and average customer value across the six customer segments.

The report includes slicers for month, quarter, year, country, and segment, allowing users to explore subsets of the data.

## Initial Dashboard Observations

The following are approximate readings from the current dashboard screenshots. They should be recalculated from the final, validated dataset before being used as formal business conclusions.

- The overview KPI cards show approximately **5,881 customers** and **$17.4 million in revenue**.
- The displayed churn KPI is approximately **50.9%**.
- The Champions segment contributes approximately **$11.8 million** in the revenue view.
- The quarterly revenue chart reaches its highest displayed value in Q4, at approximately **$6.2 million**.
- The country and segment tables allow comparisons of customer counts, revenue, and average RFM scores.

These are descriptive dashboard observations, not causal explanations. For example, the dashboard alone does not explain why one segment generates more revenue than another.

## Data Quality and Validation Notes

Before treating the dashboard as a final business analysis, validate the following:

1. **Returns and cancellations:** The SQL script counts negative quantities but does not remove them from `RetailCleaned`. The Python RFM and dashboard preparation steps then filter to `Quantity > 0`. Confirm that excluding negative-quantity rows is the intended treatment for the analysis.
2. **Duplicate handling:** The SQL script removes exact matches based on invoice, stock code, description, quantity, invoice date, price, customer ID, and country. Review duplicate counts and ensure that repeated lines are not legitimate distinct transactions.
3. **Missing customer IDs:** Transactions without `Customer_ID` are excluded from customer-level RFM calculations. Document how many rows are excluded.
4. **Snapshot date:** The notebook uses `2011-12-10`. Keep this consistent with the analysis period and document the rationale.
5. **Churn definition:** `Recency > 90` is a fixed rule. The resulting churn percentage depends on the snapshot date, transaction filters, and customer population.
6. **Revenue definition:** The notebook calculates line revenue as `Quantity * Price`. Confirm how returns, cancellations, and any non-standard invoice types are handled.
7. **Metric labels:** Confirm whether Power BI's “Total Customers,” “Churned %,” and “Average Customer Value” measures are calculated at the intended customer or transaction grain.
8. **Country ranking:** Check whether “Top 5 Countries by Avg Customer Value” is sorted and filtered as intended and whether countries with very small customer counts need context.

Document any changes made during validation so that the SQL, notebook, and Power BI report remain consistent.

## Repository Structure

```text
ikea-customer-analytics/
├── README.md
├── sql/
│   └── EDA_and_Cleaning.sql
├── notebooks/
│   └── IKEA_RFM_Segmentation.ipynb
├── screenshots/
│   ├── business-overview-customers.png
│   ├── business-overview-revenue.png
│   ├── rfm-analysis-country.png
│   └── rfm-analysis-segment.png
├── docs/
│   └── Business_Requirements_Document.md
└── IKEA_Dashboard.pbix   # Add if you have permission to share it
```

The repository can also include a sanitized business requirements summary. The supplied BRD is labelled **Internal Use Only** and includes a named preparer, so do not publish it publicly unless you have permission. Remove confidential details or keep the original document private where appropriate.

## How to Reproduce the Project

1. Download the Online Retail II dataset from the UCI Machine Learning Repository and follow its terms.
2. Import the two yearly data files into SQL Server as `Year2009_2010` and `Year2010_2011`, or update the SQL script to match your table names.
3. Run the SQL script in order to create `RetailCombined` and `RetailCleaned`.
4. Export `RetailCleaned` to `RetailCleaned.csv`, including the column headers, or adapt the notebook's CSV import to match the export format.
5. Open `IKEA_RFM_Segmentation.ipynb` in Jupyter Notebook or Google Colab.
6. Update the input file path and verify the CSV headers before running the notebook.
7. Review the transaction filters, snapshot date, duplicate treatment, and RFM definitions.
8. Run the notebook to generate `EcommerceDashboardData.csv`.
9. Open the Power BI report, connect it to the exported CSV, and refresh the data.
10. Validate the KPI measures and dashboard totals against the prepared dataset.

File paths, table names, and column headers may need to be adjusted for your environment.

## Limitations

- This is a **guided project**, not a project developed entirely from scratch.
- The segment rules use fixed score thresholds and do not use a predictive model.
- The churn flag is based on a fixed 90-day inactivity threshold.
- The analysis is historical and does not establish causes for changes in revenue or customer activity.
- Wholesale and individual retail customers are not explicitly separated in the supplied workflow.
- Results depend on data-cleaning choices, transaction filters, the snapshot date, and the definitions of the Power BI measures.
- The dashboard screenshots show selected views; the `.pbix` file is not included unless added separately.

## Potential Improvements

- Add a data dictionary and document all cleaning decisions.
- Validate revenue and customer totals against SQL and Python outputs.
- Add a segment-level action plan with clearly stated business hypotheses.
- Add a dedicated page showing the number and percentage of customers flagged by the 90-day rule.
- Test alternative inactivity thresholds and compare how the flagged population changes.
- Improve reproducibility by documenting exact data import settings, notebook package requirements, and Power BI data-source paths.
- Add the `.pbix` file only if its size and sharing permissions allow it.

## Credits and Disclaimer

This project was completed as a guided learning exercise based on a YouTube tutorial.

- **Tutorial creator/channel:** [Add creator/channel name]
- **Video title:** [Add exact video title]
- **Video link:** [Add YouTube URL]
- **Dataset:** Online Retail II, UCI Machine Learning Repository; donated by Daqing Chen.

The original tutorial creator retains credit for their instructional material and project guidance. Any additional work described as personal contributions should be limited to changes, validation, or analysis actually completed by the repository author.

This repository is for educational and portfolio purposes. It is not an official IKEA business report and does not represent IKEA's actual internal analysis or recommendations.
