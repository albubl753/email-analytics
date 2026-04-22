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

## Visualizations

![Looker Studio Dashboard](Insert_link_to_your_screenshot_image_here.png)

[View Interactive Dashboard in Looker Studio](Insert_Your_Looker_Studio_Link_Here)

## Key Findings
1. **Account Growth:** [Insert Country Name] leads in new account creation, contributing [Insert Number or %] to the overall user base.
2. **Email Engagement:** While [Country A] has the highest volume of sent emails, [Country B] demonstrates the most efficient engagement with a Click-to-Open Rate (CTOR) of [Insert %].
3. **Verification Status:** [Insert a brief analytical fact, e.g., Verified accounts demonstrate a consistently higher open rate compared to unverified accounts].
