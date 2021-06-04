Select *
From PortfolioProject..[Covid Deaths]
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..[dbo.Covid Vaccinations]
--order by 3,4
Select Location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..[Covid Deaths]
order by 1,2

--Total Cases vs Total Deaths
--Shows Likelyhood of dying if you cantact covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..[Covid Deaths]
Where location like '%states%'
order by 1,2

--Total Cases vs. Population
-- shows percentage that got covid

Select Location, date, Population, total_cases, (total_cases/Population)* 100 as PercentofPopulationInfected
From PortfolioProject..[Covid Deaths]
--Where location like '%states%'
order by 1,2

-- Counteries with highest Infection rate compare to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))* 100 as PercentofPopulationInfected
From PortfolioProject..[Covid Deaths]
--Where location like '%states%'
Group by Location, Population
order by PercentofPopulationInfected desc

-- Countries with HighestDeathCount per Population

Select Location, MAX(cast(Total_deaths as int)) as  TotalDeathCount
From PortfolioProject..[Covid Deaths]
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--By Continent
-- Continents with HighestDeathCount
Select continent, MAX(cast(Total_deaths as int)) as  TotalDeathCount
From PortfolioProject..[Covid Deaths]
--Where location like '%states%'
Where continent is not  null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select  SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From PortfolioProject..[Covid Deaths]
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


-- Total Polulation vs Vaccination 

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVccinated
--, (RollingPeopleVccinated/ population)*100
From PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[dbo.Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVccinated/ population)*100
From PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[dbo.Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[dbo.Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Data for Visulizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[dbo.Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated






