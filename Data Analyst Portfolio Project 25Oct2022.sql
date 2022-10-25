select location,date,total_cases,new_cases,total_deaths,population
from dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact Covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where location like '%Malaysia%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select location,date,population, total_cases, (total_cases/population)*100 as PercentageofPopulationInfected
from dbo.CovidDeaths
where location like '%Malaysia%'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compated to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageofPopulationInfected
from dbo.CovidDeaths
--where location like '%Malaysia%'
where continent is not null
group by location, population
order by PercentageofPopulationInfected desc

-- Showing Countries with Highest Death count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- LET"S BREAK THINGS DOWN BY CONTINENT!!

-- Showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
--where location like '%Malaysia%'
where continent is not null
--group by date
order by 1,2

-- Looking at Total population vs vaccinations
select dea.continent, dea.location, dea.date, population, CONVERT(bigint,vac.new_vaccinations) as new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea 
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(select dea.continent, dea.location, dea.date, population, CONVERT(bigint,vac.new_vaccinations) as new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea 
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, CONVERT(bigint,vac.new_vaccinations) as new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea 
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, population, CONVERT(bigint,vac.new_vaccinations) as new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea 
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null





	

