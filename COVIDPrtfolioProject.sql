SELECT  * 
from dbo.CovidDeaths
Where continent is not null 
Order by 3,4 

--select * 
--from dbo.CovidVaccinations

SELECT Location,date,total_cases,new_cases,total_deaths,population
From dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Total Cases vs Total Deaths 
--Shows lokelihood of dying if you contract covid n your country 

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From dbo.CovidDeaths
Where location like '%states%'
Order by 1,2

-- Cases vs Population 
--Shows what percentage of population contracted covid

Select Location,date,population,total_cases,(total_cases/population)*100 as PopulationPercentage
From dbo.CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2

-- Countries with Highest Infection Rates compared to Population

SELECT Location,population,MAX(total_cases)as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
From dbo.CovidDeaths
-- location like '%states%'
Where continent is not null
Group by Location,Population
Order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population 

SELECT Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
-- location like '%states%'
Where continent is not null
Group by Location 
Order by TotalDeathCount desc


--Continents with the highest death counts 

SELECT continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
-- location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers 


SELECT date,SUM(new_cases) as tota_cases, SUM(cast(new_deaths as int))as total_deaths,
			SUM(cast(new_deaths as int))/
			SUM(new_Cases)*100  as DeathPercentage
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By date 
Order by 1,2


SELECT  SUM(new_cases) as tota_cases, SUM(cast(new_deaths as int))as total_deaths,
		SUM(cast(new_deaths as int))/
		SUM(new_Cases)*100  as DeathPercentage
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date 
Order by 1,2

-- Total Population vs Vaccination 

SELECT *
From dbo.CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	 ON dea.Location = vac.location
	 AND dea.date = vac.date 

SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
From dbo.CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2,3


SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location
Order by dea.location,dea.Date) as RollingVaccinationsTotals
From dbo.CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2,3


--CTE 

With PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingVaccinationsTotals)
as
(
SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingVaccinationsTotals
From dbo.CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date 
WHERE dea.continent is not null
)
SELECT *,(RollingVaccinationsTotals/Population)*100 as PercentageVaccinated
From PopvsVac

--TEMP TABLE

DROP Table if exists PerVaccianted
Create Table PerVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationsTotals numeric
)
Insert into PerVaccinated
SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingVaccinationsTotals
From dbo.CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date 
WHERE dea.continent is not null

SELECT *,(RollingVaccinationsTotals/Population)*100 
From PerVaccinated


-- Creating VIEW to store datat for later visualizations 

Create View PercentageVaccinated as
SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location
Order by dea.location,dea.Date) as RollingVaccinationsTotals
From dbo.CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date 
WHERE dea.continent is not null

Select*
From PercentageVaccinated

