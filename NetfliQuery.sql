--NETFLIX PROJECT

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

SELECT * FROM netflix;

--
-- ============================================
-- 1. Count the Number of Movies vs TV Shows
-- Objective: Determine the distribution of content types on Netflix
-- ============================================
SELECT 
    type,
    COUNT(*) AS total_count
FROM netflix
GROUP BY type;

-- ============================================
-- 2. Find the Most Common Rating for Movies and TV Shows
-- Objective: Identify the most frequently occurring rating for each type of content
-- ============================================
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

-- ============================================
-- 3. List All Movies Released in a Specific Year (e.g., 2020)
-- Objective: Retrieve all movies released in a specific year
-- ============================================
SELECT * 
FROM netflix
WHERE release_year = 2020;

-- ============================================
-- 4. Find the Top 5 Countries with the Most Content on Netflix
-- Objective: Identify the top 5 countries with the highest number of content items
-- ============================================
SELECT * 
FROM (
    SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY country
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

-- ============================================
-- 5. Identify the Longest Movie
-- Objective: Find the movie with the longest duration
-- ============================================
SELECT show_id, title, type, duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;

-- ============================================
-- 6. Find Content Added in the Last 5 Years
-- Objective: Retrieve content added to Netflix in the last 5 years
-- ============================================
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- ============================================
-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
-- Objective: List all content directed by 'Rajiv Chilaka'
-- ============================================
SELECT *
FROM (
    SELECT 
        *,
        TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';

-- ============================================
-- 8. List All TV Shows with More Than 5 Seasons
-- Objective: Identify TV shows with more than 5 seasons
-- ============================================
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

-- ============================================
-- 9. Count the Number of Content Items in Each Genre
-- Objective: Count the number of content items in each genre
-- ============================================
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY genre;

-- ============================================
-- 10. Find each year and the average numbers of content release in India
-- Objective: Return top 5 years with the highest avg content release
-- ============================================
SELECT 
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::NUMERIC / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::NUMERIC * 100, 2
    ) AS avg_release_percentage
FROM netflix
WHERE country = 'India'
GROUP BY release_year
ORDER BY avg_release_percentage DESC
LIMIT 5;

-- ============================================
-- 11. List All Movies that are Documentaries
-- Objective: Retrieve all movies classified as documentaries
-- ============================================
SELECT * 
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';

-- ============================================
-- 12. Find All Content Without a Director
-- Objective: List content that does not have a director
-- ============================================
SELECT * 
FROM netflix
WHERE director IS NULL;

-- ============================================
-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
-- Objective: Count movies featuring 'Salman Khan' in the last 10 years
-- ============================================
SELECT * 
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- ============================================
-- 14. Find the Top 10 Actors with the Most Appearances in Indian Movies
-- Objective: Identify the top 10 actors in Indian-produced movies
-- ============================================
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
    COUNT(*) AS movie_count
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;

-- ============================================
-- 15. Categorize Content Based on 'Kill' and 'Violence' Keywords
-- Objective: Tag content as 'Bad' or 'Good' based on keywords in description
-- ============================================
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;


--THE END
