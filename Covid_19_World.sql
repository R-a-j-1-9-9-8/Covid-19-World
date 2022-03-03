
Select *
From CovidData..CovidDeaths
Order by location, date

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidData..CovidDeaths
Where continent is not null 
order by 1,2

-- Showing Total Cases vs Total Deaths of respective countries as Death percentage

Select TOP 10 Location, MAX(total_cases) as total_cases, MAX(total_deaths) as total_deaths, (MAX(total_deaths)/MAX(total_cases))*100 as DeathPercentage
From CovidData..CovidDeaths
Where continent is not null 
Group by Location
order by 4 desc

-- Top 20 Countries with Highest Infection Rate compared to Population

Select TOP 20 Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidData..CovidDeaths
Where continent is not null 
Group by Location, Population
order by PercentPopulationInfected desc

-- Top 20 Countries with Highest Death Count per Population as well as their Mortality Rate

Select TOP 20 Location, Population, MAX(total_deaths) as TotalDeathCount,(MAX(total_deaths)/population)*100 as DeathPercentage
From CovidData..CovidDeaths
Where continent is not null 
Group by Location, Population
order by TotalDeathCount desc, DeathPercentage desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths )/SUM(New_Cases)*100 as DeathPercentage
From CovidData..CovidDeaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidData..CovidDeaths dea
Join CovidData..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
From PopvsVac


DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidData..CovidDeaths dea
Join CovidData..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinatedView as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidData..CovidDeaths dea
Join CovidData..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

