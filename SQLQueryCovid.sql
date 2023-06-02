select location, date, total_cases,new_cases,total_deaths,population
from CovidProject..CovidDeaths
order by 1,2

--total cases vs total deaths
select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths where location like '%orocc%'
order by 1,2

--total cases vs population
select location, date, total_cases,population , (total_cases/population)*100 as CasesPercentage
from CovidProject..CovidDeaths where location like '%orocc%'
order by 1,2

-- location with Highest AFFECT compare with Population
select location,population ,MAX(total_cases) as HighestAFFECT, MAX((total_cases/population))*100 as CasesPercentage
from CovidProject..CovidDeaths 
GROUP BY location,population
order by CasesPercentage desc

--Location with highest death Cases
select location, MAX(CAST(total_deaths as INT)) as MaxDeath
from CovidProject..CovidDeaths where continent is not null
group by location
order by 2 desc

--continent with highest death Cases
select location, MAX(CAST(total_deaths as INT)) as MaxDeath
from CovidProject..CovidDeaths where continent is null
group by location
order by 2 desc

--total population vs vaccination
select Dea.location,Dea.date, Dea.population,Vacc.new_vaccinations,
sum(convert(int,Vacc.new_vaccinations)) 
over (partition by Vacc.location order by Vacc.location,Vacc.date) as RollingPeopVacc
from CovidProject..CovidDeaths Dea Join CovidProject..CovidVaccinations Vacc
ON Dea.location=Vacc.location AND Dea.date=Vacc.date
where Dea.continent is not null
and Dea.new_vaccinations is not null

--select Dea.location, Dea.population,sum(convert(int,Vacc.new_vaccinations))
--from CovidProject..CovidDeaths Dea Join CovidProject..CovidVaccinations Vacc
--ON Dea.location=Vacc.location AND Dea.date=Vacc.date
--group by Dea.location,Dea.population
--order by 3 desc

--total population vs vaccination
--use CTE:
with PopVsVacc (continent,location,date,population,new_vaccinations,RollingPeopVacc)
as (
select Dea.continent,Dea.location,Dea.date, Dea.population,Vacc.new_vaccinations,
sum(convert(int,Vacc.new_vaccinations)) 
over (partition by Vacc.location order by Vacc.location,Vacc.date) as RollingPeopVacc
from CovidProject..CovidDeaths Dea Join CovidProject..CovidVaccinations Vacc
ON Dea.location=Vacc.location AND Dea.date=Vacc.date
where Dea.continent is not null 
)
select *, (RollingPeopVacc/population)*100 as PercPopuVacc
from PopVsVacc where new_vaccinations is not null



--use Temp Table
drop table if exists #PercentPOpulationVaccinated
create table #PercentPOpulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
RollingPeopVacc int
)
insert into #PercentPOpulationVaccinated
select Dea.continent,Dea.location,Dea.date, Dea.population,Vacc.new_vaccinations,
sum(convert(int,Vacc.new_vaccinations)) 
over (partition by Vacc.location order by Vacc.location,Vacc.date) as RollingPeopVacc
from CovidProject..CovidDeaths Dea Join CovidProject..CovidVaccinations Vacc
ON Dea.location=Vacc.location AND Dea.date=Vacc.date
where Dea.continent is not null 
and Vacc.new_vaccinations is not null

select *, (RollingPeopVacc/population)*100 as PercPopuVacc
from #PercentPOpulationVaccinated

--Creating View to store Data visualization 
create view PercentPopuVacci as 
select Dea.continent,Dea.location,Dea.date, Dea.population,Vacc.new_vaccinations,
sum(convert(int,Vacc.new_vaccinations)) 
over (partition by Vacc.location order by Vacc.location,Vacc.date) as RollingPeopVacc
from CovidProject..CovidDeaths Dea Join CovidProject..CovidVaccinations Vacc
ON Dea.location=Vacc.location AND Dea.date=Vacc.date
where Dea.continent is not null 

select * from PercentPopuVacci




