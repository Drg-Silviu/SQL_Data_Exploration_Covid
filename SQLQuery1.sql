SELECT *
FROM PortfolioProject1.dbo.CovidDeaths
ORDER BY 3,4 

--SELECT *
--FROM PortfolioProject1.dbo.CovidVaccinations
--ORDER BY 3,4 

-- Select Data that i'm going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contact covid in your contry
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid in United Kingdom
SELECT Location, date, total_cases, Population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject1.dbo.CovidDeaths
WHERE Location LIKE 'United Kingdom'
ORDER BY 1,2

--Looking for Countried with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1.dbo.CovidDeaths
--WHERE Location LIKE 'United Kingdom'
GROUP BY Location, Population 
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
--WHERE Location LIKE 'United Kingdom'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--LET'S BREAK IT DOWN Y CONTINENT
--Showing the continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
--WHERE Location LIKE 'United Kingdom'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases)AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths as Dea
JOIN PortfolioProject1.dbo.CovidVaccinations as Vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2 

-- USE CTE

WITH PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths as Dea
JOIN PortfolioProject1.dbo.CovidVaccinations as Vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths as Dea
JOIN PortfolioProject1.dbo.CovidVaccinations as Vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualisation
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths as Dea
JOIN PortfolioProject1.dbo.CovidVaccinations as Vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated