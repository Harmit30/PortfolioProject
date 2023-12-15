-- shows what percentage of population got covid in India
select top (100) location, date, population, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- Looking at the countries with highest rate compared to population
select top (100) location, population, MAX(total_cases) as HighestInfectionCount, Max(cast(total_cases as float)/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null
group by location,population
order by PercentagePopulationInfected desc

--countris with highest death count per population
select top (100) location, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
group by location,population
order by totalDeathCount desc

select top (100) continent, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
group by continent
order by totalDeathCount desc

select top (100) location, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeaths 
where continent is  null
group by location
order by totalDeathCount desc

-- Continent with highest deathcount
select top (100) continent, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
group by continent
order by totalDeathCount desc


--Global Numbers
select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, (sum(cast(total_deaths as float))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and new_cases != 0
--group by date
order by 1,2


--join both tables
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
	--,(PeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--and dea.location like '%india%'
	--and vac.new_vaccinations is not null
order by 2,3

-- USE CTE
With PopvsVac(Continent, Location, date ,population, new_vaccination ,PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
	--,(PeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--order by 2,3
)
select *,(PeopleVaccinated/population)*100 
from PopvsVac


--TEMP Table
drop table if exists #PerecentagePopulationVaccinated
Create table #PerecentagePopulationVaccinated
(
	Continent nvarchar(255),
	location nvarchar(255),
	Date datetime,
	population numeric,
	new_vaccination numeric,
	peopleVaccinated numeric
)


insert into #PerecentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
	--,(PeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--order by 2,3

select *,(PeopleVaccinated/population)*100 
from #PerecentagePopulationVaccinated


--create View to store data for later for visulization
create view PerecentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
	--,(PeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--order by 2,3