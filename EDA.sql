1

SELECT *
FROM layoffs
ORDER BY RANDOM()
LIMIT 5;


2

SELECT 
    MAX(total_laid_off) AS maximum_laid_off_per_day,
    (MAX(percentage_laid_off) * 100 )AS maximum_percentage_laid_off
FROM layoffs;

3

SELECT *
FROM layoffs
WHERE percentage_laid_off = 1 
ORDER BY total_laid_off DESC NULLS LAST
LIMIT 5;

4

SELECT *
FROM layoffs
ORDER BY funds_raised_millions DESC NULLS LAST
LIMIT 5;

5

SELECT company, SUM(total_laid_off) AS Sum_of_laid_offs
FROM layoffs
GROUP BY company
ORDER BY 2 DESC NULLS LAST
LIMIT 5 ;

6

SELECT industry, SUM(total_laid_off) AS Sum_of_laid_offs
FROM layoffs
GROUP BY industry
ORDER BY 2 DESC NULLS LAST
LIMIT 5;

7

SELECT EXTRACT(YEAR FROM date) AS year, SUM(total_laid_off) AS Sum_of_laid_offs
FROM layoffs
GROUP BY year
ORDER BY 1 DESC NULLS LAST;

8

SELECT stage, SUM(total_laid_off) AS Sum_of_laid_offs
FROM layoffs
GROUP BY stage
ORDER BY 2 DESC NULLS LAST;


9


SELECT 
    to_char(date, 'YYYY-MM') AS year_month,
    SUM(total_laid_off) AS Sum_of_laid_offs
FROM layoffs
GROUP BY year_month
ORDER BY 1 NULLS LAST;

10

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


11

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
