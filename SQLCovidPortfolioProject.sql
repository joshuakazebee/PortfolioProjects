--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3, 4
--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1, 2

---- Looking at Total Cases vs Total Deaths in the US

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
--ORDER BY 1, 2

---- Looking at Total Cases vs Population in the US

--SELECT location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
--ORDER BY 1, 2

-- Total Global Death Percentage

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Join the Deaths and Vaccinations tables
-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location
		ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

-- Using a CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location
		ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVacPercentage
FROM PopvsVac

-- Using Temp Table

DROP TABLE if exists #percentPopulationVaccinated
CREATE TABLE #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #percentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location
		ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 1,2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #percentPopulationVaccinated

-- Creating View to store data for vizualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location
		ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null