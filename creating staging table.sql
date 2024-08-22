CREATE TABLE layoffs(
    LIKE layoffs_original);


INSERT INTO layoffs(
    SELECT * FROM layoffs_original);
