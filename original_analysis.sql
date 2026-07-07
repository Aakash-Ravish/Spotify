-- ============================================================================
-- ORIGINAL ANALYSIS — my own questions, beyond the guided project
-- ============================================================================
-- The guided project (Q1-Q13 in spotify_analysis.sql) taught the mechanics.
-- These six questions are ones I designed myself, framed the way a label or
-- streaming-platform analyst would ask them. Written in PostgreSQL dialect;
-- results in results/original_analysis_output.txt were produced by running
-- these exact queries against the same dataset (see run_original_analysis.py).
--
-- Uses the same `spotify` table + cleaning step (duration_min = 0 rows
-- removed) as spotify_analysis.sql.
-- ============================================================================


-- Q14. Which artists convert viewers into fans?
-- Views measure reach; likes measure engagement. Likes-per-1000-views is a
-- proxy for how invested an artist's audience actually is. Restricted to
-- artists with 10 tracks and >= 100M total views so small samples don't
-- dominate.
SELECT artist,
       COUNT(*) AS tracks,
       SUM(views) AS total_views,
       ROUND(SUM(likes) * 1000.0 / SUM(views), 1) AS likes_per_1k_views
FROM spotify
WHERE views > 0
GROUP BY artist
HAVING COUNT(*) >= 10 AND SUM(views) >= 100000000
ORDER BY likes_per_1k_views DESC
LIMIT 10;

-- ...and the bottom of the same ranking (for the contrast in the findings):
SELECT artist,
       COUNT(*) AS tracks,
       SUM(views) AS total_views,
       ROUND(SUM(likes) * 1000.0 / SUM(views), 1) AS likes_per_1k_views
FROM spotify
WHERE views > 0
GROUP BY artist
HAVING COUNT(*) >= 10 AND SUM(views) >= 100000000
ORDER BY likes_per_1k_views ASC
LIMIT 5;


-- Q15. Do audio features predict streaming success?
-- Cross-tab of quartiles: if "audio appeal" (danceability + energy) drove
-- streams, tracks in the top audio quartile should rarely land in the bottom
-- stream quartile. Under pure independence you'd expect ~1/16 of all tracks
-- (~1,251) in that cell. Observed: 1,272 — audio features alone tell you
-- almost nothing about commercial performance.
WITH scored AS (
  SELECT track, artist, stream,
         NTILE(4) OVER (ORDER BY danceability + energy DESC) AS audio_q,
         NTILE(4) OVER (ORDER BY stream DESC)                AS stream_q
  FROM spotify
  WHERE stream > 0
)
SELECT COUNT(*) FILTER (WHERE audio_q = 1 AND stream_q = 4) AS observed_hidden_gems,
       COUNT(*) / 16                                        AS expected_if_independent,
       COUNT(*)                                             AS total_tracks
FROM scored;


-- Q16. How platform-dependent are artists?
-- Overall, where does listening happen — and which artists' audiences live
-- almost entirely on YouTube? (Relevant to where marketing spend should go.)
SELECT most_played_on,
       COUNT(*) AS tracks,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM spotify
GROUP BY most_played_on;

SELECT artist,
       COUNT(*) AS tracks,
       ROUND(100.0 * SUM(CASE WHEN most_played_on = 'Youtube' THEN 1 ELSE 0 END) / COUNT(*), 0) AS pct_youtube
FROM spotify
GROUP BY artist
HAVING COUNT(*) >= 10
ORDER BY pct_youtube DESC
LIMIT 8;


-- Q17. Do singles actually outperform album tracks?
-- Industry intuition says singles get the promotion, so they should stream
-- best. Median (not just mean) guards against a few mega-hits skewing the
-- answer.
SELECT album_type,
       COUNT(*) AS tracks,
       ROUND(AVG(stream)) AS avg_streams,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY stream)) AS median_streams
FROM spotify
GROUP BY album_type
ORDER BY median_streams DESC;


-- Q18. What actually correlates with streams?
-- Pearson correlations computed in SQL. energy <-> loudness sanity-checks the
-- method (they're physically related, so a strong r is expected). Every
-- audio feature vs streams comes out near zero — same conclusion as Q15 by a
-- different method.
SELECT
  ROUND(CORR(energy, loudness), 3)      AS energy_vs_loudness,
  ROUND(CORR(danceability, stream), 3)  AS danceability_vs_streams,
  ROUND(CORR(energy, stream), 3)        AS energy_vs_streams,
  ROUND(CORR(valence, stream), 3)       AS valence_vs_streams,
  ROUND(CORR(speechiness, stream), 3)   AS speechiness_vs_streams,
  ROUND(CORR(duration_min, stream), 3)  AS duration_vs_streams
FROM spotify;


-- Q19. One-hit wonders vs consistent catalogues.
-- Coefficient of variation (stddev / mean) of stream counts per artist:
-- high CV = one huge hit and a quiet catalogue; low CV = listeners stream
-- everything. Restricted to artists with 10 tracks and >= 1B total streams.
SELECT artist,
       COUNT(*) AS tracks,
       ROUND(AVG(stream) / 1e6) AS avg_streams_m,
       ROUND(STDDEV_SAMP(stream) / AVG(stream), 2) AS cv
FROM spotify
WHERE stream > 0
GROUP BY artist
HAVING COUNT(*) >= 10 AND SUM(stream) >= 1000000000
ORDER BY cv DESC
LIMIT 5;

-- ...and the most consistent catalogues:
SELECT artist,
       COUNT(*) AS tracks,
       ROUND(AVG(stream) / 1e6) AS avg_streams_m,
       ROUND(STDDEV_SAMP(stream) / AVG(stream), 2) AS cv
FROM spotify
WHERE stream > 0
GROUP BY artist
HAVING COUNT(*) >= 10 AND SUM(stream) >= 1000000000
ORDER BY cv ASC
LIMIT 5;
