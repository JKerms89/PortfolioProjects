SELECT *
FROM PortfolioProject..coviddeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..covidvaccinations
--ORDER BY 3,4

--Select data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeaths
ORDER BY 1,2

--Looking at total cases vs total deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM PortfolioProject..coviddeaths
ORDER BY 1, 2

-- Shows likelihood of dying if you contract Covid in the UK.

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM PortfolioProject..coviddeaths
WHERE Location like '%kingdom%'
ORDER BY 1, 2

-- Looking at the total cases vs population in the UK.
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS percentpopulationinfected
FROM PortfolioProject..coviddeaths
WHERE Location like '%kingdom%'
ORDER BY 1, 2

-- Let's look at the countries with the highest infection rate + highest death rate compared to population size

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_deaths) AS Highestdeaths, MAX((total_cases/ population))*100 AS
PercentPopulationInfected, MAX((total_deaths / population))*100 AS PercentCovidDeaths
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentCovidDeaths DESC;

-- Showing countries with highest death count per population

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Lets break things down by continent
-- Showing continents with highest death count per population 

SELECT Continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC;

-- Create a stored procedure for continent value

CREATE PROCEDURE deathsbycontinent
@continentname varchar(50)
AS
SELECT Continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE Continent = @continentname
GROUP BY Continent

-- Execute the stored procedure. Lets have a look at North America...

EXEC deathsbycontinent @continentname = 'North America'

-- Let's now see Europe...

EXEC deathsbycontinent @continentname = 'Europe'

-- Let's do the same for location...I would like to know how many deaths there were in Italy...

CREATE PROCEDURE deathsbylocation
@locationname varchar(50)
AS
SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE Location = @locationname
GROUP BY Location

EXEC deathsbylocation @locationname = 'Italy'

-- GLOBAL NUMBERS to see total deaths and total cases on a global level. We can see that 24 February 2020
-- was the worst day for covid-19 deaths as a proportion of total cases.

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE Continent IS NOT NULL
GROUP BY date 
ORDER BY 4 DESC;

-- Let's see total cases, total deaths and death percentage on a global level without grouping by date.
-- The death rate from seasonal flu is typically around 0.1% in the U.S. This means that COVID-19 is still
-- 10 times more deadly than seasonal flu. 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE Continent IS NOT NULL;

-- Join the coviddeaths and covidvac tables together
-- Looking at total population vs vaccinations by continent-
-- Partition by is needed as we do not want the sum count to keep going up after the sum has been added up
-- for one location
-- USE CTE to allow us to do more in-depth calculations

WITH PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleFullyVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

Select*, (RollingPeopleVaccinated/Population)*100 AS percentvaccinated
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

-- Insert into the previous SQL query
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleFullyVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT*, (RollingPeopleVaccinated/Population)*100 AS percentvaccinated
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleFullyVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


Select * 
FROM PercentPopulationVaccinated


