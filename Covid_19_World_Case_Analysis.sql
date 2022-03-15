SELECT * 
FROM CovidData..CovidDeaths

-- Filtering the data for analysis

SELECT location, date, population,total_cases,new_cases,total_deaths,new_deaths,reproduction_rate,icu_patients,hosp_patients
FROM CovidData..CovidDeaths
WHERE continent is not null
order by 1,2

------Covid Cases Analysis

---Analysis at Country level

--Showing Top 15 Countries with Most Covid Cases
SELECT TOP 15 location, MAX(total_cases) as Total_Cases
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Cases desc

--List of Most Cases in a single day
SELECT TOP 15 location,date, new_cases as Cases
FROM CovidData..CovidDeaths
WHERE continent is not null
ORDER BY Cases desc

--Showing Top 15 Countries with Cumulative Death Count
SELECT TOP 15 location, MAX(total_deaths) as Total_Deaths
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Deaths desc

--List of Most Death in a single day
SELECT TOP 15 location,date, new_deaths as Deaths
FROM CovidData..CovidDeaths
WHERE continent is not null
ORDER BY Deaths desc

--Showing Top 15 Countries with Most Positive cases per capita
SELECT TOP 15 location, MAX(total_cases) as Total_Cases
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Cases desc

--Showing Top 15 Countries with highest Infection Rate
SELECT TOP 15 location, population, MAX(total_cases) as Total_Cases, (MAX(total_cases)/ population)*100 as Infection_Rate
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY Infection_Rate desc

--Showing Top 15 Countries with highest Case Fatality Rate
SELECT TOP 15 location, MAX(total_deaths) as Total_Deaths, MAX(total_cases) as Total_Cases, (MAX(total_deaths)/ MAX(total_cases))*100 as Fatality_Rate
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Fatality_Rate desc

--Showing Top 15 Countries with highest Mortality Rate
SELECT TOP 15 location, MAX(total_deaths) as Total_Deaths, population, (MAX(total_deaths)/ population)*100 as Mortality_Rate
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Mortality_Rate desc

--List of Countries with their highest Ratio of ICU to Hospitalised Patients on a single day with atleast 100 patients in Hospital
WITH IcuvsHosp (Location,Date,icu_patients,hosp_patients,ICU_to_Hosp)
as
(
	SELECT location,date,icu_patients,  hosp_patients, (icu_patients/ (icu_patients + hosp_patients)) as ICU_to_Hosp
	FROM CovidData..CovidDeaths
	WHERE continent is not null and icu_patients + hosp_patients >100
)

SELECT Location, MAX(ICU_to_Hosp) as ICU_to_Hosp
FROM IcuvsHosp
GROUP BY Location
ORDER BY ICU_to_Hosp desc


---Analysis at Continent level


--Showing Continents with their Total Confirmed Cases, Total Death Count, Death to Case Ratio along with their population size
 
--Creating a blank table to store Continent and Population
DROP Table if exists #ContinentLevel
Create Table #ContinentLevel
(
Continent nvarchar(255),
Population numeric,
)

--Inserting Continent and Population values into the table
INSERT INTO #ContinentLevel (Continent,Population)
Select   continent,  SUM(population) as population
From
	(
		SELECT DISTINCT continent,  population
		FROM CovidData..CovidDeaths
		WHERE continent is not null
	) 
	as temp
	GROUP BY continent
	ORDER BY continent 


--Creating a temporary table which stores continent, total cases and total death values
--Joining this temporary table with above table to calculate the Death_to_Case_Ratio
WITH temp (continent,Total_Cases,Total_Deaths)
as
	(
	SELECT DISTINCT continent,SUM(new_cases) OVER (Partition by continent ) as Total_Cases, SUM(new_deaths) OVER (Partition by continent ) as Total_Deaths
	FROM CovidData..CovidDeaths
	WHERE continent is not null
	)
SELECT * , (Total_Deaths/Total_Cases)*100 AS Fatality_Rate, (Total_Deaths/Population)*100 AS Mortality_Rate, (Total_Cases/Population)*100 AS Infection_Rate
from #ContinentLevel c
JOIN temp t
ON c.Continent=t.continent


---Analysis at Global level

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidData..CovidDeaths
where continent is not null 
order by 1,2


-- Creating View to store data for later visualizations

Create View TableauView as
SELECT location, date, population,total_cases,new_cases,total_deaths,new_deaths,reproduction_rate,icu_patients,hosp_patients
FROM CovidData..CovidDeaths
WHERE continent is not null