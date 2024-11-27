CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * from netflix

SELECT
	count (*) as total_content
FROM netflix

SELECT
	distinct type
from netflix

------------------------------------
-- data analysis - business problems
------------------------------------

--1. Count the number of Movies vs TV Shows

SELECT
	type,
	count(*) as total_contents
from netflix
group by 1

	
--2. Find the most common rating for movies and TV shows

WITH rating_ranking as
(
SELECT
	type,
	rating,
	count(*),
	rank() OVER(partition by type order by count(*) DESC) as ranking
FROM netflix
group by 1, 2
order by 1, 3 desc
)
SELECT 
	type,
	rating
FROM rating_ranking
WHERE ranking = 1

--3. List all movies released in a specific year (e.g., 2020)

select * from netflix
where 
	type = 'Movie'
	and
	release_year = 2020

--4. Find the top 5 countries with the most content on Netflix

select
	unnest(string_to_array(country,',')) as new_country,
	count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5

--5. Identify the longest movie

SELECT * from netflix
WHERE
	type = 'Movie'
	and
	duration = (select max(duration)
				from netflix)
	
--6. Find content added in the last 5 years

select * from netflix
where 
	to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years'


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix
where director ilike '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons

select * from netflix
where 
	type = 'TV Show'
	and
	split_part(duration,' ',1)::numeric > 5

--9. Count the number of content items in each genre

select
	unnest(string_to_array(listed_in, ',')) as genre,
	count(show_id) as total_content
from netflix
group by 1
order by 2 desc


--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

select 
	extract(year from to_date(date_added,'month DD, YYYY')) as year,
	count(*) as yearly_content,
	round(count(*)::numeric/(select count(*) from netflix where country ='India')::numeric*100,2) as avg_content_per_year
from netflix
WHERE country = 'India'
group by 1
order by 3 desc
limit 5

--11. List all movies that are documentaries

SELECT * from netflix
WHERE listed_in ilike '%Documentaries%'


--12. Find all content without a director

select * from netflix
where director is null

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select * from netflix
where
	casts ilike '%Salman Khan%'
	and
	release_year >= extract(year from current_date) - 10


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select
	unnest(string_to_array(casts, ',')) as actors,
	count(*) as total_content
from netflix
where country ilike '%India%'
group by actors
order by 2 desc
limit 10



--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

with cte as
(
SELECT 
	*,
	case
		when description ilike '%kill%' or description ilike '%violence%' then 'Bad_content'
		else 'Good_content'
	END as category
from netflix
)
SELECT
	category,
	count(*) as total_content
from cte
group by 1