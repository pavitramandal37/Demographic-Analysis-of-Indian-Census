-- to veiw dataset
select * from sql_project_1.dbo.Data1;
select * from sql_project_1.dbo.Data1;

-- to veiw number of rows in dataset
select COUNT(*) from sql_project_1.dbo.Data1;
select COUNT(*) from sql_project_1.dbo.Data2;

-- dataset for jharkhand and bihar
select * from sql_project_1..Data1 where State in ('jharkhand', 'bihar');

-- Population of India
select SUM(Population) as 'Population' from sql_project_1..Data2;

-- Average growth of India 
select * from sql_project_1..Data1;
select CONCAT(AVG(growth)*100, '%') as 'AverageGrowth' from sql_project_1..Data1;

-- Average growth per state
select State, CONCAT(AVG(growth)*100, '%') as 'Avg_Growth' from sql_project_1..Data1
group by State
order by AVG(growth) desc;

-- Average sex ratio per state
select State, ROUND(AVG(Sex_Ratio), 2) as 'Avg_Sex_Ratio' from sql_project_1..Data1
group by State
order by AVG(Sex_Ratio) desc;

-- Average Literacy Rate per state and get literate state greater than 90
select State, AVG(Literacy) as 'Avg_Literacy' from sql_project_1..Data1
group by State
order by AVG(Literacy) desc;

select State, AVG(Literacy) as 'Avg_Literacy' from sql_project_1..Data1
group by State
having AVG(Literacy) > 90
order by AVG(Literacy) desc;

--  Create table of top 3 state in literacy

create table #topstates (
state nvarchar(255),
Literacy float);

insert into #topstates
select top 3 State, ROUND(AVG(Literacy),0) as 'Literacy' from sql_project_1..Data1
group by State
order by AVG(Literacy) desc;

select * from #topstates;

--  Create table of bottom 3 state in literacy

create table #bottomstates (
state nvarchar(255),
Literacy float);

insert into #bottomstates
select top 3 State, ROUND(AVG(Literacy), 0) as 'Literacy' from sql_project_1..Data1
group by State
order by AVG(Literacy);

select * from #bottomstates;

-- union #topstates & #bottomstates in single table

(select * from #topstates
union
select * from #bottomstates)
ORDER BY Literacy desc;

-- name the states which are start with letter A

select distinct State from sql_project_1..Data1
where lower(State) like 'a%' or lower(State) like 'm%';

-- No of male and female by using sex ratio and population
/* 
sex ratio = female/male  & population = male + female then female = pop - male
sex ratio = (pop - male)/male or sex ratio = pop/male - 1
---------- male = pop/(sex ratio + 1)

pop = pop/(sex ratio + 1) + female 
pop(sex ratio + 1) = pop + female(sex ratio + 1)
---------- female = (pop * sex ratio)/(sex ratio + 1) 

format: Group SUM of male and female by States(
        Put formula to get the No of male and female(
        Convert Sex_ratio to decimal)))
*/

select b.State, SUM(Male) Total_Males, SUM(FEMALE) Total_Females from
(select a.State, a.District, ROUND(a.Population/(a.Sex_Ratio +1),0) Male, ROUND((a.Population*a.Sex_Ratio)/(a.Sex_Ratio + 1),0) Female from
(select d1.State, d1.District, d1.Sex_Ratio/1000 as Sex_Ratio, d2.Population from sql_project_1..Data1 as d1
inner join sql_project_1..Data2 as d2 on d1.District = d2.District) a) b
group by b.State
order by State;

-- Tabel for No. of Males and Females

create table Male_Female_count (
State nvarchar(255),
District nvarchar(255),
Sex_ratio float,
Population float,
Male int,
Female int);

insert into Male_Female_count
select a.State, a.District, a.Sex_Ratio, a.Population, ROUND(a.Population/(a.Sex_Ratio +1),0) Male, ROUND((a.Population*a.Sex_Ratio)/(a.Sex_Ratio + 1),0) Female from
(select d1.State, d1.District, d1.Sex_Ratio/1000 as Sex_Ratio, d2.Population from sql_project_1..Data1 as d1
inner join sql_project_1..Data2 as d2 on d1.District = d2.District) a
order by State;

select * from Male_Female_count order by State;

-- No. of Literate and Illiterate peoples
/* 
Literacy Rate = Literate People/Population therefore, ---- Literate People = Literacy rate* Population

Illiterate People = (1 - Literate People)*Population
*/

select a.State, a.District, ROUND(a.Literacy*a.Population,0) Literate_People, ROUND(Illiteracy*Population,0) Illiterate_People from
(select d1.State, d1.District, d1.Literacy/100 Literacy, (100 - d1.Literacy)/100 Illiteracy, d2.Population from sql_project_1..Data1 as d1
inner join sql_project_1..Data2 as d2 on d1.District = d2.District) a;

-- Table for Literate and Illiterate peoples
drop table #Literacy_count;
create table Literacy_count (
State nvarchar(255),
District nvarchar(255),
Literate_People int,
Illiterate_People int);

insert into Literacy_count 
select a.State, a.District, ROUND(a.Literacy*a.Population,0) Literate_People, ROUND(Illiteracy*Population,0) Illiterate_People from
(select d1.State, d1.District, d1.Literacy/100 Literacy, (100 - d1.Literacy)/100 Illiteracy, d2.Population from sql_project_1..Data1 as d1
inner join sql_project_1..Data2 as d2 on d1.District = d2.District) a;

select * from Literacy_count;

-- Population of previous census 
-- Hint: Use Growth rate
-- current population = previous population + previous population * Growth rate
-- previous population = cuurent population / (1 + Growth rate)

select SUM(b.Current_Population) Current_Census_Population, SUM(b.Pervious_Population) Pervious_Census_Population from
(select a.State, a.District, a.Growth, a.Population as Current_Population, ROUND(a.Population/(1+ a.Growth),0) Pervious_Population from
(select d1.State, d1.District, d2.Population, d1.Growth from sql_project_1..Data1 as d1
inner join sql_project_1..Data2 as d2 on d1.District = d2.District) a) b;

-- Create table for Pervious_Census_Population

create table Pervious_Census_Population (
State nvarchar(255),
District nvarchar(255),
Growth float,
Current_Population int,
Pervious_Population int);

insert into Pervious_Census_Population
select a.State, a.District, a.Growth, a.Population as Current_Population, ROUND(a.Population/(1+ a.Growth),0) Pervious_Population from
(select d1.State, d1.District, d2.Population, d1.Growth from sql_project_1..Data1 as d1
inner join sql_project_1..Data2 as d2 on d1.District = d2.District) a;

select * from Pervious_Census_Population;

-- Population vs Area of all District
select a.State, a.District, a.Area_km2/a.Current_Population Current_Population_vs_Area, a.Area_km2/a.Pervious_Population Pervious_Population_vs_Area from
(select d1.State, d1.District, d1.Current_Population, d1.Pervious_Population, d2.Area_km2 from Pervious_Census_Population as d1
inner join sql_project_1..Data2 as d2 on d1.District = d2.District) a

-- table for Population vs Area of all District
create table Population_vs_Area(
State nvarchar(255),
District nvarchar(255),
Current_Population_vs_Area float,
Pervious_Population_vs_Area float);

insert into Population_vs_Area
select a.State, a.District, a.Area_km2/a.Current_Population Current_Population_vs_Area, a.Area_km2/a.Pervious_Population Pervious_Population_vs_Area from
(select d1.State, d1.District, d1.Current_Population, d1.Pervious_Population, d2.Area_km2 from Pervious_Census_Population as d1
inner join sql_project_1..Data2 as d2 on d1.District = d2.District) a

select * from Population_vs_Area;

-- Population vs Area of all States
select b.State, b.Area_km2/b.Current_Population Current_Population_vs_Area, b.Area_km2/b.Pervious_Population Pervious_Population_vs_Area from
(select a.State, Current_Population, Pervious_Population, Area_km2 from
(select State, SUM(Cur
rent_Population) Current_Population, SUM(Pervious_Population) Pervious_Population from Pervious_Census_Population
group by State) a 
inner join (select State, SUM(Area_km2) Area_km2 from sql_project_1..Data2 group by State) as b on a.State = b.State) b

-- Population vs Area of India

select c.Area_km2/c.Current_Population Current_Population_vs_Area, c.Area_km2/c.Pervious_Population Pervious_Population_vs_Area from

(select a1.*, b1.Area_km2 from(

select '1' as id, a.* from
(select SUM(Current_Population) Current_Population, SUM(Pervious_Population) Pervious_Population from Pervious_Census_Population) a) a1

inner join
(
select '1' as id, b.* from
(select SUM(Area_km2) Area_km2 from sql_project_1..Data2) b) b1

on a1.id = b1.id) c

-- Get top 3 district from each state with highest litreacy

select a.* from 
(select State, District, Literacy, RANK() over(partition by State order by Literacy desc) rnk from sql_project_1..Data1) a
where a.rnk in (1, 2, 3)
order by Literacy desc 


-- Merge all columns into one table for Visualization

use sql_project_1;

select a.State as State, SUM(a.Growth), Avg(a.Sex_Ratio), Avg(a.Literacy), SUM(b.Population), SUM(b.Area_Km2), SUM(d.Male), SUM(d.Female), 
SUM(c.Literate_People), SUM(c.Illiterate_People), SUM(e.Pervious_Population), SUM(f.Pervious_Population_vs_Area from
(select * from sql_project_1..Data1) a,
(select * from sql_project_1..Data2) b,
(select * from sql_project_1..Literacy_count) c,
(select * from sql_project_1..Male_Female_count) d,
(select * from sql_project_1..Pervious_Census_Population) e,
(select * from sql_project_1..Population_vs_Area) f
group by a.State;
