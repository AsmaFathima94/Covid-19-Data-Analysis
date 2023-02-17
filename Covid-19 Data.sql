-- DATA EXPLORATION (coviddeaths table)

-- Select Data to begin analysis 
Select * from coviddeaths

-- Covid-19 Data from 2020-02-24 to 2023-02-12

Select Location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by location,date

-- check total cases vs total deaths
-- shows percentage of population who died after getting infected

Select Location, date, total_cases, total_deaths, (CAST(total_deaths AS DECIMAL(18,6)) / CAST(total_cases AS DECIMAL(18,6)))*100 AS DeathPercentage 
from coviddeaths
order by location, date

-- Check Death rate Country wise (Canada)
Select Location, date, total_cases, total_deaths, (CAST(total_deaths AS DECIMAL(18,6)) / CAST(total_cases AS DECIMAL(18,6)))*100 AS DeathPercentage 
from coviddeaths
WHERE location = 'Canada'
order by location, date 

-- Number of infected people (country-wise)
SELECT Location, EXTRACT(YEAR FROM date) AS year, SUM(new_cases) AS total_infected_per_year
FROM coviddeaths
GROUP BY Location, EXTRACT(YEAR FROM date)
ORDER BY location, EXTRACT(YEAR FROM date)


-- Number of people who died each year due to covid (country-wise)

SELECT Location, EXTRACT(YEAR FROM date) AS year, SUM(new_deaths) AS total_deaths_per_year
FROM coviddeaths
GROUP BY Location, EXTRACT(YEAR FROM date)
ORDER BY location, EXTRACT(YEAR FROM date)

-- Total cases vs Population
-- shows what percentage of population got covid (country-wise)

Select Location, date, population, total_cases,(CAST(total_cases AS DECIMAL(18,6)) / CAST(population AS DECIMAL(18,6)))*100 AS DeathPercentage 
from coviddeaths
order by location, date 

-- Total cases vs Population
-- shows what percentage of population got covid in Canada

Select Location, date, population, total_cases,(CAST(total_cases AS DECIMAL(18,6)) / CAST(population AS DECIMAL(18,6)))*100 AS DeathPercentage 
from coviddeaths
where location = 'Canada'
order by location, date 

-- what counties has the highest number of cases

SELECT DISTINCT (Location), SUM(new_cases) as Total_cases_per_country
FROM coviddeaths
WHERE location NOT IN ('World', 'High income','Europe', 'Asia', 'European Union', 
'Upper middle income', 'North America', 'Lower middle income', 'South America') AND 
new_cases IS NOT NULL
GROUP BY location
ORDER BY SUM(new_cases) DESC

-- what countries has the highest number of cases (Shows top 10)
-- shows global confirmed cases followed by top 10 countries

SELECT DISTINCT (Location), SUM(new_cases) as Total_cases_per_country
FROM coviddeaths
WHERE location NOT IN ('High income','Europe', 'Asia', 'European Union', 
'Upper middle income', 'North America', 'Lower middle income', 'South America') AND 
new_cases IS NOT NULL
GROUP BY location
ORDER BY SUM(new_cases) DESC
LIMIT  11

-- what countries has the highest number of death cases 
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
-- shows global dead count and death cases per continent

SELECT DISTINCT (location), SUM(new_deaths) as Total_deadcount
FROM coviddeaths
WHERE continent  IS   NULL AND location NOT IN ('High income', 'European Union', 
'Upper middle income', 'Lower middle income', 'Low income',  'International')
GROUP BY location
ORDER BY SUM(new_deaths) DESC


-- Global numbers

Select date, SUM(new_cases)  as Total_cases_eachday, SUM(new_deaths) as total_deaths_eachday
FROM coviddeaths
GROUP BY date
ORDER BY date DESC

-- Global death percentage per day

SELECT date, SUM(new_cases) as Total_cases_eachday, 
SUM(new_deaths) as total_deaths_eachday, 
CONCAT(ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 1), '%') AS death_to_cases_ratio
FROM coviddeaths
GROUP BY date
ORDER BY date DESC


-- DATA EXPLORATION (covidvaccinations table)

Select * from covidvaccinations

-- Displays the overall count of individuals who have received vaccinations globally

SELECT location, SUM(new_vaccinations) as total_people_vaccinated
FROM covidvaccinations
GROUP BY location

-- Displays the overall count of individuals who have received vaccinations in Canada

SELECT location, SUM(new_vaccinations) as total_people_vaccinated
FROM covidvaccinations
where location = 'Canada'
GROUP BY location

-- Check number of people vaccinated around the world 
-- Presents a comparison of daily vaccination counts in different countries with respect to their population

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
as
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


-- This view can be used to check the number of people globally who have been vaccinated, 
-- especially when the data is updated

CREATE VIEW PeopleVaccinatedPer AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 
Rolling_people_vaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE vac.continent IS NOT NULL






















