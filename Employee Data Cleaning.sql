-- Imported Dataset as week1
SELECT * FROM week1;

-- A new copy of the dataset was created to preserve the raw dataset
CREATE TABLE week1_copy AS
SELECT * FROM week1;

-- Standardized Full Name as propercase
-- Trimmed to remove extra spaces
UPDATE week1_copy
SET `Full Name` = CONCAT(
	UPPER(LEFT(SUBSTRING_INDEX(TRIM(REPLACE(`Full Name`, '.', ' ')), ' ', 1), 1)),
	LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(REPLACE(`Full Name`, '.',' ')), ' ', 1), 2)),
       ' ',
	UPPER(LEFT(SUBSTRING_INDEX(TRIM(REPLACE(`Full Name`, '.',' ')), ' ', -1), 1)),
	LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(REPLACE(`Full Name`, '.',' ')), ' ', -1), 2))
	);

-- Another copy of the data set was created
CREATE TABLE week1_copy1 AS
SELECT `Full Name`,
 Age,
 CASE
	WHEN `Full Name` = 'Alice Johnson' THEN 'alice@gmail.com'  -- Validated the email in relation to each employer's name
    WHEN `Full Name` = 'Li Wei' THEN 'liwei@example.com'
    WHEN `Full Name` = 'Oluwaseun Bello' THEN 'oluwaseun@email.com'  
    WHEN `Full Name` = "Anna-marie O'neil" THEN 'annamarie@domain.com'
    WHEN `Full Name` = 'John Smith' THEN 'john@example.com'
    ELSE 'mohamed@gmail.com'
 END AS Email,
`Join Date`,
Department,
Salary,
ROW_NUMBER() OVER(PARTITION BY `Full Name`) AS rownumber
FROM week1_copy
WHERE TRIM(Age) <> 'NaN'
AND TRIM(`Join Date`) NOT IN ('not a date','')
AND TRIM(Department) <> ''
AND TRIM(Salary) NOT IN ('', 'unknown', 'NaN')
ORDER BY ROW_NUMBER() OVER(PARTITION BY `Full Name`) -- Used Order by ROW_NUMBER() to remove duplicate entries
LIMIT 6;

-- Converted age to numeric value where entry is 'thirty'
UPDATE week1_copy1
SET Age = 30
WHERE Age = 'thirty';

-- Converted all age to numeric value
ALTER TABLE week1_copy1
MODIFY COLUMN Age INT;

-- Converted all date to standard date formarts
  UPDATE week1_copy1
  SET `Join Date` = CASE 
    WHEN `Join Date` LIKE '__-___-____' THEN STR_TO_DATE(`Join Date`, '%d-%b-%Y') -- 01-Jan-2022
    WHEN `Join Date` LIKE '____/__/__' THEN STR_TO_DATE(`Join Date`, '%Y/%m/%d') -- 2022/12/01
    WHEN `Join Date` LIKE '__-__-____' THEN STR_TO_DATE(`Join Date`, '%d-%m-%Y') -- 10-05-2021 (assuming d-m-y)
    ELSE NULL
  END;

-- Standardized date formart
ALTER TABLE week1_copy1
MODIFY COLUMN `Join Date` DATE;

-- Standardized department names. Checked for typos and harmonize department labels.
UPDATE week1_copy1
SET Department = 
CASE
	WHEN Department = 'HR' THEN UPPER(Department)
    ELSE CONCAT(UPPER(LEFT(Department, 1)), LOWER(SUBSTRING(Department, 2)))
END;

-- Converted salary values to numeric values
UPDATE week1_copy1
SET Salary = 
CASE
	WHEN Salary = '75k' THEN 75000
    WHEN Salary = '50000.00' THEN 50000
    WHEN Salary = '80,000' THEN 80000
    ELSE 100000
END;

ALTER TABLE week1_copy1
MODIFY COLUMN Salary INT;

-- Derived a new column 'Years of Service'
ALTER TABLE week1_copy1
ADD COLUMN `Years of Service` INT;

UPDATE week1_copy1
SET `Years of Service`= FLOOR(DATEDIFF(CURRENT_DATE(), `Join Date`)/365);

ALTER TABLE week1_copy1
DROP COLUMN rownumber;

-- Calculated the Average Age
SELECT ROUND(AVG(Age), 2) FROM week1_copy1;

-- Calculated the Total Sum of Salary
SELECT SUM(Salary) FROM week1_copy1;

SELECT * FROM week1_copy1;