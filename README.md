# Netflix Movies and TV Shows Data Analysis using SQL

<img width="2226" height="678" alt="logo" src="https://github.com/user-attachments/assets/ddab7281-9e85-4bc8-888d-c8d192d4861e" />



## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select 
     type,
	 count(*) as  total_content
from netflix_titles
group by type

```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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

```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select * FROM netflix_titles 
where  release_year=2020 and type='Movie';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT
    TRIM(value) AS new_country,
    COUNT(show_id) AS total_content
FROM netflix_titles AS t
CROSS APPLY STRING_SPLIT(country, ',')
GROUP BY TRIM(value)
ORDER BY total_content DESC;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
select 
    *
from netflix_titles
where 
    type='Movie'
	and 
	duration = (select max(duration) from netflix_titles);
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix_titles
WHERE TRY_CONVERT(date, date_added, 107) >= DATEADD(YEAR, -5, GETDATE());
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT 
    t.*,
    LTRIM(RTRIM(value)) AS director_name
FROM netflix_titles AS t
CROSS APPLY STRING_SPLIT(t.director, ',')
WHERE LTRIM(RTRIM(value)) = 'Rajiv Chilaka';
;
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
 SELECT *
FROM netflix_titles
WHERE
      type = 'TV Show' and
      LEFT(duration, CHARINDEX(' ', duration + ' ') - 1)> 5 ;

```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    LTRIM(RTRIM(value)) AS genre,
    COUNT(show_id) AS total_titles
FROM netflix_titles 
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_titles DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql

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

```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select *
from netflix_titles
where 
listed_in like '% Documentaries'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql

select* from netflix_titles
where director is null

```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix_titles
WHERE cast LIKE '%Salman Khan%'
  AND release_year >= YEAR(GETDATE()) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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

```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Bhagyashree Dahima
- **LinkedIn**:https://www.linkedin.com/in/bhagyashree-dahima-337282291/
