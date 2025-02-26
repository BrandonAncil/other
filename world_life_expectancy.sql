-- DATA CLEANING

-- Remove Duplicates
SELECT Country,
  Year,
  CONCAT(Country, Year),
  COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

SELECT Row_ID
FROM
  (SELECT Row_ID,
    CONCAT(Country, Year),
    ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
  FROM world_life_expectancy) AS Row_table
WHERE Row_Num > 1;

DELETE FROM world_life_expectancy
WHERE Row_ID IN (
  SELECT Row_ID
  FROM
    (SELECT Row_ID,
      CONCAT(Country, Year),
      ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
    FROM world_life_expectancy) AS Row_table
  WHERE Row_Num > 1
);

-- Replace null Values
SELECT *
FROM world_life_expectancy
WHERE Status IS NULL;

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing';

UPDATE world_life_expectancy
SET Status = 'Developing'
WHERE Country IN (
  SELECT DISTINCT(Country)
  FROM world_life_expectancy
  WHERE Status = 'Developing'
)
  AND Status IS NULL;

UPDATE world_life_expectancy
SET Status = 'Developed'
WHERE Country IN (
  SELECT DISTINCT(Country)
  FROM world_life_expectancy
  WHERE Status = 'Developed'
)
  AND Status IS NULL;

SELECT *
FROM world_life_expectancy
WHERE 'Life expectancy' IS NULL;

SELECT t1.Country,
  t1.Year,
  t1.'Life expectancy',
  ROUND(CAST(t2.'Life expectancy'+t3.'Life expectancy')/2,1) AS life_expectancy_new
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.Country
  AND t2.Year = t1.Year-1
JOIN world_life_expectancy t3
ON t1.Country = t3.Country
  AND t3.Year = t1.Year+1
WHERE t1.'Life expectancy' IS NULL;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.Country
  AND t2.Year = t1.Year-1
JOIN world_life_expectancy t3
ON t1.Country = t3.Country
  AND t3.Year = t1.Year+1
SET t1.'Life expectancy' = ROUND((t2.'Life expectancy'+t3.'Life expectancy')/2,1)
WHERE t1.'Life expectancy' IS NULL;


-- EXPLORATORY DATA ANALYSIS
SELECT Country,
  MIN('Life expectancy'),
  MAX('Life expectancy'),
  ROUND(MAX('Life expectancy') - MIN('Life expectancy'), 1) AS life_increase_15_years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN('Life expectancy') > 0
  AND MAX('Life expectancy') > 0
ORDER BY life_increase_15_years DESC;

SELECT Year,
  ROUND(AVG('Life expectancy'), 2)
FROM world_life_expectancy
WHERE 'Life expectancy' != 0
GROUP BY Year
ORDER BY Year ASC;

SELECT Country,
  ROUND(AVG('Life expectancy'), 1) AS life_exp,
  ROUND(AVG(GDP), 1) AS GDP
FROM world_life_expectancy
WHERE 'Life expectancy' != 0
AND GDP != 0
GROUP BY Country
ORDER BY GDP ASC;

SELECT
  SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
  AVG(CASE WHEN GDP >= 1500 THEN 'Life expectancy' ELSE NULL END) High_GDP_Life_Expectancy,
  SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
  AVG(CASE WHEN GDP <= 1500 THEN 'Life expectancy' ELSE NULL END) Low_GDP_Life_Expectancy
FROM world_life_expectancy;

SELECT Status,
  COUNT(DISTINCT Country),
  ROUND(AVG('Life expectancy'),1)
FROM world_life_expectancy
GROUP BY Status;

SELECT Country,
  ROUND(AVG('Life expectancy'),1) AS life_exp,
  ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
WHERE 'Life expectancy' != 0
AND BMI != 0
GROUP BY Country
ORDER BY BMI DESC;

SELECT Country,
  Year,
  'Life expectancy',
  'Adult Mortality',
  SUM('Adult Mortality') OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
WHERE Country LIKE '%United%';