DROP TABLE IF EXISTS netflix;
create table netflix(
	show_id	VARCHAR(6),
	type	VARCHAR(10),
	title	VARCHAR(150),
	director	VARCHAR(210),
	castS	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(150),
	description VARCHAR(250)

)


SELECT * FROM netflix;

-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

select 
	type,
	count(*) as total_content
from netflix;
group by type;
--2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

--3. List all movies released in a specific year (e.g., 2020)

select * from netflix where type = 'Movie' and release_year = 2020

--4. Find the top 5 countries with the most content on Netflix
select * from netflix
select 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country , --unnest used separate the each item in array
	COUNT(show_id) as no_of_content
from netflix
group by 1
order by 2 desc
limit 5
--5. Identify the longest movie

select * from netflix where 
	type = 'Movie'
	and
	duration = (select max(duration) from netflix) --subquery

--6. Find content added in the last 5 years

select * from netflix where
	TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 years'
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix where director ilike '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons

select 
	*
from netflix where
	type = 'TV Show'
	and
	SPLIT_PART(duration, ' ',1)::numeric >5

--9. Count the number of content items in each genre

select 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as Genre,
	count(show_id)
from netflix
group by 1

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
	select 
		extract(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) AS year,
		count(*) as yearly_content,
		ROUND(count(*)::numeric / (select count(*) from netflix where country = 'India')::numeric*100, 2) as avg_count
	from netflix
	where
		country = 'India'
		group by 1
--11. List all movies that are documentaries

select * from netflix where listed_in ILIKE 'Documentaries'

--12. Find all content without a director

select * from netflix where director IS NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * from netflix where
	casts ILIKE '%Salman Khan%'
	and
	release_year > extract(year from CURRENT_DATE)-10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
UNNEST(STRING_TO_ARRAY(casts , ',')) as actors,
count(*) as total_content
from netflix
where country ilike '%india%'
group by 1
order by 2 desc
limit 10


15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

with table_new
as 
(
select 
*,
case when description ilike '%kill%' or 
		  description ilike '%violence%' then 'bad' 
		  else 'good'
	 end category
from netflix
)

select 
category,
count(*) as total
from table_new
group by 1


