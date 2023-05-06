SELECT * 
FROM coviddeath
ORDER BY 3,4;

#SELECT *
#FROM covidvaccination
#order by 3,4

#select data that I am going to use
SELECT Location, date, total_cases, new_cases, total_deaths, population
from coviddeath
order by 1,2

#looking at total cases vs total deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from coviddeath
where location like '%Canada%'
order by 1,2

#looking at total cases vs population
#percentage of population got covid
SELECT Location, date, Population,total_cases, (total_cases/Population)*100 as PercentPopulationInfected 
from coviddeath
#where location like '%Canada%'
order by 1,2


#looking at countries with Highest Infection Rate compared to Population
SELECT Location, Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected 
from coviddeath
#where location like '%Canada%'
GROUP BY Location, Population
order by PercentPopulationInfected desc

#showing countries with highest death count per population
SELECT Location, CAST(MAX(Total_deaths) AS SIGNED) as TotalDeathCount
from coviddeath
#where location like '%Canada%'
WHERE continent is not null
GROUP BY Location
order by TotalDeathCount desc

#Let's break things down by continent
SELECT continent, CAST(MAX(Total_deaths) AS SIGNED) as TotalDeathCount
from coviddeath
#where location like '%Canada%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc

#showing continents with the highest death count per population

SELECT continent, CAST(MAX(Total_deaths) AS SIGNED) as TotalDeathCount
from coviddeath
#where location like '%Canada%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc

#global numbers
SELECT SUM(new_cases) as total_cases , CAST(SUM(new_deaths) AS SIGNED) as total_deaths, SUM(new_deaths)/CAST(SUM(new_cases) AS SIGNED)*100 as DeathPercentage
FROM coviddeath
WHERE continent is not null
GROUP BY date
order by 1,2

#Looking at total population vs vaccinations
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
SELECT coviddeath.continent, coviddeath.location, coviddeath.date, coviddeath.population, covidvaccination.new_vaccinations, 
SUM(covidvaccination.new_vaccinations) OVER (Partition by coviddeath.location, coviddeath.date) as RollingPeopleVaccinated
FROM coviddeath 
JOIN covidvaccination ON coviddeath.location = covidvaccination.location AND coviddeath.date = covidvaccination.date
JOIN (
	SELECT location, date, SUM(new_vaccinations) AS total_new_vaccinations
    FROM covidvaccination
    GROUP BY location, date
) tv on covidvaccination.location= tv.location and covidvaccination.date= tv.date

WHERE coviddeath.continent IS NOT NULL
)
select * ,(RollingPeopleVaccinated/Population)*100
from PopvsVac;

#Creating view to store data for later visualization
Create View PercentPopulationVaccinatedView as
SELECT coviddeath.continent, coviddeath.location, coviddeath.date, coviddeath.population, covidvaccination.new_vaccinations, 
SUM(covidvaccination.new_vaccinations) OVER (Partition by coviddeath.location, coviddeath.date) as RollingPeopleVaccinated
FROM coviddeath 
JOIN covidvaccination ON coviddeath.location = covidvaccination.location AND coviddeath.date = covidvaccination.date
JOIN (
	SELECT location, date, SUM(new_vaccinations) AS total_new_vaccinations
    FROM covidvaccination
    GROUP BY location, date
) tv on covidvaccination.location= tv.location and covidvaccination.date= tv.date

WHERE coviddeath.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated

