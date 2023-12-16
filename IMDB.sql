USE imdb;

-- Q1. Find the total number of rows in each table of the schema?
SELECT table_name, table_rows FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'imdb';

-- Q2. Which columns in the movie table have null values?
SELECT 
    sum(case when id is null then 1 else 0 end)as ID,
    sum(case when title is null then 1 else 0 end)as Title,
    sum(case when year is null then 1 else 0 end)as Year,
    sum(case when date_published is null then 1 else 0 end)as Publishing_date,
    sum(case when duration is null then 1 else 0 end)as Duration,
    sum(case when country is null then 1 else 0 end)as Country,
    sum(case when worlwide_gross_income is null then 1 else 0 end)as Income,
    sum(case when languages is null then 1 else 0 end)as Languages,
    sum(case when production_company is null then 1 else 0 end)as Company 
    FROM movie;

-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
SELECT YEAR, count(title) AS Movies_count FROM movie GROUP BY year ORDER BY year;

SELECT MONTH(date_published) AS MonthNo, count(*) AS NoOfMovies FROM movie GROUP BY MonthNo ORDER BY MonthNo ;

-- Q4. How many movies were produced in the USA or India in the year 2019??
SELECT count(distinct id) AS NoOfMovies, year FROM movie WHERE ( country LIKE '%USA%' OR country LIKE '%INDIA%' ) AND YEAR = 2019;

-- Q5. Find the unique list of the genres present in the data set?
SELECT DISTINCT(genre) FROM genre ;

-- Q6.Which genre had the highest number of movies produced overall?
SELECT genre, year, COUNT(movie_id) AS No_of_movies FROM genre g INNER JOIN movie m ON g.movie_id = m.id WHERE year = 2019
GROUP BY genre ORDER BY No_of_movies DESC LIMIT 1;

-- Q7. How many movies belong to only one genre?
WITH genre_count AS
(
SELECT movie_id, count(genre) as count_of_genre
FROM genre group by movie_id)
SELECT count(movie_id) FROM genre_count where count_of_genre = 1;

-- Q8.What is the average duration of movies in each genre? 
SELECT g.genre, avg(duration) 
FROM movie m 
JOIN genre g ON g.movie_id = m.id 
GROUP BY g.genre ;

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
WITH genre_rank AS (
SELECT genre, COUNT(movie_id) AS movie_count,
RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
FROM genre
GROUP BY genre
)
SELECT * FROM genre_rank
WHERE genre='thriller';

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
SELECT 
min(avg_rating) AS min_avg_rating, max(avg_rating) AS max_avg_rating, min(total_votes) AS min_total_votes, 
max(total_votes) AS max_total_votes, min(median_rating) AS min_median_rating, max(median_rating) AS max_median_rating FROM ratings;

-- Q11. Which are the top 10 movies based on average rating?
SELECT m.title, r.avg_rating 
FROM movie m 
INNER JOIN ratings r ON m.id = r.movie_id 
ORDER BY r.avg_rating 
DESC LIMIT 10 ;

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
SELECT median_rating, count(movie_id) AS movie_count 
FROM ratings 
GROUP BY median_rating 
ORDER BY median_rating ;

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
SELECT m.production_company, count(r.movie_id) 	AS movie_count,
DENSE_RANK() OVER(ORDER BY COUNT(m.title) DESC) AS prod_company_rank
FROM movie m
INNER JOIN ratings r ON m.id = r.movie_id
WHERE production_company IS NOT NULL 
AND r.avg_rating>8 
GROUP BY production_company;

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
SELECT g.genre, count(*) 	AS movie_count 
FROM genre g 
INNER JOIN movie m 			ON m.id = g.movie_id 
INNER JOIN ratings r 		ON r.movie_id = g.movie_id 
WHERE YEAR like '2017' 
AND MONTH(date_published)= '03' 
AND r.total_votes>1000 
AND m.country like 'USA' 
GROUP BY g.genre
ORDER BY movie_count DESC;

-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
SELECT m.title, r.avg_rating, g.genre FROM movie AS m 
INNER JOIN ratings AS r 
ON r.movie_id = m.id 
INNER JOIN genre AS g
ON g.movie_id = m.id
WHERE avg_rating >8 
ORDER BY avg_rating DESC ;

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
SELECT median_rating, COUNT(*) FROM ratings AS r 
INNER JOIN movie AS m 
ON m.id = r.movie_id 
WHERE date_published 
BETWEEN '2018-04-01' 
AND '2019-04-01' 
AND median_rating = 8 
GROUP BY median_rating ;

-- Q17. Do German movies get more votes than Italian movies? 
SELECT tot_votes, langs FROM movie AS m INNER JOIN ratings AS r ON m.id=r.movie_id WHERE langs LIKE 'German' OR langs LIKE 'Italian' GROUP BY langs ORDER BY tot_voteS DESC;

-- Q18. Which columns in the names table have null values??
SELECT
sum(case WHEN NAME IS NULL THEN 1 ELSE 0 END) AS name_nullcount,
sum(case WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nullcount,
sum(case WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nullcount,
sum(case WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nullcount
FROM names ;

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
WITH top_3_genres AS 
(
		SELECT genre, count(m.id) AS movie_count,
		RANK() OVER 
		(ORDER BY count(m.id) DESC) AS genre_rank 
		FROM movie 	AS m
		INNER JOIN genre AS g 	ON g.movie_id = m.id
		INNER JOIN ratings AS r ON r.movie_id = m.ID
		WHERE avg_rating > 8
		GROUP BY genre 
		LIMIT 3 )
SELECT 	n.name AS director_name,
		count(d.movie_id) AS movie_count
		FROM director_mapping AS d
		INNER JOIN genre AS GN ON d.movie_id = GN.movie_id
		INNER JOIN names AS n ON n.id = d.name_id
		INNER JOIN top_3_genres USING(genre)
		INNER JOIN ratings USING(movie_id) 
		WHERE avg_rating > 8
		GROUP BY name
		ORDER BY movie_count
		DESC LIMIT 3 ;

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
SELECT DISTINCT name AS actor, COUNT(r.movieid) AS movietot FROM ratings AS r INNER JOIN role_mapping AS rm ON rm.movie_id = n.id
WHERE medianrating >=8 AND category = 'actor' GROUP BY name ORDER BY movietot DESC LIMIT 2;

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
SELECT production_company,
sum(total_votes) AS vote_count,
RANK() OVER (ORDER BY sum(total_votes) DESC) AS prod_company_rank
FROM movie AS m
INNER JOIN ratings AS r
ON r.movie_id = m.id
GROUP BY production_company LIMIT 3 ;

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
SELECT name AS actor_name, total_votes,
                COUNT(m.id) as movie_count,
                ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actor_avg_rating,
                RANK() OVER(ORDER BY avg_rating DESC) AS actor_rank
		
FROM movie AS m 
INNER JOIN ratings AS r 
ON m.id = r.movie_id 
INNER JOIN role_mapping AS rm 
ON m.id=rm.movie_id 
INNER JOIN names AS nm 
ON rm.name_id=nm.id
WHERE category='actor' AND country= 'india'
GROUP BY name
HAVING COUNT(m.id)>=5
LIMIT 1;

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
SELECT name AS actress_name, total_votes,
                COUNT(m.id) AS movie_count,
                ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actress_avg_rating,
                RANK() OVER(ORDER BY avg_rating DESC) AS actress_rank
		
FROM movie AS m 
INNER JOIN ratings AS r 
ON m.id = r.movie_id 
INNER JOIN role_mapping AS rm 
ON m.id=rm.movie_id 
INNER JOIN names AS nm 
ON rm.name_id=nm.id
WHERE category='actress' AND country='india' AND languages='hindi'
GROUP BY name
HAVING COUNT(m.id)>=3
LIMIT 1;

/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
SELECT title,
CASE 
WHEN avg_rating > 8 THEN 'Superhit movies'
WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
WHEN avg_rating < 5 THEN 'Flop movies'
END AS avg_rating_category
FROM movie AS m
INNER JOIN genre AS g ON m.id = g.movie_id
INNER JOIN ratings AS r ON m.id = r.movie_id
WHERE genre LIKE 'Thriller' 
ORDER BY title;

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
SELECT genre,
ROUND(AVG(duration), 2) AS avg_duration,
SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
WITH top_3_genre AS
( 	
	SELECT genre, COUNT(movie_id) AS number_of_movies
    FROM genre AS g
    INNER JOIN movie AS m
    ON g.movie_id = m.id
    GROUP BY genre
    ORDER BY COUNT(movie_id) DESC
    LIMIT 3
),

top_5 AS
(
	SELECT genre,
			year,
			title AS movie_name,
			worlwide_gross_income,
			DENSE_RANK() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
        
	FROM movie AS m 
    INNER JOIN genre AS g 
    ON m.id= g.movie_id
	WHERE genre IN (SELECT genre FROM top_3_genre)
)

SELECT *
FROM top_5
WHERE movie_rank<=5;

-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
SELECT production_company, COUNT(m.id) AS movie_count,
ROW_NUMBER() OVER(ORDER BY count(id) DESC) AS prod_comp_rank
FROM movie AS m 
INNER JOIN ratings AS r 
ON m.id=r.movie_id
WHERE median_rating>=8 AND production_company IS NOT NULL AND POSITION(',' IN languages)>0
GROUP BY production_company
LIMIT 2;

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
SELECT 
	name, 
	SUM(total_votes) AS total_votes,
	COUNT(rm.movie_id) AS movie_count, 
	AVG(r.avg_rating) AS avg_rating,
	DENSE_RANK() OVER(ORDER BY AVG(r.avg_rating) DESC) AS actress_rank
FROM 
	names AS n
	INNER JOIN role_mapping AS rm 	ON n.id = rm.name_id
	INNER JOIN ratings 		AS r 	ON r.movie_id = rm.movie_id
	INNER JOIN genre 		AS g 	ON r.movie_id = g.movie_id
WHERE 
	category = 'actress' AND genre = 'drama'
GROUP BY name
HAVING avg(r.avg_rating) > 8
LIMIT 3;

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/

WITH movie_dates_details AS
(
SELECT d.name_id, name, d.movie_id, m.date_published, 
LEAD(date_published, 1) OVER(PARTITION BY d.name_id ORDER BY date_published, d.movie_id) AS next_movie_date
FROM director_mapping d
INNER JOIN names AS n ON d.name_id=n.id 
INNER JOIN movie AS m ON d.movie_id=m.id
),

date_diff AS
(
	 SELECT *, DATEDIFF(next_movie_date, date_published) AS diff
	 FROM movie_dates_details
 ),
 
 avg_interval_days AS
 (
	 SELECT name_id, AVG(diff) AS avg_interval_movie_days
	 FROM date_diff
	 GROUP BY name_id
 ),
 
 final_answer AS
 (
	 SELECT d.name_id AS director_id,
		 name AS director_name,
		 COUNT(d.movie_id) AS number_of_movies,
		 ROUND(avg_interval_movie_days) AS inter_movie_days,
		 ROUND(AVG(avg_rating),2) AS avg_rating,
		 SUM(total_votes) AS total_votes,
		 MIN(avg_rating) AS min_rating,
		 MAX(avg_rating) AS max_rating,
		 SUM(duration) AS total_duration,
		 ROW_NUMBER() OVER(ORDER BY COUNT(d.movie_id) DESC) AS director_row_rank
	 FROM
		 names AS n 
         JOIN director_mapping AS d 
         ON n.id=d.name_id
		 JOIN ratings AS r 
         ON d.movie_id=r.movie_id
		 JOIN movie AS m 
         ON m.id=r.movie_id
		 JOIN avg_interval_days AS a 
         ON a.name_id=d.name_id
	 GROUP BY director_id
 )
 SELECT *	
 FROM final_answer
 LIMIT 9;
