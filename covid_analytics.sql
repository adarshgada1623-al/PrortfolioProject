USE portfolioproject;
DROP TABLE IF EXISTS CovidVaccinations;

SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CovidVaccinations.csv'
INTO TABLE CovidVaccinations
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
CREATE TABLE CovidVaccinations (
    iso_code TEXT,
    continent TEXT,
    location TEXT,
    date TEXT,
    new_tests TEXT,
    total_tests TEXT,
    total_tests_per_thousand TEXT,
    new_tests_per_thousand TEXT,
    new_tests_smoothed TEXT,
    new_tests_smoothed_per_thousand TEXT,
    positive_rate TEXT,
    tests_per_case TEXT,
    tests_units TEXT,
    total_vaccinations TEXT,
    people_vaccinated TEXT,
    people_fully_vaccinated TEXT,
    new_vaccinations TEXT,
    new_vaccinations_smoothed TEXT,
    total_vaccinations_per_hundred TEXT,
    people_vaccinated_per_hundred TEXT,
    people_fully_vaccinated_per_hundred TEXT,
    new_vaccinations_smoothed_per_million TEXT,
    stringency_index TEXT,
    population_density TEXT,
    median_age TEXT,
    aged_65_older TEXT,
    aged_70_older TEXT,
    gdp_per_capita TEXT,
    extreme_poverty TEXT,
    cardiovasc_death_rate TEXT,
    diabetes_prevalence TEXT,
    female_smokers TEXT,
    male_smokers TEXT,
    handwashing_facilities TEXT,
    hospital_beds_per_thousand TEXT,
    life_expectancy TEXT,
    human_development_index TEXT
);


UPDATE  covidvaccinations
SET human_development_index = null
WHERE human_development_index = '';

SET SQL_SAFE_UPDATES=0;

SELECT *
FROM coviddeath;

SELECT *
FROM covidvaccinations;

SELECT human_development_index
FROM covidvaccinations
WHERE human_development_index NOT REGEXP '^[0-9.]+$'
AND human_development_index IS NOT NULL;

UPDATE covidvaccinations
SET human_development_index = NULL
WHERE TRIM(human_development_index) = ''


ALTER TABLE covidvaccinations
MODIFY COLUMN human_development_index DOUBLE;

SELECT human_development_index
FROM covidvaccinations
LIMIT 432,5;

UPDATE covidvaccinations
SET human_development_index = NULL
WHERE human_development_index NOT REGEXP '^[0-9.]+$';


SELECT * FROM coviddeath
WHERE location LIKE '%Asia%'
ORDER BY 3,4 ;

SELECT * FROM covidvaccinations
ORDER BY 3,4;

SELECT location,`date`,total_cases,new_cases,total_deaths,population
FROM coviddeath
ORDER BY 1,2;

-- Looking at total Cases VS Total Death

SELECT location,`date`,total_cases,total_deaths,(total_deaths/total_cases)*100 DeathPercentage
FROM coviddeath
WHERE location LIKE '%India%'
ORDER BY 1,2;

-- Looking at Total cases VS Population
SELECT location,`date`,total_cases,population,(total_cases/population)*100 InfectionPercentage
FROM coviddeath
WHERE location LIKE '%States%'
ORDER BY 1,2;

SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 InfectionPercentage
FROM coviddeath
GROUP BY location,population
ORDER BY InfectionPercentage DESC;

SELECT continent,MAX(total_deaths) TotalDeathCount
FROM coviddeath
WHERE continent IS  NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Showing continent  with the Highest death count per population






-- Gloable Number
SELECT SUM(new_cases),SUM(new_deaths),SUM(new_deaths)/SUM(new_cases)*100
FROM coviddeath
WHERE continent IS NOT NULL
-- GROUP BY `date`
ORDER BY 1,2;

-- Looking at the Total Population VS Vaccination

SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,SUM(VAC.new_vaccinations) OVER(PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS rolling_people_vacc
FROM coviddeath DEA
JOIN covidvaccinations VAC
ON DEA.location = VAC.location
AND DEA.`date` = VAC.`date`
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3;


WITH PVvsVAC(continent,date,location,population,new_vaccinations,rolling_people_vacc)
AS
(
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,SUM(VAC.new_vaccinations) OVER(PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS rolling_people_vacc
FROM coviddeath DEA
JOIN covidvaccinations VAC
ON DEA.location = VAC.location
AND DEA.`date` = VAC.`date`
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3
)
SELECT *,(rolling_people_vacc/population)*100
FROM PVvsVAC;

-- TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE  PercentPopulationVaccinated
(
continent VARCHAR(255),
location VARCHAR(255),
Date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_people_vacc NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,SUM(VAC.new_vaccinations) OVER(PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS rolling_people_vacc
FROM coviddeath DEA
JOIN covidvaccinations VAC
ON DEA.location = VAC.location
AND DEA.`date` = VAC.`date`;
-- WHERE DEA.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *,(rolling_people_vacc/population)*100
FROM PercentPopulationVaccinated;

CREATE VIEW PPercentPopulationVaccinated AS
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,SUM(VAC.new_vaccinations) OVER(PARTITION BY DEA.location ORDER BY DEA.location,DEA.date) AS rolling_people_vacc
FROM coviddeath DEA
JOIN covidvaccinations VAC
ON DEA.location = VAC.location
AND DEA.`date` = VAC.`date`
 WHERE DEA.continent IS NOT NULL;











