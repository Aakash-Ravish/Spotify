# Spotify Streaming Data Analysis — SQL

My worked solutions to [najirh's Advanced SQL guided project](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL), analysing a 10,000+ row [Spotify dataset from Kaggle](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset) in PostgreSQL.

Full credit for the project structure, dataset selection and practice questions goes to najirh — this repo contains **my own worked queries**, written while completing the project ([`spotify_analysis.sql`](spotify_analysis.sql)).

## What's in the analysis

The queries progress from exploratory data analysis through to window functions and CTEs:

**EDA & data cleaning**
- Row/artist/album-type counts, duration ranges
- Found and removed zero-duration junk rows before analysis

**Core analysis (Q1–Q10)**
- Filtering and aggregation: tracks over 1B streams, comments on licensed tracks, tracks per artist
- Grouped metrics: average danceability per album, top-5 tracks by energy, views/likes on official videos
- Conditional aggregation: `CASE WHEN` + `COALESCE` pivot to compare Spotify vs YouTube stream counts per track

**Advanced (Q11–Q13)**
- `DENSE_RANK()` window function partitioned by artist to get each artist's top 3 most-viewed tracks
- Subquery filtering: tracks with above-average liveness
- CTE computing the energy spread (max − min) per album

## Skills practised

PostgreSQL · joins · `GROUP BY` aggregation · conditional aggregation (`CASE WHEN`, `COALESCE`) · subqueries · CTEs (`WITH`) · window functions (`DENSE_RANK() OVER (PARTITION BY ...)`)

## Files

| File | Description |
|------|-------------|
| [`spotify_analysis.sql`](spotify_analysis.sql) | All worked queries — schema, EDA, Q1–Q13 |

## Reproduce

1. Grab the [dataset from Kaggle](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)
2. Run the `CREATE TABLE` block at the top of `spotify_analysis.sql`, import the CSV
3. Work through the queries top to bottom
