
--Select data to use
SELECT * 
From PortfolioProject..COVIDDeaths
order by 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..COVIDDeaths
Order by 1,2

--Looking at total cases vs total deaths

Alter Table portfolioProject..CovidDeaths alter column total_cases FLOAT
Alter Table portfolioProject..CovidDeaths alter column total_deaths FLOAT
Alter Table portfolioProject..CovidDeaths alter column population FLOAT

SELECT Location, date, total_cases, total_deaths, (total_deaths / NULLIF (total_cases, 0)*100) AS DeathPercentage
FROM PortfolioProject..COVIDDeaths
WHERE location = 'United States'
Order by 1,2

----total cases vs population

SELECT Location, date, population, total_cases, (total_cases/ population)*100 as InfectionPercentage
FROM PortfolioProject..COVIDDeaths
WHERE location = 'United States'
Order by 1,2

--------Highest infection rates
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/ NULLIF (population, 0))*100) AS PercentPopulationInfected
FROM PortfolioProject..COVIDDeaths
GROUP by population, location
order by Population DESC

--Countries with death count per population
Select Location, max(total_deaths) as TotalDeathCount
From PortfolioProject..COVIDDeaths
Where continent != ''
Group by location 
Order by TotalDeathCount DESC

--BROKEN DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..COVIDDeaths
Where continent is not null and continent != ''
GROUP by continent
order by TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, SUM(CAST(new_cases as INT)) AS total_cases, SUM(CAST(new_deaths AS INT)) AS deaths, SUM(CAST(new_deaths AS FLOAT))/ SUM(CAST(NULLIF (new_cases,0)AS float))*100 AS Deathpercentage
FROM PortfolioProject..COVIDDeaths
where continent != ''
group by date 
order by 1,2 DESC

SELECT *
FROM PortfolioProject..COVIDVaccinations



--Total population vs # of vaccinations
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
AS 
(
SELECT D.continent, d.location, D.date, D.population, V.new_vaccinations, 
SUM(cast(V.new_vaccinations AS BIGINT)) OVER (Partition by D.location order by D.location, D.date) AS RollingVaccinations
FROM PortfolioProject..COVIDDeaths AS D
JOIN PortfolioProject..COVIDVaccinations AS V
	on D.location = V.location
	and D.date = V.date
Where D.continent != ''
)
Select *, (RollingVaccinations/NULLIF (Population, 0)*100)
From PopvsVac
Where continent != ''
--Use CTE to use RollingVaccinations in calculations right away

--Temp table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population BIGINT,
New_vaccinations BIGINT, 
RollingVaccinations BIGINT,
)

Insert into #PercentPopulationVaccinated
SELECT D.continent, d.location, D.date, D.population, V.new_vaccinations, 
SUM(cast(V.new_vaccinations AS BIGINT)) OVER (Partition by D.location order by D.location, D.date) AS RollingVaccinations
FROM PortfolioProject..COVIDDeaths AS D
JOIN PortfolioProject..COVIDVaccinations AS V
	on D.location = V.location
	and D.date = V.date
Where D.continent != ''

Select *, (Cast(RollingVaccinations AS FLoat)/NULLIF (Cast(Population AS FLOAT), 0)*100) AS PercentVaccinated
From #PercentPopulationVaccinated


-- Creating view to store for later visualizations

Create View PercentPopulationVaccinated as 
SELECT D.continent, d.location, D.date, D.population, V.new_vaccinations, 
SUM(cast(V.new_vaccinations AS BIGINT)) OVER (Partition by D.location order by D.location, D.date) AS RollingVaccinations
FROM PortfolioProject..COVIDDeaths AS D
JOIN PortfolioProject..COVIDVaccinations AS V
	on D.location = V.location
	and D.date = V.date
Where D.continent != ''

Select * 
From PercentPopulationVaccinated