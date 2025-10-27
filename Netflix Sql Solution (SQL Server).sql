select* from netflix_titles

-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

select 
     type,
	 count(*) as  total_content
from netflix_titles
group by type

--2. Find the most common rating for movies and TV shows

 SELECT
    type,
    rating
FROM (
    SELECT
        type,
        rating,
        COUNT(*) AS total,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix_titles
    GROUP BY type, rating
) AS t1
WHERE ranking = 1;


--3. List all movies released in a specific year (e.g., 2020)

select *FROM netflix_titles
select * FROM netflix_titles 
where  release_year=2020 and type='Movie';


--4. Find the top 5 countries with the most content on Netflix

SELECT
    TRIM(value) AS new_country,
    COUNT(show_id) AS total_content
FROM netflix_titles AS t
CROSS APPLY STRING_SPLIT(country, ',')
GROUP BY TRIM(value)
ORDER BY total_content DESC;


--5. Identify the longest movie

select 
    *
from netflix_titles
where 
    type='Movie'
	and 
	duration = (select max(duration) from netflix_titles)


--6. Find content added in the last 5 years

SELECT *
FROM netflix_titles
WHERE TRY_CONVERT(date, date_added, 107) >= DATEADD(YEAR, -5, GETDATE());

 
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select 
   * from netflix_titles
   where director like '%Rajiv Chilaka%'


--8. List all TV shows with more than 5 seasons

  SELECT *
FROM netflix_titles
WHERE
      type = 'TV Show' and
      LEFT(duration, CHARINDEX(' ', duration + ' ') - 1)> 5 ;



--9. Count the number of content items in each genre

SELECT 
    LTRIM(RTRIM(value)) AS genre,
    COUNT(show_id) AS total_titles
FROM netflix_titles 
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_titles DESC;


--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

SELECT TOP 5
    YEAR(TRY_CONVERT(date, date_added, 107)) AS release_year,
    COUNT(*) AS total_titles,
    COUNT(*) * 1.0 / (
        SELECT COUNT(*) 
        FROM netflix_titles
        WHERE country LIKE '%India%'
          AND TRY_CONVERT(date, date_added, 107) IS NOT NULL
    ) * 100 AS avg_content_percentage
FROM netflix_titles
WHERE 
    country LIKE '%India%'
    AND TRY_CONVERT(date, date_added, 107) IS NOT NULL
GROUP BY YEAR(TRY_CONVERT(date, date_added, 107))
ORDER BY total_titles DESC;


--11. List all movies that are documentaries

select *
from netflix_titles
where 
listed_in like '% Documentaries'


--12. Find all content without a director

select* from netflix_titles
where director is null


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix_titles
WHERE cast LIKE '%Salman Khan%'
  AND release_year >= YEAR(GETDATE()) - 10;


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT TOP 10
    LTRIM(RTRIM(value)) AS actor,
    COUNT(*) AS total_movies
FROM netflix_titles 
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE 
    country LIKE '%India%'   -- Only titles produced in India
    AND type = 'Movie'       -- Only movies, not TV Shows
    AND cast IS NOT NULL    -- Avoid NULLs
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_movies DESC;


--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

SELECT
    *,
    CASE
        WHEN description LIKE '%kill%' 
          OR description LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS content_category
FROM netflix_titles;



SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN LOWER(description) LIKE '%kill%' 
              OR LOWER(description) LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_titles
) AS categorized_content
GROUP BY category;





