

use covidDB

select * from  covidvaccinated;
select * from covidDeath;

---showing clunms from death table like location , date , total_cases , new_cases , total_deaths and population -----

select continent, location , date , total_cases , new_cases , total_deaths , population
from covidDeath
where continent  is not null
order by 2,3 ; 


--- Calulating the percentage of total deaths over total cases ----

select continent, location , date ,  total_cases  , new_cases , total_deaths  , population,
( cast(total_deaths as float) /cast(total_cases as float))*100 as deathpercentage 
from covidDeath
where continent  is not null
order by 2,3 ; 

---calculate  total percentage of people infected in the popluation  ---

select continent, location , date ,  total_cases  , new_cases , total_deaths  , population,
( cast(total_cases as float) / population )*100 as Infected_percentage
from covidDeath
where continent  is not null
order by 2,3 ; 

---Countries with highest  infected rate ---

select  location,population,  max(cast(total_cases as int)) as highest_infection_count,
max ( ( cast(total_cases as float) / population ))*100 as Highest_Infected_rate 
from covidDeath
group by location, population
order by  Highest_Infected_rate  desc;


----countries with highest death rate  ---

select  location,  max(cast(total_deaths as int )) as highest_death_count,
max ( ( cast(total_deaths as float) / population ))*100 as Highest_death_rate 
from covidDeath
where continent is not null
group by location
order by  Highest_death_rate  desc;

---At Global level  ----

---- continent with highest deathcount---

select  continent,  max(cast(total_deaths as int )) as death_count
from covidDeath
where continent is not null
group by continent
order by  death_count desc;


----new_cases  date wise at global level ---
select date,sum( new_cases ) as Total_new_case
from covidDeath
where continent is not null
group by date
order by 1;

---- calucating total deaths and  new_caes date wise at global level ---

select date, sum( new_cases ) as Total_new_case, sum(cast(new_deaths as float)) as total_deaths 
from covidDeath
where continent is not null 
group by date
order by 1,2;

----  shows Total cases , total deaths and total death percentage . 

select  sum( new_cases ) as Total_new_case, sum(cast(new_deaths as float)) as total_deaths , 
sum(cast(new_deaths as int))/sum (new_cases) *100 as total_death_percentage
from covidDeath
where continent is not null 
order by 1,2;

--- Joining 2 tables ----

select * 
from covidDeath  as death
join covidvaccinated  as vaccinated
on  death.location = vaccinated.location
and  death.date = vaccinated.date;


--- Total population  vs vacctination ----

     SELECT
			death.continent,
			death.location,
			death.date,
			death.population,
			vaccinated.new_vaccinations,
			SUM(CONVERT(BIGINT, vaccinated.new_vaccinations)) OVER (
				PARTITION BY death.location 
				ORDER BY death.date 
				ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			) AS Rolling_People_Vaccination
		FROM
			covidDeath AS death
		JOIN covidvaccinated AS vaccinated 
			ON death.location = vaccinated.location
											AND death.date = vaccinated.date
		WHERE
			death.continent IS NOT NULL
		ORDER BY death.location,death.date;
			



--- Percentage of people who got vaccinated ---
--( we will  use CTE to make a temp table )---

WITH my_CTE(continent,location,date,population,new_vaccinations, Rolling_People_Vaccination)
as(
		SELECT
			death.continent,
			death.location,
			death.date,
			death.population,
			vaccinated.new_vaccinations,
			SUM(CONVERT(BIGINT, vaccinated.new_vaccinations)) OVER (
				PARTITION BY death.location 
				ORDER BY death.date 
				ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			) AS Rolling_People_Vaccination
		FROM
			covidDeath AS death
		JOIN covidvaccinated AS vaccinated 
			ON death.location = vaccinated.location
											AND death.date = vaccinated.date
		WHERE
			death.continent IS NOT NULL
	)
	SELECT * , (Rolling_People_Vaccination/population)*100 as Percentage_people_vaccinated 
	FROM my_CTE;


---- Creating a view for later visulatisation ----

CREATE  VIEW  people_vaccinated as
     SELECT death.continent, death.location, death.date, death.population, vaccinated.new_vaccinations,
			SUM(CONVERT(BIGINT, vaccinated.new_vaccinations)) OVER (
				PARTITION BY death.location 
				ORDER BY death.date 
				ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			) AS Rolling_People_Vaccination
		FROM covidDeath AS death
		JOIN covidvaccinated AS vaccinated 
			ON death.location = vaccinated.location AND death.date = vaccinated.date
		WHERE death.continent IS NOT NULL;
	