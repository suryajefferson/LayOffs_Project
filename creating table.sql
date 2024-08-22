-- Create layoffs table 
CREATE TABLE public.layoffs_original
(
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    date TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions NUMERIC
);


-- Set ownership of the tables to the postgres user
ALTER TABLE public.layoffs_original OWNER to postgres;
