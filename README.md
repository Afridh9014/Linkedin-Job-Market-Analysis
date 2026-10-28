# 📊 LinkedIn Job Market Analysis

> A data-driven exploration of talent competition, hiring trends, experience-level demand and sector activity across **949 LinkedIn job postings** in India, built with **SQL** and an interactive **Excel dashboard**.

![Tools](https://img.shields.io/badge/SQL-SQL%20Server-blue)
![Tools](https://img.shields.io/badge/Excel-Dashboard-green)
![Records](https://img.shields.io/badge/Records-949-orange)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

---

## 📑 Table of Contents

1. [Project Overview](#-project-overview)
2. [Business Problem & Objectives](#-business-problem--objectives)
3. [Dataset](#-dataset)
4. [Tools & Technologies](#-tools--technologies)
5. [Repository Structure](#-repository-structure)
6. [Dashboard](#-dashboard)
7. [Analysis Breakdown](#-analysis-breakdown)
8. [Key Insights](#-key-insights)
9. [Recommendations](#-recommendations)
10. [SQL Concepts Demonstrated](#-sql-concepts-demonstrated)
11. [Data Notes & Limitations](#-data-notes--limitations)
12. [How to Reproduce](#-how-to-reproduce)
13. [Author](#-author)

---

## 🔍 Project Overview

This project analyses LinkedIn job postings to understand **how competitive the job market is, where hiring is concentrated, and what kind of talent employers want**. It answers 16 business questions using SQL (basic aggregations through window functions and CTEs) and presents the headline numbers in an interactive Excel dashboard with slicers for sector, year and month.

The work is split into two parts:

- **Part A – Basic Understanding (6 questions):** competition, in-demand experience levels, hiring months, top roles and sectors.
- **Part B – Advanced Business Analytics (10 questions):** window functions, CTEs, growth/decline trends, senior vs entry-level gaps, geographic hotspots and employer activity.

---

## 🎯 Business Problem & Objectives

Job seekers, recruiters and workforce planners lack a clear view of where competition is highest and when and where hiring happens. This project aims to:

- Measure **applicant competition** by role, company, sector and experience level
- Identify **peak hiring periods** and monthly demand patterns
- Find **geographic hotspots** for job opportunities
- Compare **senior vs entry-level** demand across sectors
- Understand **employment-type preferences** (full-time, contract, part-time)
- Benchmark the **most active hiring companies**

---

## 🗂 Dataset

| Property | Details |
|---|---|
| **Source** | LinkedIn job postings (India) |
| **Records** | 949 rows |
| **Columns** | 16 |
| **Time span** | March 2023 – February 2024 (`publishedAt`, format `dd-mm-yyyy`) |
| **Geography** | City and state level (Bengaluru, Mumbai, Gurugram, Pune, Hyderabad, etc.) |
| **Total applications** | 111,031 |

### Data Dictionary

| Column | Description |
|---|---|
| `Column1` | Index column (row number from the export) |
| `id` | Unique LinkedIn job ID |
| `publishedAt` | Date the job was published |
| `title` | Job title |
| `companyName` | Hiring company |
| `postedTime` | Relative posting time (e.g. "3 weeks ago") |
| `applicationsCount` | Number of applications received |
| `description` | Job description text / skills |
| `contractType` | Full-time, Contract, Part-time, Internship, Temporary, Other |
| `experienceLevel` | Entry level, Associate, Mid-Senior level, Director, Executive, Internship, Not Applicable, Part-time |
| `workType` | Functional category of the job |
| `sector` | Industry sector of the company |
| `companyId` | LinkedIn company ID |
| `city` | City of the job |
| `state` | State of the job |
| `recently_posted_jobs` | Flag (Yes/No) for recently posted jobs |

---

## 🛠 Tools & Technologies

- **SQL (SQL Server / T-SQL)** – data querying and analysis
- **Microsoft Excel** – PivotTables, PivotCharts, slicers and dashboard design
- **SSMS** – query execution and result validation

---

## 📁 Repository Structure

```
├── data/
│   └── linkedin.csv                      # Raw dataset (949 rows, 16 columns)
├── sql/
│   └── queries.sql                       # All SQL queries (Part A + Part B)
├── dashboard/
│   ├── dashboard.png                     # Dashboard screenshot
│   └── LinkedIn_Job_Dashboard.xlsx       # Interactive Excel dashboard
├── report/
│   └── LinkedIn_Job_Analysis_Report.pdf  # Full 16-page analysis report
└── README.md
```

> Adjust the paths above to match your actual folder layout.

---

## 📈 Dashboard

![LinkedIn Job Analysis Dashboard](dashboard/dashboard.png)

The Excel dashboard includes:

- **KPI cards** showing applications by experience-level group, each with a donut share
- **Pie chart** of job share by sector (filterable)
- **Line chart** of job volume by contract type
- **Combo chart** of total jobs (bars) vs applications per job (line) for the top cities
- **Slicers** for **sector**, **year** and **month** to filter every visual

### Experience-Level Groups (Dashboard KPIs)

| Group | Includes | Applications | Share |
|---|---|---|---|
| Mid-Senior Level | Mid-Senior level | 41,968 | 38% |
| Entry Level | Entry level + Internship | 33,610 | 30% |
| Senior Level | Associate + Director + Executive | 25,506 | 23% |
| Others | Not Applicable + Part-time | 9,947 | 9% |

---

## 🧠 Analysis Breakdown

### Part A: Basic Understanding

| # | Question | Technique |
|---|---|---|
| A1 | Talent competition: which roles and companies attract the most applicants? | `SUM`, `GROUP BY` |
| A2 | Which experience levels are most in demand? | `COUNT`, `GROUP BY` |
| A3 | Which experience level faces the highest competition? | `SUM` of applications by level |
| A4 | Which months see the highest hiring activity? | `MONTH()`, `GROUP BY` |
| A5 | Which roles attract the most applicants? | `SUM`, `GROUP BY` |
| A6 | Which sectors post the most jobs? | `COUNT`, `SUM`, `WHERE IS NOT NULL` |

### Part B: Advanced Business Analytics

| # | Question | Technique |
|---|---|---|
| B1 | Rank hiring pace | `DENSE_RANK() OVER` |
| B2 | Which jobs are significantly more competitive than average? | CTE + self-`JOIN` against `AVG` |
| B3 | Which sectors, cities and roles are surging or declining? | CTEs + `LAG()`, growth % with `CASE` |
| B4 | Are employers disproportionately seeking senior talent? | Conditional aggregation, `NULLIF` |
| B5 | Which companies have nationwide hiring presence? | `COUNT(DISTINCT)`, `HAVING` |
| B6 | Which cities and states have the highest job activity? | `GROUP BY city, state` |
| B7 | Full-time vs contract vs part-time preference | `CASE WHEN`, `GROUP BY` |
| B8 | Which sectors need senior vs entry-level talent? | Conditional aggregation |
| B9 | Which companies are the most active hirers? | `HAVING COUNT(*) >= 10` |
| B10 | Monthly trend in job postings | `YEAR()`, `MONTH()` time series |

### Sample Query: Surge / Decline Detection (B3)

```sql
WITH postingOvertime AS (
    SELECT sector, city, title,
           YEAR(publishedAt)  AS year,
           MONTH(publishedAt) AS month,
           COUNT(*)           AS number_of_jobs
    FROM Linkedin_jobs
    GROUP BY sector, city, title, YEAR(publishedAt), MONTH(publishedAt)
),
prevJobcount AS (
    SELECT *,
           LAG(number_of_jobs) OVER (ORDER BY year, month) AS Prevnumber_of_jobs
    FROM postingOvertime
)
SELECT *,
       ROUND((number_of_jobs - Prevnumber_of_jobs) * 100.0 / Prevnumber_of_jobs, 2) AS growth_percentage,
       CASE WHEN number_of_jobs > Prevnumber_of_jobs THEN 'Surge'
            WHEN number_of_jobs < Prevnumber_of_jobs THEN 'Decline'
            ELSE 'Standard' END AS status
FROM prevJobcount;
```

---

## 💡 Key Insights

| Theme | Finding |
|---|---|
| 🏙 **Top hiring city** | **Bengaluru** leads with **196 jobs** and **26,094 applications**, followed by Mumbai (123), Gurugram (67), Pune (62) and Hyderabad (54) |
| 📅 **Peak hiring month** | **January** has **587 postings**, over 5x any other month (see data note below) |
| 💼 **Employment type** | **Full-time dominates** with 920 postings; Contract (11) and Part-time (3) are marginal |
| 🔥 **Most competed role** | **Data Scientist** with **6,325 total applications** and DENSE_RANK #1 (47 postings), followed by Product Manager (5,043) |
| 🏭 **Top sector** | **Financial Services** with **131 jobs** and 14,528 applications, followed by IT Services & Consulting (85) and Software Development (74) |
| 🎓 **Experience demand** | **Mid-Senior level** is the most demanded (355 jobs, 41,968 applications), followed by Entry level (301 jobs) |
| 🌐 **Nationwide hirers** | Large enterprises such as Tata Cummins and Aditya Birla Capital operate across multiple cities and states |
| 🏢 **Active hirers** | Companies with 10+ postings include Tata Cummins, Freshworks, Infosys and Microsoft |

---

## ✅ Recommendations

**For job seekers**
- Target **Bengaluru, Mumbai, Gurugram, Pune and Hyderabad** for the most openings.
- Prepare to stand out for **Data Scientist** and **Product Manager** roles, which see the highest application volumes.
- Time your search around **January**, the heaviest hiring month in this dataset.

**For recruiters / HR teams**
- Expect heavy applicant volumes for popular roles and plan screening capacity accordingly.
- Entry-level roles are far more competitive per posting than niche senior roles in many sectors, so tailor outreach.

**For analysts / workforce planners**
- Financial Services and IT Services are the largest demand pools.
- Full-time hiring dominates; contract and part-time pipelines are small in this sample.

---

## 🧰 SQL Concepts Demonstrated

- Aggregations: `COUNT`, `SUM`, `AVG`
- Grouping and filtering: `GROUP BY`, `HAVING`, `WHERE`
- Window functions: `DENSE_RANK()`, `LAG()`
- Common Table Expressions (CTEs), including multi-CTE chains
- Self-joins and joins between CTEs
- Conditional logic: `CASE WHEN`
- Date functions: `YEAR()`, `MONTH()`
- Null-safe maths: `NULLIF`
- `COUNT(DISTINCT ...)` for geographic spread
- `TOP N` result limiting

---

## ⚠️ Data Notes & Limitations

- **Sample size:** 949 postings is a small snapshot, not the whole Indian job market.
- **January spike:** 587 of 949 postings fall in January, which suggests the data was scraped in batches. Treat "seasonality" conclusions as indicative only.
- **Full-time share:** Full-time is 920 of 949 rows (about 96.9%). The 98.3% in the report excludes Internship, Temporary and Other rows from the denominator (920 of 936).
- **`workType` typos:** values like "Engineering and Inforamation Technology" exist in the raw data and should be cleaned before using that column.
- **Location values:** some `city` entries are regions or countries (e.g. "India", "Greater Kolkata Area"), so city-level counts may be slightly fragmented.
- **"Competition" metric:** several queries use total applications; a true applicants-per-posting ratio would be `SUM(applicationsCount) / COUNT(*)`.
- **Naming in B1 / B10:** B1 ranks job *titles* and B10 groups by company; the descriptions refer to companies in places.
- **Label typos in B3:** the status labels in the original SQL are spelled `Serge` / `Declain` (meant "Surge" / "Decline"); the corrected spelling is used in the sample above.
- **LAG scope:** the B3 `LAG()` is ordered by year and month without partitioning, so growth is computed against the previous row overall rather than per sector/city/title. Adding `PARTITION BY sector, city, title` would give true per-segment trends.

---

## ▶️ How to Reproduce

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/<your-repo-name>.git
   cd <your-repo-name>
   ```
2. **Load the data** into SQL Server: import `data/linkedin.csv` into a table named `Linkedin_jobs` (use `dd-mm-yyyy` handling or convert `publishedAt` to `DATE`).
3. **Run the queries** from `sql/queries.sql` in SSMS (Part A first, then Part B).
4. **Open the dashboard** (`dashboard/LinkedIn_Job_Dashboard.xlsx`) in Excel and use the sector, year and month slicers to explore.
5. **Read the full report** in `report/LinkedIn_Job_Analysis_Report.pdf`.

---

## 👤 Author

**Pathan Afridh Khan**
Data Analyst | SQL • Excel

📧 pathanafridhkhan@gmail.com

⭐ If you found this project useful, consider giving it a star!
