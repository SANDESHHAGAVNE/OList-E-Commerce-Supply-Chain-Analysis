# Olist E-commerce Logistics & Supply Chain Analysis

## 📌 Project Overview

This project provides a comprehensive analysis of the Olist e-commerce dataset, focusing on logistics efficiency and supply chain performance. The goal was to move beyond flat file analysis and build a scalable data pipeline that identifies where delays occur in the order lifecycle and how those delays impact the business's bottom line.

## 🛠️ Tech Stack

- **Database:** MySQL (Schema Design, ETL, Views)
- **BI Tool:** Power BI (Star Schema Modeling, DAX, Geospatial Mapping)
- **Data Source:** Brazilian E-Commerce Public Dataset (100k+ orders)

## 🏗️ Project Architecture

### 1. Database Architecture & ETL

The foundation of the project involved migrating disconnected CSV files into a structured Relational Database.

- **Schema Design:** Built 9 interconnected tables with established Primary and Foreign Keys.
- **Optimization:** Standardized column naming conventions for cleaner SQL querying and BI field management.
- **Data Cleaning:** Handled deduplication using `DISTINCT ON` logic and patched incomplete metadata for product category translations.

### 2. Analytical Modeling (SQL Views)

Rather than performing transformations in the BI tool, heavy lifting was offloaded to MySQL using Master Views:

- **Logistics View:** Breaks down the order lifecycle into Warehouse Time (Seller handoff) and Shipping Time (Carrier transit).
- **SLA Analysis:** Calculates the gap between estimated and actual delivery dates.
- **Product Master:** Calculates volumetric weight (`L×W×H/6000`) to analyze shipping cost efficiency.

### 3. Power BI Dashboard

Created a two-page executive report designed for Operations and Sales stakeholders.

- **Page 1: Logistics Overview:** Tracks On-Time Delivery Rates, average lead times, and geospatial satisfaction heatmaps.
- **Page 2: Product & Cost Analysis:** Deep dive into category performance, shipping cost correlations, and regional efficiency.
- **Custom DAX:** Developed a dynamic `On-Time Rate %` measure using `CALCULATE` and `DIVIDE` logic.

## 📈 Key Insights

- **Bottleneck Analysis:** Identified that warehouse processing time accounts for a significant portion of delays in high-volume regions.
- **SLA Correlation:** Proved that customer review scores drop by an average of 1.2 points for every 3 days a delivery exceeds the SLA.
- **Regional Trends:** Visualized freight cost disparities across Brazilian states, highlighting opportunities for local warehousing incentives.

## ⚠️ Technical Challenges & Solutions

- **Connectivity:** Resolved MySQL SASL/SCRAM authentication errors and local loopback (127.0.0.1) connection issues.
- **Data Modeling:** Managed Many-to-Many relationship complexities in Power BI using bi-directional filtering while maintaining data integrity.
- **Geospatial Accuracy:** Fixed "data drift" in map visuals by implementing precise Latitude/Longitude coordinate mapping and data categorization.

## 🚀 How to Use

1. **SQL:** Run the provided scripts to initialize the database schema and populate the analytical views.
2. **Power BI:** Connect the `.pbix` file to your local MySQL instance (ensure the database name matches).
3. **Interact:** Use the synchronized slicers to filter by date range, product category, or region.








