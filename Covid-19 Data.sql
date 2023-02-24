-- DATA EXPLORATION (coviddeaths table)

-- Select Data to begin analysis 
SELECT * FROM coviddeaths

-- Covid-19 Data from 2020-02-24 to 2023-02-12

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY location,date
 

-- Annual COVID-19 incidence by country
SELECT Location, EXTRACT(YEAR FROM date) AS year, SUM(new_cases) AS total_infected_per_year
FROM coviddeaths
GROUP BY Location, EXTRACT(YEAR FROM date)
ORDER BY location, EXTRACT(YEAR FROM date)


-- Total cases vs Population
-- Daily count of COVID-19 cases recorded in each country, in relation to the population size

SELECT Location, date, population, total_cases,(CAST(total_cases AS DECIMAL(18,6)) / CAST(population AS DECIMAL(18,6)))*100 AS Percentage 
FROM coviddeaths
ORDER BY location, date 

-- Total cases vs Population
-- Shows the daily proportion of Canadians who tested positive for COVID-19 in relation to the overall population size

Select Location, date, population, total_cases,(CAST(total_cases AS DECIMAL(18,6)) / CAST(population AS DECIMAL(18,6)))*100 AS Percentage 
FROM coviddeaths
WHERE location = 'Canada'
ORDER BY location, date 


-- List of countries and their confirmed COVID-19 cases as a proportion of their population

SELECT Location, population, MAX(total_cases) AS Total_Case_Count, 
(CAST(MAX(total_cases) AS DECIMAL(18,6)) / CAST(population AS DECIMAL(18,6)))*100 AS InfectedPopulationPercentage
FROM coviddeaths
GROUP BY Location, population
 

-- Which countries have the highest number of cases

SELECT DISTINCT (Location), SUM(new_cases) as Total_cases_per_country
FROM coviddeaths
WHERE location NOT IN ('World', 'High income','Europe', 'Asia', 'European Union', 
'Upper middle income', 'North America', 'Lower middle income', 'South America') AND 
new_cases IS NOT NULL
GROUP BY location
ORDER BY SUM(new_cases) DESC

-- Which countries have the highest number of cases (Top 10 displayed)
-- Shows global confirmed cases followed by top 10 countries

SELECT DISTINCT (Location), SUM(new_cases) as Total_cases_per_country
FROM coviddeaths
WHERE location NOT IN ('High income','Europe', 'Asia', 'European Union', 
'Upper middle income', 'North America', 'Lower middle income', 'South America') AND 
new_cases IS NOT NULL
GROUP BY location
ORDER BY SUM(new_cases) DESC
LIMIT  11


-- check total cases vs total deaths
-- Provides a daily breakdown of COVID-19 death cases in each country

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS DECIMAL(18,6)) / CAST(total_cases AS DECIMAL(18,6)))*100 AS DeathPercentage 
FROM coviddeaths
ORDER BY location, date

-- Death rate by country (Canada)
-- The data also reveals the day when Canada started recording death cases
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS DECIMAL(18,6)) / CAST(total_cases AS DECIMAL(18,6)))*100 AS DeathPercentage 
FROM coviddeaths
WHERE location = 'Canada'
ORDER BY location, date

--Total number of confirmed COVID-19 case count and the number of deaths

SELECT SUM (new_cases) as total_cases, SUM (new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Number of COVID-19 deaths per year in each country

SELECT Location, EXTRACT(YEAR FROM date) AS year, SUM(new_deaths) AS total_deaths_per_year
FROM coviddeaths
GROUP BY Location, EXTRACT(YEAR FROM date)
ORDER BY location, EXTRACT(YEAR FROM date)

-- Countries with the highest number of COVID-19 death cases.
-- Shows global numbers followed by top 10 countries

SELECT DISTINCT (Location), SUM(new_deaths) as Total_deadcount_per_country
FROM coviddeaths
WHERE location NOT IN ('High income','Europe', 'Asia', 'European Union', 
'Upper middle income', 'North America', 'Lower middle income', 'South America') AND 
new_deaths IS NOT NULL
GROUP BY location
ORDER BY SUM(new_deaths) DESC
LIMIT 11


-- BREAK THINGS BY CONTINENT
-- Worldwide COVID-19 death count by continent

SELECT DISTINCT (location), SUM(new_deaths) as Total_deathcount
FROM coviddeaths
WHERE continent  IS   NULL AND location NOT IN ('High income', 'European Union', 
'Upper middle income', 'Lower middle income', 'Low income',  'International')
GROUP BY location
ORDER BY SUM(new_deaths) DESC


-- Daily global record of COVID-19 death cases from 2020-02-24 to 2023-02-12

Select date, SUM(new_cases)  as Total_cases_eachday, SUM(new_deaths) as total_deaths_eachday
FROM coviddeaths
GROUP BY date
ORDER BY date DESC

-- Displays daily global death percentage

SELECT date, SUM(new_cases) as Total_cases_eachday, 
SUM(new_deaths) as total_deaths_eachday, 
CONCAT(ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 1), '%') AS death_to_cases_ratio
FROM coviddeaths
GROUP BY date
ORDER BY date DESC


-- DATA EXPLORATION (covidvaccinations table)

SELECT * FROM covidvaccinations

-- Overall count of individuals who have been vaccinated  in each country

SELECT location, SUM(new_vaccinations) as total_people_vaccinated
FROM covidvaccinations
GROUP BY location

-- Overall count of individuals who have been vaccinated in Canada

SELECT location, SUM(new_vaccinations) as total_people_vaccinated
FROM covidvaccinations
WHERE location = 'Canada'
GROUP BY location

-- Check number of people vaccinated around the world 
-- Displays a comparison of daily vaccination counts in different countries with respect to their population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE vac.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL


-- Check daily count of individuals who received vaccinations in Canada, relative to its population 
-- It also shows the date when Canada commenced its vaccination program

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE vac.continent IS NOT NULL AND vac.location = 'Canada' AND vac.new_vaccinations IS NOT NULL

-- Presents the number of people vaccinated each day, 
-- and the column adjacent to it calculates the total number of vaccinations up to and including that day

With popvsvac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 
Rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE vac.continent IS NOT NULL 
)
SELECT * , (Rolling_people_vaccinated/population)*100 AS VaccinatedPercentage
FROM popvsvac

-- Create a new table where the output from the previous query can be saved

CREATE TABLE PercentPeopleVaccinated
(
                      Continent VARCHAR (250),
	                  Location VARCHAR (250),
	                  Date TIMESTAMP,
	                  Population NUMERIC,
	                  New_vaccinations NUMERIC,
                      Rolling_people_vaccinated NUMERIC
);

INSERT INTO PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 
Rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE vac.continent IS NOT NULL;

SELECT * , (Rolling_people_vaccinated/population)*100 AS VaccinatedPercentage
FROM PercentPeopleVaccinated;

-- Create views for storing data that can be used for visualization at a later stage


-- This view can be used to check the number of people who have been vaccinated globally, 
-- especially when the data is updated

CREATE VIEW PeopleVaccinatedPer AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 
Rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE vac.continent IS NOT NULL