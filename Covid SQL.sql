SELECT Location,date,total_cases,new_cases,total_deaths,population FROM CovidDeaths ORDER BY 1,2
--Death Percent
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercent
FROM CovidDeaths 
WHERE location = 'India'
ORDER BY 1,2

--Total Cases VS Population(People Got Infected Percent)
SELECT Location,date,total_cases,population,(total_cases/population)*100 AS InfectPercent 
FROM CovidDeaths
WHERE location LIKE '%states'
ORDER BY 1,2


--Countries with most InfectRate
SELECT Location,MAX(total_cases) AS MAX_CASE,population,MAX((total_cases/population))*100 AS InfectPercent 
FROM CovidDeaths 
GROUP BY location,population
ORDER BY InfectPercent desc
 

 
--Countries with most DiedRate
SELECT Location,population,MAX(cast(total_deaths as  int)) AS MAX_DEATH, MAX((total_deaths/total_cases)) AS DeathPercent
FROM CovidDeaths WHERE continent is NOT NULL
GROUP BY Location,population
ORDER BY DeathPercent desc

--Continent with most Deathcount
SELECT continent,MAX(cast(total_deaths as  int)) AS DeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY DeathCount desc

--Total population VS Vaccination
WITH popvsVAC (continent,location,date,Population,new_vaccination,RollingPeopleVaccinated)
AS (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
--USING CTE
SELECT *,(RollingPeopleVaccinated/Population)* 100 as new FROM popvsVAC

--USING TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


SELECT *,(RollingPeopleVaccinated/Population)* 100 as new FROM #PercentPopulationVaccinated

--CREATING VIEW
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 