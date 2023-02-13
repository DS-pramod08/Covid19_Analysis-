select * from [dbo].[Covid_Deaths] order by 3,4;


--select data that we are going to using

select location, date, total_cases, new_cases, total_deaths, population 
from [dbo].[Covid_Deaths]
where continent is not null
order by 1,2;



--Looking at the Total_cases vs Total_Deaths

select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as Deaths_Percentage
from [dbo].[Covid_Deaths]
where continent is not null
order by 1,2;



--Looking at Total_cases vs Population

select location, date,population, total_cases, (total_cases/population)*100 as Percentage_Population_Infected  
from [dbo].[Covid_Deaths]
where location like '%India%'
and continent is not null
order by 1,2;



--Looking at Countries with Highest Infection rate compared to Population

select location,population,MAX(total_cases) as Highest_infection_Count, MAX((total_cases/population))*100 as Percentage_Population_Infected 
from [dbo].[Covid_Deaths] 
where continent is not null
group by location,population
order by Percentage_Population_Infected desc;



--Showing Countries with Highest Death count per Population
--Cast - It is used to change data types directly in query to show the result.

select location,MAX(CAST(total_deaths as int)) as Highest_Death_Count 
from [dbo].[Covid_Deaths]
where continent is not null
group by location
order by Highest_Death_Count desc;



--By Continents

select continent,MAX(CAST(total_deaths as int)) as Highest_Death_Count 
from [dbo].[Covid_Deaths]
where continent is not null
group by continent
order by Highest_Death_Count desc;



-- Global Number

select date,SUM(total_cases) as Sum_Total_Cases,SUM(cast(new_deaths as int)) as Sum_New_Deaths,sum(cast(new_deaths as int)) / sum(new_cases)*100 as Death_percentage 
from [dbo].[Covid_Deaths]
where continent is not null
group by date
order by 1,2;




select * from [dbo].[Covid_Vaccinations] order by 3,4;


-- Join Two Tables

select *
from [dbo].[Covid_Deaths] Deaths
join [dbo].[Covid_Vaccinations] Vaccination
on Deaths.location = Vaccination.location
and deaths.date = Vaccination.date;



-- Looking at Total_population vs vaccination
--While all your sizes can fit into INT (up to 2^31 - 1), their SUM cannot. 
--'Bigint' used for casting in below example.

select Deaths.continent,Deaths.location,Deaths.date,Deaths.population,Vaccination.new_vaccinations,
sum(cast(Vaccination.new_vaccinations as bigint))
over (Partition by Deaths.location order by deaths.location,deaths.date) as Rolling_people_vaccinated
from [dbo].[Covid_Deaths] Deaths
join [dbo].[Covid_Vaccinations] Vaccination
on Deaths.location = Vaccination.location
and deaths.date = Vaccination.date
where deaths.continent is not null
order by 2,3;


-- CTE use

with Population_vs_Vaccination (continent,location,date,population,Rolling_people_vaccinated,new_vaccination)
as (
select Deaths.continent,Deaths.location,Deaths.date,Deaths.population,Vaccination.new_vaccinations,
sum(cast(Vaccination.new_vaccinations as bigint))
over (Partition by Deaths.location order by deaths.location,deaths.date) as Rolling_people_vaccinated
from [dbo].[Covid_Deaths] Deaths
join [dbo].[Covid_Vaccinations] Vaccination
on Deaths.location = Vaccination.location
and deaths.date = Vaccination.date
where deaths.continent is not null
)
select *, (Rolling_people_vaccinated/population)*100 
from Population_vs_Vaccination;


-- Temp Table

drop table if exists #PercentagePopulationVaccinated --(use this command if table already exists it will drop)
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
loacation nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
Rolling_people_vaccinated numeric
)

insert into #PercentagePopulationVaccinated
select Deaths.continent,Deaths.location,Deaths.date,Deaths.population,Vaccination.new_vaccinations,
sum(cast(Vaccination.new_vaccinations as bigint))
over (Partition by Deaths.location order by deaths.location,deaths.date) as Rolling_people_vaccinated
from [dbo].[Covid_Deaths] Deaths
join [dbo].[Covid_Vaccinations] Vaccination
on Deaths.location = Vaccination.location
and deaths.date = Vaccination.date
where deaths.continent is not null

select *, (Rolling_people_vaccinated/population)*100 
from #PercentagePopulationVaccinated;



--creating views to store data for later visulization

create view PercentagePopulationVaccinated as 
select Deaths.continent,Deaths.location,Deaths.date,Deaths.population,Vaccination.new_vaccinations,
sum(cast(Vaccination.new_vaccinations as bigint))
over (Partition by Deaths.location order by deaths.location,deaths.date) as Rolling_people_vaccinated
from [dbo].[Covid_Deaths] Deaths
join [dbo].[Covid_Vaccinations] Vaccination
on Deaths.location = Vaccination.location
and deaths.date = Vaccination.date
where deaths.continent is not null;

select *
from PercentagePopulationVaccinated;