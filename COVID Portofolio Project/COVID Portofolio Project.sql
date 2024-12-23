Select *
From PortofollioProject..CovidDeaths
order by 3,4

--select *
--from PortofollioProject..CovidVaccination
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortofollioProject..CovidDeaths
order by 1,2

--total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofollioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--total cases vs population
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortofollioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at the countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortofollioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected DESC

--LETS BREAK THINGS DOWN WITH CONTINENT
Select continent, MAX(cast(total_deaths as int)) as TotaltDeathCount
From PortofollioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotaltDeathCount DESC

--showing countries with highest deaths count per population
Select location, MAX(cast(total_deaths as int)) as TotaltDeathCount
From PortofollioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotaltDeathCount DESC

--Global numbers
select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortofollioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total popualtion vs vaccinations
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint))
OVER (partition by dea.location order by dea.location, dea.date	) as RollingPeopleVaccinated
from PortofollioProject..CovidDeaths dea
join PortofollioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint))
OVER (partition by dea.location order by dea.location, dea.date	) as RollingPeopleVaccinated
from PortofollioProject..CovidDeaths dea
join PortofollioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--create view for data visualization later
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint))
OVER (partition by dea.location order by dea.location, dea.date	) as RollingPeopleVaccinated
from PortofollioProject..CovidDeaths dea
join PortofollioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated