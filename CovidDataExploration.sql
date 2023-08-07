select * from PortfolioProject..covidDeaths 
where continent is not NULL
order by 3,4;

--select * from PortfolioProject..covidVaccination order by 3,4;

-- Total cases vs total deaths
--Shows the Likelihood of dying if you contract covid in Senegal
select [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProject..covidDeaths
 where [location] like '%Senegal%'
 order by 1, 2;

 --The total cases vs population 
 --Shows what percentage of population got covid
 select a.[location], a.[date], b.population, a.total_cases, (a.total_deaths/b.population)*100 as PercentPopulationInfected
 from PortfolioProject..covidDeaths a, PortfolioProject..covidVaccination b
 where a.[location] like '%Senegal%'
 order by 1, 2;

 --Countries with highest infection rate compared to population
select a.[location], b.population, MAX(a.total_cases) as HighestInfectionCount,
MAX((a.total_deaths/b.population))*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths a, PortfolioProject..covidVaccination b
GROUP BY a.[location], b.population
order by PercentPopulationInfected desc;


--Countries with highest death count per population
select [location], MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths 
where continent is not NULL
GROUP BY [location]
order by TotalDeathCount desc;

-- Continent with highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths 
where continent is not NULL
GROUP BY continent
order by TotalDeathCount desc;

--accurate ones
select [location], MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths 
where continent is NULL
GROUP BY [location]
order by TotalDeathCount desc;

--Global numbers --error "Arithmetic overflow" (division by zero or division that results in a very large number)
select [date], SUM(CAST(new_cases as float)) as new_cases, SUM(CAST(new_deaths as float)) as new_deaths,
SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100  as DeathPercentage
 from PortfolioProject..covidDeaths
 where continent is not null
 group by [date]
 order by 1, 2;

--Global numbers (handle division with NULLIF)
 SELECT
    [date],
    SUM(CAST(new_cases as float)) as total_cases,
    SUM(CAST(new_deaths as float)) as total_deaths,
    CASE
        WHEN SUM(CAST(new_cases as float)) <> 0 THEN
            SUM(CAST(new_deaths as float)) / NULLIF(SUM(CAST(new_cases as float)), 0) * 100
        ELSE
            NULL -- Handle division by zero case
    END as DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY [date]
ORDER BY 1,2;

--Global numbers death percentage accross the world
 SELECT
    SUM(CAST(new_cases as float)) as total_cases,
    SUM(CAST(new_deaths as float)) as total_deaths,
    CASE
        WHEN SUM(CAST(new_cases as float)) <> 0 THEN
            SUM(CAST(new_deaths as float)) / NULLIF(SUM(CAST(new_cases as float)), 0) * 100
        ELSE
            NULL -- Handle division by zero case
    END as DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent is not null
ORDER BY 1,2;

--total population vs Vaccination 
Select dea.continent, dea.[location], dea.[date], vac.population, vac.new_vaccinations,
SUM(Convert(float, vac.new_vaccinations)) 
over (partition by dea.[location] order by dea.location, dea.date) as RollingPeopleVaccinated-- sum of all the vaccinations by location
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccination vac
on dea.[location]=vac.[location]
and dea.[date]=vac.[date]
where dea.continent is not NULL
order by 2,3;

--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations,  RollingPeopleVaccinated)
as (
Select dea.continent, dea.[location], dea.[date], vac.population, vac.new_vaccinations,
SUM(Convert(float, vac.new_vaccinations)) 
over (partition by dea.[location] order by dea.location, dea.date) as RollingPeopleVaccinated-- sum of all the vaccinations by location
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccination vac
on dea.[location]=vac.[location]
and dea.[date]=vac.[date]
where dea.continent is not NULL
--order by 2,3
) 
Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp table
Drop table if EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC ,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.[location], dea.[date], vac.population, vac.new_vaccinations,
SUM(Convert(float, vac.new_vaccinations)) 
over (partition by dea.[location] order by dea.location, dea.date) as RollingPeopleVaccinated-- sum of all the vaccinations by location
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccination vac
on dea.[location]=vac.[location]
and dea.[date]=vac.[date]
--where dea.continent is not NULL
--order by 2,3
Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view for data Visualisation 

create view PercentPopulationVaccinated as 
Select dea.continent, dea.[location], dea.[date], vac.population, vac.new_vaccinations,
SUM(Convert(float, vac.new_vaccinations)) 
over (partition by dea.[location] order by dea.location, dea.date) as RollingPeopleVaccinated-- sum of all the vaccinations by location
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccination vac
on dea.[location]=vac.[location]
and dea.[date]=vac.[date]
where dea.continent is not NULL
--order by 2,3

 select * from PercentPopulationVaccinated;