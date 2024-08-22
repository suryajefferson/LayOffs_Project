-- checking for duplicate values

-- adding a row number column Where it assigins row number as 1 for unique row
SELECT * ,
ROW_NUMBER () OVER (PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,stage, country, funds_raised_millions ) as ROW_NUM
FROM layoffs
LIMIT 5;

-- adding above code as a subquery and filtering where row_num > 1 to show the duplicate values
SELECT * FROM (
    SELECT * ,
    ROW_NUMBER () OVER (PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,stage, country, funds_raised_millions ) as ROW_NUM
    FROM layoffs) AS duplicate
WHERE row_num > 1;


Method 1 
-- adding above code as a CTE and using ctid  and deleting duplicates
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


Method 2


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
		layoffs;

-- now that we have this we can delete rows were row_num is greater than 2

DELETE FROM world_layoffs.layoffs2
WHERE row_num >= 2;


--  check  for successfull deletion of duplicates
SELECT * FROM (
    SELECT * ,
    ROW_NUMBER () OVER (PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,stage, country, funds_raised_millions ) as ROW_NUM
    FROM layoffs) AS duplicate
WHERE row_num > 1;



2 standardize data

By observing the data column by column we have found that it is required to clean the data
1 industry column
    prob 1 : we observe that there are NULL values and also might be blanks
    prob 2 : we observe that Crypto has several variations
2 country column
    prob 1 :  we have some "United States" and some "United States." with a period at the end
2 date column
    prob 1 : the date date column is in string format


1 industry column
-- we are taking a look at the industry column
SELECT DISTINCT(industry)
FROM layoffs
ORDER BY 1;

-- prob 1 : we observe that there are NULL values and also might be blanks
-- solution : we need to fill those NULL values and blanks
-- prob 2 : we observe that Crypto has several variations
-- solution: we need only one variation, let's say Crypto

-- solution for prob 1 :  we need to fill those NULL values and blanks

-- checking Null and blank values
SELECT *
FROM layoffs
WHERE industry IS NULL OR industry =
-- since there are no other rows of company, we are keeping the indstry columln as NULL

SELECT *
FROM layoffs
WHERE company like 'Airbnb%';
-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all


-- we should set the blanks to nulls since those are typically easier to work with
UPDATE layoffs
SET industry = NULL
WHERE industry = '';

SELECT * 
FROM layoffs
WHERE industry IS NULL OR industry = '';
-- checking all of blanks are converted to NULL or not

-- now we need to fill those NULL values

UPDATE layoffs AS table_1
SET industry = table_2.industry
FROM layoffs AS table_2
WHERE table_1.company = table_2.company
  AND table_1.industry IS NULL
  AND table_2.industry IS NOT NULL;

-- Check for successful replacement of NULL values
SELECT *
FROM layoffs
WHERE company like 'Airbnb%';

-- ---------------------------------------------------

-- solution for prob 2 :  we need only one variation, let's say Crypto

SELECT *
FROM layoffs
WHERE industry like 'Crypto%'
ORDER BY industry DESC
LIMIT 5;

-- we need to change those to Crypto

UPDATE layoffs
SET industry = 'Crypto'
WHERE industry like 'Crypto%';
-- all the elements starting with Crypto now will be remaned as "Crypto"


2 country column

-- looking at the distict countries
SELECT DISTINCT(country) 
FROM layoffs
ORDER BY 1;

UPDATE layoffs
SET country = TRIM(TRAILING '.' FROM country);

-- running the code again to see if it is fixed
SELECT DISTINCT(country) 
FROM layoffs
ORDER BY 1;

3 percentage_laid_off column
-- converting text to numeric
ALTER TABLE layoffs
ALTER COLUMN percentage_laid_off TYPE NUMERIC USING percentage_laid_off::NUMERIC;

4 date column
-- checking the date column type

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'layoffs'
  AND column_name = 'date';


-- converting data from str to date using TO_DATE
UPDATE layoffs
SET date = TO_DATE(date, 'MM/DD/YYYY')
WHERE date IS NOT NULL;


-- now we can convert the column type to date
ALTER TABLE layoffs
ALTER COLUMN date TYPE DATE USING TO_DATE(date, 'YYYY/MM/DD');


-- checking again to make sure it is successfully converted
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'layoffs'
  AND column_name = 'date';



3. Look at Null Values
-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase
-- so there isn't anything I want to change with the null values



4. remove any columns and rows we need to

SELECT *
FROM layoffs
WHERE   total_laid_off IS Null AND percentage_laid_off IS NULL;

-- we do not want these rows of data, therfore we are removing them

DELETE FROM layoffs
WHERE   total_laid_off IS Null AND percentage_laid_off IS NULL;


-- running the code again to see for the successfull deletion
SELECT *
FROM layoffs
WHERE   total_laid_off IS Null AND percentage_laid_off IS NULL;

-- now we remove the column we previously created i.e row_num
ALTER TABLE layoffs
DROP COLUMN row_num;

-- now the data is ready for EDA phase
SELECT *
FROM layoffs
ORDER BY RANDOM ()
limit 5;




