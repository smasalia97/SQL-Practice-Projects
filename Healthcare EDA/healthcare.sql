SELECT * 
FROM dbo.healthcare_dataset$

-- Fixing the text case for Name
UPDATE dbo.[healthcare_dataset$]
SET Name = CONCAT(UPPER(SUBSTRING(Name, 1, 1)), LOWER(SUBSTRING(Name, 2, LEN(Name))));


-- Easy Questions: 
-- Find the names and ages of all patients admitted for "Emergency" cases.
SELECT Name, Age
FROM dbo.healthcare_dataset$
WHERE [Admission Type] = 'Emergency';

--List the unique blood types available in the dataset, sorted alphabetically.
SELECT DISTINCT [Blood Type] AS unique_blood_types
FROM dbo.healthcare_dataset$
ORDER BY unique_blood_types

--Calculate the average billing amount for patients with "Cancer" as a medical condition.
SELECT AVG([Billing Amount]) as avg_cancer_billing_amount
FROM dbo.healthcare_dataset$
WHERE [Medical Condition] = 'Cancer';

--Display the top 5 hospitals by the number of admissions.
SELECT TOP 5 [Hospital], COUNT(*) AS count_of_admissions
FROM dbo.healthcare_dataset$
GROUP BY [Hospital]
ORDER BY count_of_admissions DESC

--Retrieve the list of doctors who have treated patients with "Normal" test results.
SELECT Doctor
FROM dbo.healthcare_dataset$
WHERE [Test Results] = 'Normal';

--Identify the number of male and female patients in the dataset.
SELECT Gender, COUNT(Gender) as count_gender
FROM dbo.healthcare_dataset$
GROUP BY Gender

--Find the most recent admission date for a patient treated by "Samantha Davies."
SELECT DISTINCT ([Date of Admission])
FROM dbo.healthcare_dataset$
WHERE Doctor = 'Samantha Davies'

--List the distinct medications prescribed to patients with "Diabetes."
SELECT DISTINCT Medication
FROM dbo.healthcare_dataset$
WHERE [Medical Condition] = 'Diabetes'

--Find patients who have a billing amount higher than the average billing amount.
SELECT Name, ROUND([Billing Amount], 2) as billing_amount
FROM dbo.healthcare_dataset$
WHERE [Billing Amount] > (SELECT AVG([Billing Amount]) FROM dbo.healthcare_dataset$)

--Display the number of patients grouped by each insurance provider.
SELECT [Insurance Provider],  COUNT(NAME) count_of_users
FROM dbo.healthcare_dataset$
GROUP BY [Insurance Provider]
ORDER BY count_of_users DESC



---- Moderate Questions:
--Calculate the total billing amount for each hospital and sort it in descending order.
SELECT DISTINCT Hospital FROM dbo.healthcare_dataset$ -- Just to get count of unique hospitals to tally with the next query

SELECT Hospital, ROUND(SUM([Billing Amount]), 2) total_billing_amt
FROM dbo.healthcare_dataset$
GROUP BY Hospital
ORDER BY total_billing_amt DESC

--Find all patients who have been treated by more than one doctor.
SELECT Name, COUNT(Doctor) AS count_doctor
FROM dbo.healthcare_dataset$
GROUP BY Name
HAVING COUNT(Doctor) > 1
ORDER BY count_doctor DESC;

--Retrieve the details of patients whose discharge date is later than 15 days after their admission date.
SELECT *
FROM dbo.healthcare_dataset$
WHERE DATEDIFF(DAY, [Date of Admission], [Discharge Date]) > 15

--Identify the doctor with the highest number of "Elective" admissions.
SELECT TOP 1 Doctor, COUNT([Admission Type]) AS Elective_Admissions_Count
FROM dbo.healthcare_dataset$
WHERE [Admission Type] = 'Elective'
GROUP BY Doctor
ORDER BY Elective_Admissions_Count DESC

--List all patients whose billing amount falls within the top 10% of the dataset.
SELECT name, ROUND(PERCENTILE_DISC (0.9) WITHIN GROUP (ORDER BY [Billing Amount] DESC) OVER (PARTITION BY name), 2) AS top_10_pct
FROM dbo.healthcare_dataset$
ORDER BY top_10_pct DESC

--Find the average age of patients grouped by their medical condition and gender.
SELECT [Medical Condition], Gender, ROUND(AVG(Age), 2) as avg_age
FROM dbo.healthcare_dataset$
GROUP BY [Medical Condition], Gender
ORDER BY avg_age DESC

-- Display the names of hospitals that have treated at least one patient for all conditions
-- Get the count of distinct medical conditions
WITH ConditionCount AS (
    SELECT COUNT(DISTINCT [Medical Condition]) AS total_conditions
    FROM dbo.[healthcare_dataset$]
)

-- Find hospitals that treated at least one patient for all distinct medical conditions
SELECT Hospital
FROM dbo.[healthcare_dataset$]
GROUP BY Hospital
HAVING COUNT(DISTINCT [Medical Condition]) = (SELECT total_conditions FROM ConditionCount);

--List the top 3 insurance providers by the number of claims they handled.
SELECT TOP 3 [Insurance Provider], COUNT(*) number_claims
FROM dbo.healthcare_dataset$
GROUP BY [Insurance Provider]
ORDER BY number_claims DESC

--Find the doctor who has treated the maximum number of patients with "Abnormal" test results.
SELECT TOP 1 Doctor, COUNT(DISTINCT Name) count
FROM dbo.healthcare_dataset$
GROUP BY Doctor, [Test Results]
HAVING [Test Results] = 'Abnormal'
ORDER BY count DESC

--Display the admission types that have an average billing amount greater than $20,000.
SELECT [Admission Type], ROUND(AVG([Billing Amount]), 2) AS avg_bill
FROM dbo.[healthcare_dataset$]
GROUP BY [Admission Type]
HAVING AVG([Billing Amount]) >= 20000;




---- Hard Questions:
--Write a query to find patients who have been readmitted to the same hospital (admitted more than once).
SELECT DISTINCT Name, Hospital, COUNT(*) count
FROM dbo.healthcare_dataset$
GROUP BY Name, Hospital
HAVING count(*) > 1
ORDER BY count DESC, Name 
	
--Calculate the percentage of patients with each blood type who received "Urgent" vs. "Elective" admission types.
SELECT [Blood Type], [Admission Type], COUNT(*) AS total_admissions
FROM dbo.[healthcare_dataset$]
WHERE [Admission Type] <> 'Emergency'
GROUP BY [Blood Type], [Admission Type]
ORDER BY total_admissions DESC, [Blood Type];

-- Retrieve the names of doctors who have only treated patients with "Normal" test results
SELECT Doctor
FROM dbo.[healthcare_dataset$]
WHERE [Doctor] NOT IN (
    SELECT Doctor
    FROM dbo.[healthcare_dataset$]
    WHERE [Test Results] IN ('Abnormal', 'Inconclusive')
)
--Use a window function to rank hospitals based on their total billing amount.
SELECT Hospital, 
       ROUND(SUM([Billing Amount]), 2) AS total_billing,
       RANK() OVER (ORDER BY SUM([Billing Amount]) DESC) AS billing_rank
FROM dbo.[healthcare_dataset$]
GROUP BY Hospital;

--Find the average billing amount for each blood type, considering only patients whose age is above 50.
With dataset_above_50 AS (
	SELECT *
	FROM dbo.healthcare_dataset$
	WHERE Age > 50
)
SELECT [Blood Type], ROUND(AVG([Billing Amount]), 2) avg_bill_amt
FROM dataset_above_50
GROUP BY [Blood Type]
ORDER BY avg_bill_amt DESC

-- Identify patients whose billing amount is greater than the average billing of their respective admission type using subqueries.
SELECT Name
FROM (
    SELECT Name, [Admission Type], [Billing Amount],
           AVG([Billing Amount]) OVER (PARTITION BY [Admission Type]) AS avg_bill_amt
    FROM dbo.[healthcare_dataset$]
) AS main
WHERE main.[Billing Amount] > main.avg_bill_amt;

-- Display a list of all medications prescribed more than twice and the number of patients who received each
SELECT Medication, COUNT(DISTINCT Name) AS num_patients
FROM dbo.healthcare_dataset$
WHERE Medication IS NOT NULL
GROUP BY Medication
HAVING COUNT(Medication) > 2;

--Use case statements to categorize patients' billing amounts into three groups: 'Low', 'Medium', and 'High' based on the dataset�s quartile ranges.
WITH Quartiles AS (
    -- Calculate the quartiles (Q1, Q2, Q3) for the billing amounts
    SELECT TOP 1
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY [Billing Amount]) OVER () AS Q1,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [Billing Amount]) OVER () AS Q2,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY [Billing Amount]) OVER () AS Q3
    FROM dbo.[healthcare_dataset$]
)

		-- Select the patient data and categorize billing amounts based on quartiles
SELECT *,
       CASE
           WHEN [Billing Amount] <= (SELECT Q1 FROM Quartiles) THEN 'Low'
           WHEN ([Billing Amount] > (SELECT Q1 FROM Quartiles) AND [Billing Amount] <= (SELECT Q2 FROM Quartiles)) THEN 'Medium'
           ELSE 'High'
       END AS Billing_Category
FROM dbo.healthcare_dataset$;


-- Generate a list of the top 5 doctors who have handled the most diverse range of medical conditions
SELECT Doctor, COUNT(DISTINCT [Medical Condition]) AS condition_count
FROM dbo.healthcare_dataset$
GROUP BY Doctor
HAVING COUNT(DISTINCT [Medical Condition]) = (
    -- Subquery to get the total number of distinct medical conditions
    SELECT COUNT(DISTINCT [Medical Condition]) 
    FROM dbo.healthcare_dataset$
)
ORDER BY condition_count DESC;
