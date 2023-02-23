---select * from [Portfolio Project]..CovidDeaths
----order by 3,4

select Location, date, total_cases, new_cases, total_deaths, Population
from [Portfolio Project]..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from [Portfolio Project]..CovidDeaths
where location like ('%states%')
order by 1,2

-- Looking at total cases vs population
select Location, date, total_cases, population, (total_cases/population)*100 as casepercentage
from [Portfolio Project]..CovidDeaths
-- where location like ('%states%')
order by 1,2

-- Looking at highest infection rate vs pop
select Location, Max(total_cases) as highestinfectioncount, population, Max(total_cases/population)*100 as percentpopinfected
from [Portfolio Project]..CovidDeaths
-- where location like ('%states%')
group by location, population
order by 4 desc

-- showing countries with highest death rate per pop
select Location, Max(total_deaths) as highestdeathcount, population, Max(total_deaths/population)*100 as percentpopdeaths
from [Portfolio Project]..CovidDeaths
-- where location like ('%states%')
group by location, population
order by 4 desc

-- showing countries with highest death count 
select Location, Max(cast (total_deaths as int)) as highestdeathcount
from [Portfolio Project]..CovidDeaths
-- where location like ('%states%')
where continent is not null
group by location
order by 2 desc


-- Lets break things down by continent
select continent, Max(cast (total_deaths as int)) as highestdeathcount
from [Portfolio Project]..CovidDeaths
-- where location like ('%states%')
where continent is not null
group by continent
order by 2 desc

-- Global numbers
select date, sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/sum(new_cases) as deathpercentage ---, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from [Portfolio Project]..CovidDeaths
---where location like '%states%'
where continent is not null
group by date
order by 1,2


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacs vac
	On dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
Order by 2,3

--- Use CTE
with PopvsVac (continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacs vac
	On dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--Order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent Nvarchar(255), 
Location Nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacs vac
	On dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--Order by 2,3

Select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualisations
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacs vac
	On dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--Order by 2,3

select * 
From PercentPopulationVaccinated