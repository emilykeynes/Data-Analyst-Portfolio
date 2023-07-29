Select *
From PortfolioProjct..coviddeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProjct..covidvaccinatons$
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjct..coviddeaths$
Where continent is not null
order by 1,2

-- Change column type varchar to int

Select *
From coviddeaths$

Exec sp_help 'coviddeaths$';

Alter table coviddeaths$
Alter column total_cases bigint

Alter table coviddeaths$
Alter column total_deaths bigint


-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjct..coviddeaths$
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Tota Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjct..coviddeaths$
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjct..coviddeaths$
-- where location like '%states%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProjct..coviddeaths$
-- where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY LOCATION (NULL)

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProjct..coviddeaths$
-- where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT (NOT NULL)

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProjct..coviddeaths$
-- where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProjct..coviddeaths$
-- where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjct..coviddeaths$
-- where location like '%states%'
Where continent is not null
-- Group by date
order by 1,2


-- Join two sets of data

Select *
From PortfolioProjct..coviddeaths$ dea
Join PortfolioProjct..covidvaccinatons$ vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProjct..coviddeaths$ dea
Join PortfolioProjct..covidvaccinatons$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProjct..coviddeaths$ dea
Join PortfolioProjct..covidvaccinatons$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProjct..coviddeaths$ dea
Join PortfolioProjct..covidvaccinatons$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProjct..coviddeaths$ dea
Join PortfolioProjct..covidvaccinatons$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

