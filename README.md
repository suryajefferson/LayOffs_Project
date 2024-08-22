
## Abstract

This project analyzes global job layoffs using a comprehensive dataset encompassing various companies, industries, and time periods. The primary objective was to uncover trends and patterns in layoffs, including the impact on different sectors, companies, and temporal fluctuations. Through SQL queries and data aggregation, the analysis reveals key insights into which companies and industries were most affected, the relationship between funding and layoffs, and the trends over time. This project highlights the importance of data cleaning and optimization in SQL for accurate and meaningful analysis, providing a detailed view of the dynamics of job layoffs across the global job market.
# About the Data

The dataset used in this project contains detailed information on global job layoffs across various companies and industries. Key attributes include:

- **Company**: The name of the company where layoffs occurred.
- **Location**: The geographical location of the company.
- **Industry**: The industry sector to which the company belongs.
- **Total Laid Off**: The number of employees laid off by the company.
- **Percentage Laid Off**: The percentage of the company’s workforce that was laid off.
- **Date**: The date when the layoffs were announced or took place.
- **Stage**: The business stage of the company (e.g., Post-IPO, Series B, etc.).
- **Country**: The country where the company is headquartered.
- **Funds Raised**: The amount of funds (in millions) raised by the company.

This data provides a comprehensive overview of layoffs across different sectors, regions, and time periods, allowing for in-depth analysis of trends and patterns in job cuts.

# Tools I Used

For my detailed study of the data analyst job market, I used several important tools:

- **SQL**: The main tool for querying the database and finding key insights.
- **PostgreSQL**: The database system I used to manage the job posting data.
- **Visual Studio Code**: My preferred tool for managing the database and running SQL queries.
- **Git & GitHub**: Crucial for version control and sharing my SQL scripts and analysis, enabling collaboration and tracking.

# Overview of this Project

### Phase 1: Database Setup

1. **Creating the Database** - Establish a new database, ensuring it is structured according to the requirements of the project.

2. **Creating the Tables** - Design and implement the tables within the database, defining appropriate schema and data types to store the data effectively.

3. **Loading the Data** - Import the data into the created tables, ensuring it is correctly mapped and integrated for analysis.


### Phase 2: Data Cleaning

1. **Copying Original Table** - It is recommended to apply changes to a copied version of the table rather than modifying the original.

2. **Removing Duplicates** - Eliminate repetitive rows to ensure data accuracy.

3. **Standardizing Data** - Identify and correct issues such as spelling errors, column type mismatches, and other discrepancies.

4. **Handling NULL values and Blank values** - Decide whether to delete, fill, or leave blank/null values as they are.

5. **Removing Unnecessary Rows and Columns** - Remove any rows or columns that are not needed.


### Phase 3: EDA

1. **Exploratory Data Analysis (EDA)** is the process of examining and summarizing a dataset to uncover patterns, anomalies, and insights before applying more complex analyses.

---
<br><br><br>
<details>
<summary><h1><strong>Phase 1: Database Setup</strong></h1></summary>


### 1. Creating the Database

``` sql 
CREATE DATABASE World_Layoffs;
```

### 2. Creating the Table

``` sql 
-- Create layoffs table 
CREATE TABLE public.layoffs_original
(
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off NUMERIC,
    date TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions NUMERIC
);


-- Set ownership of the tables to the postgres user
ALTER TABLE public.layoffs_original OWNER to postgres;
```

### 3. Loading the Data


- In PostgresSQL > PgAdmin4 > PSQL Tool, using these commands to insert data from csv files to database
``` sql 
\copy layoffs FROM 'D:\SQL\LayOffs\Files\layoffs.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8', NULL 'NULL');
```


</details>

<br><br><br>
<details>
<summary><h1><strong>Phase 2: Data Cleaning</strong></h1></summary>


### 1. Copying the Original Table
- It is advisable to make changes to a copy of the table rather than the original


``` sql 
CREATE TABLE layoffs(
    LIKE layoffs_raw);


INSERT INTO layoffs(
    SELECT * FROM layoffs_raw);
```


### 2. Removing Duplicates

**Identifying Duplicates** 
- First, identify duplicates by assigning a row number to each row based on key columns

``` sql
SELECT * ,
ROW_NUMBER () OVER (PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,stage, country, funds_raised_millions ) as ROW_NUM
FROM layoffs;
```


<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| company          | location        | industry   | total_laid_off | percentage_laid_off | date       | stage     | country        | funds_raised_millions | row_num |
|------------------|------------------|------------|----------------|---------------------|------------|-----------|----------------|-----------------------|---------|
| E Inc.           | Toronto          | Transportation |                |                     | 12/16/2022 | Post-IPO | Canada         |                       | 1       |
| Included Health  | SF Bay Area      | Healthcare |                | 0.06                | 7/25/2022  | Series E  | United States  | 272                   | 1       |
| #Paid            | Toronto          | Marketing  | 19             | 0.17                | 1/27/2023  | Series B  | Canada         | 21                    | 1       |
| &Open            | Dublin           | Marketing  | 9              | 0.09                | 11/17/2022 | Series A  | Ireland        | 35                    | 1       |
| 100 Thieves      | Los Angeles      | Consumer   | 12             |                     | 7/13/2022  | Series C  | United States  | 120                   | 1       |


</details>


- Filter the duplicate rows

``` sql
SELECT * FROM (
    SELECT * ,
    ROW_NUMBER () OVER (PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,stage, country, funds_raised_millions ) as ROW_NUM
    FROM layoffs) AS duplicate
WHERE row_num > 1;
```




<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>


| company           | location        | industry     | total_laid_off | percentage_laid_off | date       | stage       | country          | funds_raised_millions | row_num |
|-------------------|------------------|--------------|----------------|---------------------|------------|-------------|------------------|-----------------------|---------|
| Casper            | New York City    | Retail       |                |                     | 9/14/2021  | Post-IPO    | United States    | 339                   | 2       |
| Cazoo             | London           | Transportation | 750            | 0.15                | 6/7/2022   | Post-IPO    | United Kingdom   | 2000                  | 2       |
| Hibob             | Tel Aviv         | HR           | 70             | 0.3                 | 3/30/2020  | Series A    | Israel           | 45                    | 2       |
| Wildlife Studios  | Sao Paulo        | Consumer     | 300            | 0.2                 | 11/28/2022 | Unknown     | Brazil           | 260                   | 2       |
| Yahoo             | SF Bay Area      | Consumer     | 1600           | 0.2                 | 2/9/2023   | Acquired    | United States    | 6                     | 2       |



</details>

**Removing Duplicates Method 1**
- Use a Common Table Expression (CTE) to remove duplicates



``` sql
WITH cte AS (
    SELECT ctid,company,row_num
    FROM (
        SELECT ctid,company,
               ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
        FROM layoffs
    ) AS duplicate
    WHERE row_num > 1
)
DELETE 
FROM layoffs
WHERE ctid IN (SELECT ctid FROM cte);
```



<details>
<summary><strong>Removing Duplicates Method 2</strong></summary>

- Alternatively, create a new table with row_number as added column

``` sql 
ALTER TABLE layoffs ADD row_num INT;

SELECT *
FROM layoffs;

CREATE TABLE layoffs2 (
company text,
location text,
industry text,
total_laid_off INT,
percentage_laid_off text,
date text,
stage text,
country text,
funds_raised_millions int,
row_num INT
);

INSERT INTO layoffs2
(company,
location,
industry,
total_laid_off,
percentage_laid_off,
date,
stage,
country,
funds_raised_millions,
row_num)
SELECT company,
location,
industry,
total_laid_off,
percentage_laid_off,
date,
stage,
country,
funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off, date, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs;
        
```

- Remove rows where row_num is greater than 1

```sql 
DELETE FROM layoffs2
WHERE row_num >= 1;
```




-  Check  for successful deletion of duplicates

``` sql
SELECT * FROM (
    SELECT * ,
    ROW_NUMBER () OVER (PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,stage, country, funds_raised_millions ) as ROW_NUM
    FROM layoffs) AS duplicate
WHERE row_num > 1;
```

- Empty results must appear

</details>

###  3. Standardizing Data

After a thorough review of the data column by column, it was determined that data cleaning is necessary for some columns

1. **Industry Column**
   - **Problem 1:** NULL values and potential blanks
   - *solution* : Fill those NULL values and blanks
   - **Problem 2:** Variations in "Crypto" entries
   - *solution* : Change values that start with 'Crypto' to 'Crypto'


2. **Country Column**
   - **Problem 1:** Variations like "United States" and "United States." (with a period)
   - *solution* : Remove '.'

3. **Percentage_laid_off Column**
   - **Problem 1:** Values are stored as strings.
   - *solution* : Convert values and column type to NUMERIC

4. **Date Column**
   - **Problem 1:** Dates are stored as strings.
   - *solution* : Convert values and column type to DATE format

**1. Cleaning the `industry` Column**

*Problem 1:* NULL values and potential Blanks

*solution* : Fill those NULL values and Blanks

- Take a look at the  distinct industries
``` sql 
SELECT DISTINCT(industry)
FROM layoffs
ORDER BY 1;
```



<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| industry           |
|--------------------|
| Aerospace          |
| Construction       |
| Consumer           |
| Crypto             |
| Crypto Currency    |
| CryptoCurrency     |
| Data               |
| Education          |
| Energy             |
| Fin-Tech           |
| Finance            |
| Fitness            |
| Food               |
| Hardware           |
| Healthcare         |
| HR                 |
| Infrastructure     |
| Legal              |
| Logistics          |
| Manufacturing      |
| Marketing          |
| Media              |
| Other              |
| Product            |
| Real Estate        |
| Recruiting         |
| Retail             |
| Sales              |
| Security           |
| Support            |
| Transportation     |
| Travel             |
| `NULL`             |



</details>

- Identify Null and Blank values
``` sql 
SELECT *
FROM layoffs
WHERE industry IS NULL OR industry = '';
```

<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| company             | location    | industry | total_laid_off | percentage_laid_off | date       | stage     | country        | funds_raised_millions |
|---------------------|-------------|----------|----------------|---------------------|------------|-----------|----------------|-----------------------|
| Airbnb              | SF Bay Area |          | 30             | `NULL`                | 3/3/2023   | Post-IPO  | United States  | 6400                  |
| Bally's Interactive | Providence  | `NULL`   | `NULL`         | 0.15                | 1/18/2023  | Post-IPO  | United States  | 946                   |
| Juul                | SF Bay Area |          | 400            | 0.3                 | 11/10/2022 | Unknown   | United States  | 1500                  |
| Carvana             | Phoenix     |          | 2500           | 0.12                | 5/10/2022  | Post-IPO  | United States  | 1600                  |


</details>

- Identify details of company startig with Bally

``` sql 
SELECT *
FROM layoffs
WHERE company Like 'Bally%';
```


<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| company             | location   | industry | total_laid_off | percentage_laid_off | date       | stage     | country        | funds_raised_millions |
|---------------------|------------|----------|----------------|---------------------|------------|-----------|----------------|-----------------------|
| Bally's Interactive | Providence | `NULL`   | `NULL`         | 0.15                | 1/18/2023  | Post-IPO  | United States  | 946                   |


</details>

###### Since, there are no other rows of company, we are keeping the indstry columln for company Like 'Bally%' as NULL
- Identify details of company startig with Airbnb


``` sql 
SELECT *
FROM layoffs
WHERE company like 'Airbnb%';
```


<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| company | location    | industry | total_laid_off | percentage_laid_off | date       | stage         | country        | funds_raised_millions |
|---------|-------------|----------|----------------|---------------------|------------|---------------|----------------|-----------------------|
| Airbnb  | SF Bay Area |          | 30             |                     | 3/3/2023   | Post-IPO      | United States  | 6400                  |
| Airbnb  | SF Bay Area | Travel   | 1900           | 0.25                | 5/5/2020   | Private Equity | United States  | 5400                  |


</details>

###### The Airbnb entry is intended for travel but lacks population.
###### Similar issues are likely with other entries.
###### Write a query to update duplicates with non-null industry values.
###### This approach will handle large datasets efficiently without manual checks.
- Set the Blanks to NULLS, as they are easier to work with

``` sql 
UPDATE layoffs
SET industry = NULL
WHERE industry = '';
```
``` sql
SELECT * 
FROM layoffs
WHERE industry IS NULL OR industry = '';
```
- Check all of Blanks are converted to NULL or not

<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| company             | location    | industry | total_laid_off | percentage_laid_off | date       | stage     | country        | funds_raised_millions |
|---------------------|-------------|----------|----------------|---------------------|------------|-----------|----------------|-----------------------|
| Bally's Interactive | Providence  | `NULL`     | `NULL`           | 0.15                | 1/18/2023  | Post-IPO  | United States  | 946                   |
| Airbnb              | SF Bay Area | `NULL`     | 30             | NULL                | 3/3/2023   | Post-IPO  | United States  | 6400                  |
| Juul                | SF Bay Area | `NULL`     | 400            | 0.3                 | 11/10/2022 | Unknown   | United States  | 1500                  |
| Carvana             | Phoenix     | `NULL`     | 2500           | 0.12                | 5/10/2022  | Post-IPO  | United States  | 1600                  |


</details>


- Fill NULL values based on other rows with the same company

``` sql
UPDATE layoffs AS table_1
SET industry = table_2.industry
FROM layoffs AS table_2
WHERE table_1.company = table_2.company
  AND table_1.industry IS NULL
  AND table_2.industry IS NOT NULL;
  ```
- Check for successful replacement of NULL values


``` sql
SELECT *
FROM layoffs
WHERE company like 'Airbnb%';
```


<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>


| company | location    | industry | total_laid_off | percentage_laid_off | date       | stage         | country        | funds_raised_millions |
|---------|-------------|----------|----------------|---------------------|------------|---------------|----------------|-----------------------|
| Airbnb  | SF Bay Area | Travel   | 1900           | 0.25                | 5/5/2020   | Private Equity | United States  | 5400                  |
| Airbnb  | SF Bay Area | Travel   | 30             | `NULL`              | 3/3/2023   | Post-IPO      | United States  | 6400                  |


</details>

*Problem 2:* Variations in "Crypto" entries

*solution* : Change values that start with 'Crypto' to 'Crypto'

- Identifying details of industry that starts with Crypto

``` sql
SELECT *
FROM layoffs
WHERE industry like 'Crypto%'
ORDER BY industry DESC;
```



<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| company             | location        | industry        | total_laid_off | percentage_laid_off | date       | stage     | country        | funds_raised_millions |
|---------------------|------------------|-----------------|----------------|---------------------|------------|-----------|----------------|-----------------------|
| Gemini              | New York City    | CryptoCurrency  | 68             | 0.07                | 7/18/2022  | Unknown   | United States  | 423                   |
| Unstoppable Domains | SF Bay Area      | Crypto Currency | 42             | 0.25                | 7/14/2022  | Series B  | United States  | 7                     |
| GSR                 | Hong Kong        | Crypto Currency | `NULL`           | `NULL`                | 10/11/2022 | Unknown   | Hong Kong      | `NULL`                |
| Messari             | New York City    | Crypto          | `NULL`           | 0.15                | 2/23/2023  | Series B  | United States  | 61                    |
| Polygon             | Bengaluru        | Crypto          | 100            | 0.2                 | 2/21/2023  | Unknown   | India          | 451                   |



</details>

- Change values that start with 'Crypto' to 'Crypto'

``` sql
UPDATE layoffs
SET industry = 'Crypto'
WHERE industry like 'Crypto%';
```

###### All the elements starting with Crypto now will be remaned as "Crypto"
##### 2. Cleaning `Country` Column 
*Problem 1:* Variations like "United States" and "United States." (with a period)

*solution* : Remove '.'
- Take a look at the distinct countries

``` sql
SELECT DISTINCT(country) 
FROM layoffs
ORDER BY 1;
```


<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| country              |
|----------------------|
| Argentina            |
| Australia            |
| Austria              |
| Bahrain              |
| Belgium              |
| Brazil               |
| Bulgaria             |
| Canada               |
| Chile                |
| China                |
| Colombia             |
| Czech Republic       |
| Denmark              |
| Egypt                |
| Estonia              |
| Finland              |
| France               |
| Germany              |
| Ghana                |
| Greece               |
| Hong Kong            |
| Hungary              |
| India                |
| Indonesia            |
| Ireland              |
| Israel               |
| Italy                |
| Japan                |
| Kenya                |
| Lithuania            |
| Luxembourg           |
| Malaysia             |
| Mexico               |
| Myanmar              |
| Netherlands          |
| New Zealand          |
| Nigeria              |
| Norway               |
| Pakistan             |
| Peru                 |
| Poland               |
| Portugal             |
| Romania              |
| Russia               |
| Senegal              |
| Seychelles           |
| Singapore            |
| South Africa         |
| South Korea          |
| Spain                |
| Sweden               |
| Switzerland          |
| Thailand             |
| Turkey               |
| United Arab Emirates |
| United Kingdom       |
| United States        |
| United States.       |
| Uruguay              |
| Vietnam              |


</details>

- Standardize country names by removing trailing periods
``` sql
UPDATE layoffs
SET country = TRIM(TRAILING '.' FROM country);
```
- Run the code again to see if it is fixed

```sql
SELECT DISTINCT(country) 
FROM layoffs
ORDER BY 1;
```

<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| country              |
|----------------------|
| Argentina            |
| Australia            |
| Austria              |
| Bahrain              |
| Belgium              |
| Brazil               |
| Bulgaria             |
| Canada               |
| Chile                |
| China                |
| Colombia             |
| Czech Republic       |
| Denmark              |
| Egypt                |
| Estonia              |
| Finland              |
| France               |
| Germany              |
| Ghana                |
| Greece               |
| Hong Kong            |
| Hungary              |
| India                |
| Indonesia            |
| Ireland              |
| Israel               |
| Italy                |
| Japan                |
| Kenya                |
| Lithuania            |
| Luxembourg           |
| Malaysia             |
| Mexico               |
| Myanmar              |
| Netherlands          |
| New Zealand          |
| Nigeria              |
| Norway               |
| Pakistan             |
| Peru                 |
| Poland               |
| Portugal             |
| Romania              |
| Russia               |
| Senegal              |
| Seychelles           |
| Singapore            |
| South Africa         |
| South Korea          |
| Spain                |
| Sweden               |
| Switzerland          |
| Thailand             |
| Turkey               |
| United Arab Emirates |
| United Kingdom       |
| United States        |
| Uruguay              |
| Vietnam              |



</details>

##### 4 Cleaning `Percentage_laid_off` column
*Problem 1:* Values are stored as strings.

*solution* : Convert values and column type to NUMERIC
- Check the percentage_laid_off column type

``` sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'layoffs'
  AND column_name = 'percentage_laid_off';
```

<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| column_name | data_type |
|-------------|-----------|
| percentage_laid_off| text      |


</details>


- Convert the column type to NUMERIC

``` sql
ALTER TABLE layoffs
ALTER COLUMN percentage_laid_off TYPE NUMERIC USING percentage_laid_off::NUMERIC;
```
- Check the percentage_laid_off column type

``` sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'layoffs'
  AND column_name = 'percentage_laid_off';
```

<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| column_name | data_type |
|-------------|-----------|
| percentage_laid_off| numeric      |


</details>


##### 3 Cleaning `Date` column
**Problem 1:** Dates are stored as strings.

*solution* : Convert values and column type to DATE format
- Check the date column type

``` sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'layoffs'
  AND column_name = 'date';
```

<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| column_name | data_type |
|-------------|-----------|
| date        | text      |


</details>


- Convert the date column from string format to DATE

``` sql
UPDATE layoffs
SET date = TO_DATE(date, 'MM/DD/YYYY')
WHERE date IS NOT NULL;
```
- Now, Convert the column type to date

``` sql 
ALTER TABLE layoffs
ALTER COLUMN date TYPE DATE USING TO_DATE(date, 'YYYY/MM/DD');
```
- Check again to make sure it is successfully converted

``` sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'layoffs'
  AND column_name = 'date';
```


<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| column_name | data_type |
|-------------|-----------|
| date        | date      |



</details>

##### 4. Handling Null Values
- Leave null values in total_laid_off, percentage_laid_off, and funds_raised_millions columns, as they may be useful for calculations during EDA.
##### 5. Removing Unnecessary Rows and Columns

- Take a look at the NULL values in Total laid off and Percentage laid off


``` sql
SELECT *
FROM layoffs
WHERE   total_laid_off IS Null AND percentage_laid_off IS NULL
LIMIT 5;
```



<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>

| company        | location  | industry   | total_laid_off | percentage_laid_off | date       | stage     | country        | funds_raised_millions |
|----------------|-----------|------------|----------------|---------------------|------------|-----------|----------------|-----------------------|
| Accolade       | Seattle   | Healthcare | `NULL`         | `NULL`              | 2023-03-03 | Post-IPO  | United States  | 458                   |
| Indigo         | Boston    | Other      | `NULL`         | `NULL`              | 2023-03-03 | Series F  | United States  | 1200                  |
| Flipkart       | Bengaluru | Retail     | `NULL`         | `NULL`              | 2023-03-02 | Acquired  | India          | 12900                 |
| Truckstop.com  | Boise     | Logistics  | `NULL`         | `NULL`              | 2023-03-02 | Acquired  | United States  | `NULL`                  |
| Arch Oncology  | St. Louis | Healthcare | `NULL`         | `NULL`              | 2023-02-22 | Series C  | United States  | 155                   |



</details>

###### As these rows of data are unnecessary for the analysis. Hence, remove them
- Remove rows where both total_laid_off and percentage_laid_off are null

``` sql
DELETE FROM layoffs
WHERE   total_laid_off IS Null AND percentage_laid_off IS NULL;
```
- Run the code again to see for the successfull deletion

``` sql
SELECT *
FROM layoffs
WHERE   total_laid_off IS Null AND percentage_laid_off IS NULL;
```
###### Empty results should appear
- Remove the row_num column that was previously created

``` sql
ALTER TABLE layoffs
DROP COLUMN row_num;
```
#### Data Ready for EDA


``` sql
SELECT *
FROM layoffs
ORDER BY RANDOM ()
LIMIT 5;
```


<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>


| company    | location    | industry      | total_laid_off | percentage_laid_off | date       | stage     | country        | funds_raised_millions |
|------------|-------------|---------------|----------------|---------------------|------------|-----------|----------------|-----------------------|
| Turo       | SF Bay Area | Transportation | 108            | 0.3                 | 2020-03-31 | Series E  | United States  | 467                   |
| Cybereason | Boston      | Security       | 200            | 0.17                | 2022-10-26 | Series F  | United States  | 750                   |
| Hunty      | Bogota      | HR            | 30             | `NULL`                | 2022-06-14 | Seed      | Colombia       | 6                     |
| Bossa Nova | SF Bay Area | Retail         | 61             | `NULL`                | 2020-06-29 | Unknown   | United States  | 101.6                 |
| B8ta       | SF Bay Area | Retail         | 250            | 0.5                 | 2020-03-26 | Series C  | United States  | 88                    |



</details>

</details>

<br><br><br>
<details>
<summary><h1><strong>Phase 3: EDA</strong></h1></summary>


### 1. Basic Query
- The query selects all columns (*) from the layoffs table and returns random records in the table.

``` sql
SELECT *
FROM layoffs
ORDER BY RANDOM()
LIMIT 5;
```


<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>


| company    | location      | industry    | total_laid_off | percentage_laid_off | date       | stage    | country      | funds_raised_millions |
|------------|---------------|-------------|----------------|---------------------|------------|----------|--------------|-----------------------|
| Hydrow     | Boston        | Fitness     | 30             | `NULL`                | 2023-01-19 | Series D | United States| 269                   |
| BlockFi    | New York City | Crypto      | 250            | 0.2                 | 2022-06-13 | Series E | United States| 1000                  |
| Ada        | Toronto       | Support     | 78             | 0.16                | 2022-09-20 | Series C | Canada       | 190                   |
| Bridgit    | Waterloo      | Construction| 13             | 0.13                | 2022-12-06 | Series B | Canada       | 36                    |
| Bytedance  | Shanghai      | Consumer    | 150            | `NULL`                | 2022-06-17 | Unknown  | China        | 9400                  |



</details>



<details>
<summary><h4><strong>Click to view Insights</strong></h4></summary>


**Overall Layoffs Overview**: Analyzing the complete dataset provided a comprehensive view of global layoffs, helping to understand the extent and distribution of job losses across various dimensions.


</details>


### 2. Finding Maximum Values

- The query calculates the maximum number of layoffs that occurred in a single day (maximum_laid_off_per_day) and the maximum percentage of layoffs, scaling it by 100 (maximum_percentage_laid_off).




``` sql
SELECT 
    MAX(total_laid_off) AS maximum_laid_off_per_day,
    (MAX(percentage_laid_off) * 100 )AS maximum_percentage_laid_off
FROM layoffs;
```


<details>
<summary><h4><strong>Click to view Results</strong></h4></summary>


| maximum_laid_off_per_day | maximum_percentage_laid_off |
|--------------------------|-----------------------------|
| 12000                    | 100                         |


</details>




<details>
<summary><h4><strong>Click to view Insights</strong></h4></summary>


**Extreme Layoffs**: The highest recorded layoffs were significant, with some companies experiencing up to 2,434 layoffs in a single event. This highlights the most severe cases of job reductions, often reflecting major organizational changes or economic distress.


</details>



### 3. Filtering by Maximum Percentage Laid Off

- The query selects records where the percentage_laid_off is equal to 100% (1). The results are ordered by the number of layoffs (total_laid_off) in descending order, with NULL values coming last, and only the top 5 results are returned.

``` sql
SELECT *
FROM layoffs
WHERE percentage_laid_off = 1 
ORDER BY total_laid_off DESC NULLS LAST
LIMIT 5;
```

<details>
<summary><h4><strong>Click to view Results </strong></h4></summary>


| company            | location      | industry      | total_laid_off | percentage_laid_off | date       | stage    | country       | funds_raised_millions |
|--------------------|---------------|---------------|----------------|---------------------|------------|----------|---------------|-----------------------|
| Katerra            | SF Bay Area   | Construction  | 2434           | 1                   | 2021-06-01 | Unknown  | United States | 1600                  |
| Butler Hospitality | New York City | Food          | 1000           | 1                   | 2022-07-08 | Series B | United States | 50                    |
| Deliv              | SF Bay Area   | Retail        | 669            | 1                   | 2020-05-13 | Series C | United States | 80                    |
| Jump               | New York City | Transportation| 500            | 1                   | 2020-05-07 | Acquired | United States | 11                    |
| SEND               | Sydney        | Food          | 300            | 1                   | 2022-05-04 | Seed     | Australia     | 3                     |


</details>



<details>
<summary><h4><strong>Click to view  Insights</strong></h4></summary>


**Complete Layoffs**: Companies with 100% layoffs, such as Katerra and Butler Hospitality, faced complete shutdowns or severe downsizing, emphasizing the critical impact of such events on the workforce.


</details>

### 4. Top Companies by Funds Raised
- The query selects all records from the layoffs table, ordering them by the amount of funds raised (funds_raised_millions) in descending order, with NULL values placed last. It returns the top 5 records.
``` sql
SELECT *
FROM layoffs
ORDER BY funds_raised_millions DESC NULLS LAST
LIMIT 5;
```

<details>
<summary><h4><strong>Click to view Results </strong></h4></summary>


| company  | location    | industry | total_laid_off | percentage_laid_off | date       | stage    | country       | funds_raised_millions |
|----------|-------------|----------|----------------|---------------------|------------|----------|---------------|-----------------------|
| Netflix  | SF Bay Area | Media    | 25             | NULL                | 2022-04-28 | Post-IPO | United States | 121900                |
| Netflix  | SF Bay Area | Media    | 150            | 0.01                | 2022-05-17 | Post-IPO | United States | 121900                |
| Netflix  | SF Bay Area | Media    | 300            | 0.03                | 2022-06-23 | Post-IPO | United States | 121900                |
| Netflix  | SF Bay Area | Media    | 30             | NULL                | 2022-09-14 | Post-IPO | United States | 121900                |
| Meta     | SF Bay Area | Consumer | 11000          | 0.13                | 2022-11-09 | Post-IPO | United States | 26000                 |



</details>



<details>
<summary><h4><strong>Click to view  Insights</strong></h4></summary>


**Fundraising vs. Layoffs**: Companies with substantial funds raised, like Katerra with $1.6 billion, still experienced significant layoffs. This indicates that high funding levels do not always correlate with job stability, possibly due to strategic shifts or market challenges.


</details>


### 5. Top Companies by Total Layoffs

- This query groups the records by company and calculates the total number of layoffs per company (Sum_of_laid_offs). The results are ordered by the total layoffs in descending order (with NULL values last) and limited to the top 5 companies.
``` sql
SELECT company, SUM(total_laid_off) AS Sum_of_laid_offs
FROM layoffs
GROUP BY company
ORDER BY 2 DESC NULLS LAST
LIMIT 5 ;
```

<details>
<summary><h4><strong>Click to view Results </strong></h4></summary>


| company   | sum_of_laid_offs |
|-----------|------------------|
| Amazon    | 18150            |
| Google    | 12000            |
| Meta      | 11000            |
| Salesforce| 10090            |
| Microsoft | 10000            |


</details>


<details>
<summary><h4><strong>Click to view  Insights</strong></h4></summary>


**Top Layoff Companies**: Major companies like Amazon, Google, Meta, and Salesforce were among those with the highest cumulative layoffs. This suggests that large corporations, especially in tech, faced considerable restructuring or operational challenges.


</details>


### 6. Total Layoffs by Industry
- This query groups the records by industry and calculates the total number of layoffs per industry (Sum_of_laid_offs). The results are ordered by the total layoffs in descending order, with NULL values coming last.
``` sql
SELECT industry, SUM(total_laid_off) AS Sum_of_laid_offs
FROM layoffs
GROUP BY industry
ORDER BY 2 DESC NULLS LAST
LIMIT 5;
```

<details>
<summary><h4><strong>Click to view Results </strong></h4></summary>

| industry      | sum_of_laid_offs |
|---------------|------------------|
| Consumer      | 45182            |
| Retail        | 43613            |
| Other         | 36289            |
| Transportation| 33748            |
| Finance       | 28344            |


</details>



<details>
<summary><h4><strong>Click to view  Insights</strong></h4></summary>


**Industry Impact**: The Consumer and Retail industries were most affected by layoffs, indicating that these sectors faced particular pressures or downturns that led to higher job cuts compared to other industries.


</details>


### 7. Total Layoffs by Year

- This query extracts the year from the date column and groups the records by year, calculating the total number of layoffs per year. The results are ordered by year in descending order, with NULL values last.
``` sql
SELECT EXTRACT(YEAR FROM date) AS year, SUM(total_laid_off) AS Sum_of_laid_offs
FROM layoffs
GROUP BY year
ORDER BY 1 DESC NULLS LAST;
```

<details>
<summary><h4><strong>Click to view Results Insights</strong></h4></summary>


| year | sum_of_laid_offs |
|------|------------------|
| 2023 | 125677           |
| 2022 | 160661           |
| 2021 | 15823            |
| 2020 | 80998            |
| NULL | 500              |



</details>


<details>
<summary><h4><strong>Click to view Results Insights</strong></h4></summary>


**Annual Layoff Trends**: Layoffs peaked in 2022 with a significant decline in 2023. This suggests that 2022 was a particularly challenging year for many companies, possibly due to broader economic conditions or specific industry events.


</details>

### 8. Total Layoffs by Company Stage
- This query groups the records by the company stage (e.g., startup, growth) and calculates the total number of layoffs per stage. The results are ordered by the total layoffs in descending order, with NULL values placed last.

``` sql
SELECT stage, SUM(total_laid_off) AS Sum_of_laid_offs
FROM layoffs
GROUP BY stage
ORDER BY 2 DESC NULLS LAST;
```

<details>
<summary><h4><strong>Click to view Results </strong></h4></summary>


| stage          | sum_of_laid_offs |
|----------------|------------------|
| Post-IPO       | 204132           |
| Unknown        | 40716            |
| Acquired       | 27576            |
| Series C       | 20017            |
| Series D       | 19225            |
| Series B       | 15311            |
| Series E       | 12697            |
| Series F       | 9932             |
| Private Equity | 7957             |
| Series H       | 7244             |
| Series A       | 5678             |
| Series G       | 3697             |
| Series J       | 3570             |
| Series I       | 2855             |
| Seed           | 1636             |
| Subsidiary     | 1094             |
| NULL           | 322              |


</details>


<details>
<summary><h4><strong>Click to view  Insights</strong></h4></summary>

 **Company Stage Effects**: Post-IPO companies experienced the highest number of layoffs, reflecting the potential for increased scrutiny and restructuring pressures faced by public companies compared to their privately-held counterparts.

 
</details>

### 9. Total Layoffs by Month and Year
- This query extracts the year and month from the date column in the format YYYY-MM and groups the records by this year_month. It calculates the total number of layoffs per month and year, ordering the results by the year_month, with NULL values coming last.

``` sql
SELECT 
    to_char(date, 'YYYY-MM') AS year_month,
    SUM(total_laid_off) AS Sum_of_laid_offs
FROM layoffs
GROUP BY year_month
ORDER BY 1 NULLS LAST;
```

<details>
<summary><h4><strong>Click to view Results </strong></h4></summary>


| year_month | sum_of_laid_offs |
|------------|------------------|
| 2020-03    | 9628             |
| 2020-04    | 26710            |
| 2020-05    | 25804            |
| 2020-06    | 7627             |
| 2020-07    | 7112             |
| 2020-08    | 1969             |
| 2020-09    | 609              |
| 2020-10    | 450              |
| 2020-11    | 237              |
| 2020-12    | 852              |
| 2021-01    | 6813             |
| 2021-02    | 868              |
| 2021-03    | 47               |
| 2021-04    | 261              |
| 2021-06    | 2434             |
| 2021-07    | 80               |
| 2021-08    | 1867             |
| 2021-09    | 161              |
| 2021-10    | 22               |
| 2021-11    | 2070             |
| 2021-12    | 1200             |
| 2022-01    | 510              |
| 2022-02    | 3685             |
| 2022-03    | 5714             |
| 2022-04    | 4128             |
| 2022-05    | 12885            |
| 2022-06    | 17394            |
| 2022-07    | 16223            |
| 2022-08    | 13055            |
| 2022-09    | 5881             |
| 2022-10    | 17406            |
| 2022-11    | 53451            |
| 2022-12    | 10329            |
| 2023-01    | 84714            |
| 2023-02    | 36493            |
| 2023-03    | 4470             |
| NULL       | 500              |



</details>


<details>
<summary><h4><strong>Click to view  Insights</strong></h4></summary>


**Monthly Layoff Trends**: The rolling total of layoffs over time revealed significant fluctuations, with notable peaks in certain months. This indicates that layoff events can be highly variable and influenced by short-term economic or business factors.


</details>

### 10. Rolling Total of Layoffs by Month

Explanation:

- Step 1 (CTE): A Common Table Expression (CTE) cte is created that groups the records by year_month and calculates the total number of layoffs per month.

- Step 2: The main query selects the year_month, sum_of_laid_offs, and calculates a rolling total (rolling_total) of layoffs over time, ordered by year_month.
``` sql

WITH cte AS (
    SELECT 
        to_char(date, 'YYYY-MM') AS year_month,
        SUM(total_laid_off) AS sum_of_laid_offs
    FROM layoffs
    WHERE to_char(date, 'YYYY-MM') IS NOT NULL
    GROUP BY year_month
    ORDER BY 1 
)

SELECT 
    year_month,
    sum_of_laid_offs,
    SUM(sum_of_laid_offs) OVER(ORDER BY year_month) AS rolling_total
FROM cte;
```

<details>
<summary><h4><strong>Click to view Results </strong></h4></summary>


| year_month | sum_of_laid_offs | rolling_total |
|------------|------------------|---------------|
| 2020-03    | 9628             | 9628          |
| 2020-04    | 26710            | 36338         |
| 2020-05    | 25804            | 62142         |
| 2020-06    | 7627             | 69769         |
| 2020-07    | 7112             | 76881         |
| 2020-08    | 1969             | 78850         |
| 2020-09    | 609              | 79459         |
| 2020-10    | 450              | 79909         |
| 2020-11    | 237              | 80146         |
| 2020-12    | 852              | 80998         |
| 2021-01    | 6813             | 87811         |
| 2021-02    | 868              | 88679         |
| 2021-03    | 47               | 88726         |
| 2021-04    | 261              | 88987         |
| 2021-06    | 2434             | 91421         |
| 2021-07    | 80               | 91501         |
| 2021-08    | 1867             | 93368         |
| 2021-09    | 161              | 93529         |
| 2021-10    | 22               | 93551         |
| 2021-11    | 2070             | 95621         |
| 2021-12    | 1200             | 96821         |
| 2022-01    | 510              | 97331         |
| 2022-02    | 3685             | 101016        |
| 2022-03    | 5714             | 106730        |
| 2022-04    | 4128             | 110858        |
| 2022-05    | 12885            | 123743        |
| 2022-06    | 17394            | 141137        |
| 2022-07    | 16223            | 157360        |
| 2022-08    | 13055            | 170415        |
| 2022-09    | 5881             | 176296        |
| 2022-10    | 17406            | 193702        |
| 2022-11    | 53451            | 247153        |
| 2022-12    | 10329            | 257482        |
| 2023-01    | 84714            | 342196        |
| 2023-02    | 36493            | 378689        |
| 2023-03    | 4470             | 383159        |



</details>


<details>
<summary><h4><strong>Click to view  Insights</strong></h4></summary>


**Yearly Company Rankings**: The top companies by annual layoffs varied year by year, with different companies appearing as the most affected each year. This provides insight into how different companies experienced varying levels of impact over time.


</details>


### 11. Top 5 Companies by Layoffs per Year

- Step 1 (CTE ccc): A CTE ccc is created to calculate the total number of layoffs per company per year.

- Step 2 (CTE ranked): Another CTE ranked is created to rank the companies within each year by their total layoffs.

- Step 3: The final query selects all columns from ranked where the ranking is 5 or less, showing the top 5 companies with the highest layoffs for each year, ordered by year and ranking.
``` sql

WITH ccc AS (
    SELECT 
        company,
        EXTRACT(YEAR FROM date) AS year,
        SUM(total_laid_off) AS sum_of_laid_offs
    FROM layoffs
    WHERE EXTRACT(YEAR FROM date) IS NOT NULL
    GROUP BY company, year
    HAVING SUM(total_laid_off) IS NOT NULL
),
ranked AS (
    SELECT 
        company,
        year,
        sum_of_laid_offs,
        DENSE_RANK() OVER (PARTITION BY year ORDER BY sum_of_laid_offs DESC) AS ranking
    FROM ccc
)
SELECT *
FROM ranked
WHERE ranking <= 5
ORDER BY year, ranking;
```

<details>
<summary><h4><strong>Click to view Results </strong></h4></summary>


| company        | year | sum_of_laid_offs | ranking |
|----------------|------|------------------|---------|
| Uber           | 2020 | 7525             | 1       |
| Booking.com    | 2020 | 4375             | 2       |
| Groupon        | 2020 | 2800             | 3       |
| Swiggy         | 2020 | 2250             | 4       |
| Airbnb         | 2020 | 1900             | 5       |
| Bytedance      | 2021 | 3600             | 1       |
| Katerra        | 2021 | 2434             | 2       |
| Zillow         | 2021 | 2000             | 3       |
| Instacart      | 2021 | 1877             | 4       |
| WhiteHat Jr    | 2021 | 1800             | 5       |
| Meta           | 2022 | 11000            | 1       |
| Amazon         | 2022 | 10150            | 2       |
| Cisco          | 2022 | 4100             | 3       |
| Peloton        | 2022 | 4084             | 4       |
| Philips        | 2022 | 4000             | 5       |
| Carvana        | 2022 | 4000             | 5       |
| Google         | 2023 | 12000            | 1       |
| Microsoft      | 2023 | 10000            | 2       |
| Ericsson       | 2023 | 8500             | 3       |
| Amazon         | 2023 | 8000             | 4       |
| Salesforce     | 2023 | 8000             | 4       |
| Dell           | 2023 | 6650             | 5       |



</details>



<details>
<summary><h4><strong>Click to view  Insights</strong></h4></summary>


**Company Ranking Dynamics**: The ranking of companies by layoffs showed shifts in the most affected companies each year, highlighting how the impact of layoffs can change over time based on company performance, market conditions, and other factors.


</details>


</details>

<br><br><br>
---
# Overall Insights

1. **Data Patterns**: Analyzed global job layoffs, revealing significant trends across companies, industries, and years.

2. **Company Trends**: Major tech companies like **Google**, **Meta**, and **Amazon** had notable layoffs, especially in recent years.

3. **Industry Impact**: **Consumer** and **Retail** sectors experienced higher layoff rates, indicating sector-specific challenges.

4. **Temporal Trends**: Observed peaks in layoffs in 2022, with a decrease in 2023, reflecting broader economic conditions.

5. **Funding vs. Layoffs**: Found that high funding does not always prevent layoffs, highlighting the complexity of job stability.

6. **Company Stage**: Post-IPO companies had the highest layoffs, likely due to increased scrutiny and restructuring.

7. **Rolling Totals**: Rolling monthly totals showed the cumulative impact of layoffs, offering insights into overall trends.

8. **Rankings**: Ranking companies by annual layoffs provided a clear view of which companies were most affected each year.

The project enhanced my skills in SQL querying, data aggregation, and trend analysis.

# What I Learned

### Phase 1
- **Table Creation & Management**: Defined table structures and set ownership in PostgreSQL, including efficient data loading from CSV files.

### Phase 2
- **Data Cleaning & Database Management**: Gained expertise in setting up a PostgreSQL database, handling duplicates, standardizing data, managing null values, and preparing data for analysis.
- **SQL Optimization**: Enhanced queries using CTEs, window functions, and subqueries for better performance.
- **Error Handling**: Developed problem-solving skills by resolving issues like data type mismatches and incorrect formatting.

### Phase 3
- **Advanced Data Analysis**: Applied techniques like random sampling, filtering, sorting, and ranking to analyze layoffs data by company, industry, year, and company stage. Also calculated rolling totals and identified key trends.

# Conclusion

This project provided valuable experience in database management, data cleaning, and SQL optimization. Key learnings include:

1. **Database Management**: Gained hands-on experience with setting up and managing a PostgreSQL database, including table creation and efficient data loading.
2. **Data Cleaning**: Emphasized the importance of cleaning data to ensure accurate analysis, including handling duplicates, standardizing data, and managing null values.
3. **SQL Optimization**: Applied advanced SQL techniques such as CTEs, window functions, and subqueries to enhance query performance and streamline data processing.
4. **Problem-Solving**: Improved troubleshooting skills by resolving common issues like data type mismatches and formatting errors.
5. **Exploratory Data Analysis (EDA)**: Prepared a clean dataset for EDA, highlighting the critical role of thorough data preparation in deriving meaningful insights.

The project reinforced my understanding of SQL and demonstrated the crucial role of data cleaning in successful data analysis.

# END
---