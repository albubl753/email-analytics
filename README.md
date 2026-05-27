# User Engagement & Email Marketing Analysis

## Business Goal
The objective of this project is to analyze user account creation dynamics and evaluate email campaign performance. The analysis identifies top-performing markets by account volume and calculates key marketing conversion metrics (Open Rate, Click-to-Open Rate) to support targeted user segmentation and engagement strategies.

## Tech Stack
* **Database:** Google BigQuery (SQL)
* **BI Tool:** Looker Studio

## SQL Techniques Applied
* **CTEs (Common Table Expressions):** To structure complex, multi-step data aggregations.
* **Window Functions:** `RANK() OVER` for identifying the Top-10 countries by account and email volume.
* **Data Combinations:** `UNION ALL` to merge distinct datasets (account metrics and email metrics) while preserving dimension granularity (date, country, etc.).
* **Safe Calculations:** `SAFE_DIVIDE` integration to prevent zero-division errors during relative metric calculations.

## Visualization
*[Link to interactive dashboard in Looker Studio](https://lookerstudio.google.com/reporting/fc3e8bd2-7b6b-42d2-8028-0e26a41b0e0b)*

## Key Findings
* **Account Growth:** **United States** leads in new account creation, contributing **12,384 accounts**, significantly outpacing the next largest markets (India with 2,687 and Canada with 2,067).
* **Email Engagement:** While the **United States** has the highest overall volume of sent emails (233,503 messages), the **United Kingdom** demonstrates the most efficient engagement with the highest Click-to-Open Rate (CTOR) at **13.83%**.
* **Verification Status:** User verification directly impacts campaign performance. **Verified accounts** demonstrate a significantly higher engagement, with an average Open Rate of **35.6%**, compared to just 29.5% for unverified users.




