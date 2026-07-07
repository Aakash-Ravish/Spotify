-- Advance SQL Project -- Spotify Datasets


DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


--EDA

SELECT COUNT(*) FROM SPOTIFY;

SELECT COUNT(DISTINCT ARTIST) FROM SPOTIFY;

SELECT DISTINCT ALBUM_TYPE FROM SPOTIFY;

SELECT MAx(duration_min) From spotify;

SELECT Min(duration_min) From spotify;

SELECT * FROM SPOTIFY
WHERE DURATION_MIN = '0';

DELETE FROM SPOTIFY
WHERE DURATION_MIN = '0';


SELECT * FROM SPOTIFY 
WHERE DURATION_MIN = '0';

SELECT DISTINCT CHANNEL FROM SPOTIFY;

------------------------------------------
-- DATA ANALYSIS - A 
------------------------------------------

--Q.1Retrieve the names of all tracks that have more than 1 billion streams.
--Q.2List all albums along with their respective artists.
--Q.3Get the total number of comments for tracks where licensed = TRUE.
--Q.4Find all tracks that belong to the album type single.
--Q.5Count the total number of tracks by each artist.

--Q.1Retrieve the names of all tracks that have more than 1 billion streams.

Select * From spotify
Where stream > 1000000000;


--Q.2List all albums along with their respective artists.

Select DISTINCT album, Artist From spotify;


--Q.3 Get the total number of comments for tracks where licensed = TRUE.

Select sum(comments) AS total_comments
 From Spotify
Where licensed = 'true';


--Q.4 Find all tracks that belong to the album type single.
Select * From spotify
Where album_type = 'single';


--Q.5Count the total number of tracks by each artist.
Select artist, ---1
count(*) AS total_no_song --1 2 
From spotify
group by artist
Order by 2 DESC;

------------------------------------------------------------------------------------------

--Q.6Calculate the average danceability of tracks in each album.
--Q.7Find the top 5 tracks with the highest energy values.
--Q.8ist all tracks along with their views and likes where official_video = TRUE.
--Q.9For each album, calculate the total views of all associated tracks.
--Q.10Retrieve the track names that have been streamed on Spotify more than YouTube.
---------------------------------------------------------------------------------------------


--Q.6Calculate the average danceability of tracks in each album.

Select album, avg(danceability) as Avg_danceability
From spotify
Group by 1
Order by 2 DESC;

--Q.7Find the top 5 tracks with the highest energy values.

Select track,
max(energy)  As energy
From spotify
Group by 1
Order By 2 DESC
Limit 5;

--Q.8List all tracks along with their views and likes where official_video = TRUE.

Select track, 
        Sum(views) as total_views, 
        SUm(likes) As total_likes
From spotify
Where official_video = 'TRUE'
Group by 1 
Order by 2 DESC;

--Q.9For each album, calculate the total views of all associated tracks.

Select 
       album, 
	   track,
	   sum(views) as total_views
	From spotify
	Group By 1, 2
	Order by 3 DESC;

--Q.10 Retrieve the track names that have been streamed on Spotify more than YouTube.

Select * From 
(select track,
	   --most_played_on,
	   	coalesce(Sum(case when most_played_on = 'Youtube' THEN stream END), 0) as stream_on_youtube,
	   coalesce(SUm(case when most_played_on = 'Spotify' THEN stream END), 0) as stream_on_spotify 
from spotify 
Group by 1) as t1
 Where stream_on_spotify > stream_on_youtube
AND  stream_on_youtube <> 0;


------------------------------------------------------------------------------------------
-- Q11 Find the top 3 most-viewed tracks for each artist using window functions.
-- Q12 Write a query to find tracks where the liveness score is above the average.
------------------------------------------------------------------------------------------

-- Q11 Find the top 3 most-viewed tracks for each artist using window functions.

-- each artist and their total view for each track 
-- track with highest view for each artist (3)
-- Dense rank -- cte and filder rank <=3


With ranking_artist
AS 
(Select artist,
        track, 
		Sum(views) as total_view,
	    DENSE_RANK() OVER(PARTITION BY artist Order by sum(views) DEsc) AS rank
FRom spotify
Group by 1, 2
order by 1,3  DESC)
Select * From ranking_artist
Where rank <=3;

-- Q12 Write a query to find tracks where the liveness score is above the average.

Select track, liveness From spotify 
where liveness > (Select AVG(liveness) from spotify);

Select AVG(liveness) from spotify; -- ≈ 0.19

-- Q 13 Use a WITH clause to calculate the difference between
--the highest and lowest energy values for tracks in each album.


WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energy
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energy as energy_diff
FROM cte
ORDER BY 2 DESC;




