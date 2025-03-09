--Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE  netflix
(
	show_id	varchar(5),
	type	varchar(10),
	title	varchar(150),
	director varchar(208),	
	casts     varchar(1000),	
	country	  varchar(150),
	date_added	varchar(50),
	release_year INT,	
	rating	varchar(10),
	duration  varchar(10),	
	listed_in	varchar(100),
	description varchar(260)
);
SELECT * FROM netflix;

SELECT COUNT(*) as total_content
FROM netflix;

SELECT DISTINCT type
FROM netflix;


--1:count the number of movies and TV shows 
SELECT 
   type ,
   COUNT(*) as total_content
FROM netflix  
GROUP BY type


--2:find the most common rating for movies and TV shows
SELECT 
     type,
	 rating
FROM
(
	 SELECT 
	    type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*)DESC) as ranking
	FROM netflix
	GROUP BY 1,2
) as t1
WHERE 
   ranking = 1
--ORDER BY 1,3 DESC;


--3:list all movies released in a specific year (e.g.,2020)
SELECT * FROM netflix
WHERE 
    type = 'Movie'
	AND
	release_year = 2020;


--4:find the top 5 countries with the most content on Netflix
SELECT 
    UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id)as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5

'''SELECT
    UNNEST(STRING_TO_ARRAY(country,',')) as new_country
FROM netflix
'''


--5:identify the longest movie
SELECT *FROM netflix
WHERE
    type = 'Movie'
	AND
	duration = (SELECT MAX (duration)FROM netflix)


--6:find content added in the last 5 years
SELECT *
FROM netflix 
WHERE 
    TO_DATE(date_added,'Month DD, YYYY')>= CURRENT_DATE - INTERVAL '5 years'


--7:find all the movies and TV shows by director 'Rajiv Chilaka'
SELECT * FROM netflix
WHERE
    director ILIKE '%Rajiv Chilaka%'


--8:list all TV shows with more than 5 seasons
SELECT * FROM netflix
WHERE
    type = 'TV Show'
	AND
    CAST(SPLIT_PART(duration,' ',1)AS INTEGER) > 5


--9:count the number of content items in each genre
SELECT 
   UNNEST(STRING_TO_ARRAY(listed_in,',')),
   COUNT(show_id)as total_content
FROM netflix
GROUP BY 1


--10:find each year and the average number of content released by India on netflix,
--return top 5 year with highest avg content release
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD , YYYY'))as year,
	COUNT(*) as total_shows,
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric * 100 as avg_content
FROM netflix
WHERE 
    country = 'India'
GROUP BY 1


--11:list all the movies that are documentries
SELECT * FROM netflix 
WHERE
    listed_in ILIKE '%documentaries%'


--12:find all the content without a director
SELECT * FROM netflix
WHERE 
    director IS NULL


--13:find how many movies actor 'Salman Khan' appeared in last 10 years 
SELECT *  FROM netflix 
WHERE 
    casts ILIKE '%Salman Khan%'
	AND
	release_year >= EXTRACT(YEAR FROM CURRENT_DATE)-10


--14:find the top 10 actors who have appeared in the highest number of movies produced in India
SELECT
    UNNEST(STRING_TO_ARRAY(casts,','))as actors,
	COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY actors
ORDER BY total_content DESC
LIMIT 10


--15:categories the content based on the presence of the keywords 'Kill' and 
--'violence' in the description field. Label content containing these keywords
--as 'Bad' and all other content as 'Good'. Count how many items fall into each category
WITH new_table
AS(
   SELECT *,
	      CASE
		  WHEN
		      description ILIKE '%kill%'OR
			  description ILIKE '%violence%'THEN 'Bad_Content'
			  ElSE 'Good_Content'
		  END category
	FROM netflix
)
SELECT 
     category ,
	 COUNT (*) as total_content
FROM new_table
GROUP BY 1
