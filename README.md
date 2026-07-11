# Spotify Streaming Data Analysis (SQL)

SQL analysis of a 20,000-track [Spotify/YouTube dataset from Kaggle](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset). Two parts:

1. **[Original analysis](#original-analysis--my-own-questions)**: six business questions I designed and answered myself ([`original_analysis.sql`](original_analysis.sql), results captured verbatim in [`results/original_analysis_output.txt`](results/original_analysis_output.txt)).
2. **[Guided foundation](#guided-foundation)**: my worked solutions to [najirh's Advanced SQL practice project](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL), which taught me the mechanics I built on for part 1.

## Original analysis — my own questions

I framed each question the way a label or streaming-platform analyst actually would. All results below are real query output run against the dataset, nothing here is illustrative.

### 1. Which artists convert viewers into fans? (`Q14`)

Views measure reach, likes measure investment. I ranked artists by **likes per 1,000 views** (minimum 10 tracks, 100M+ total views) and the dataset splits hard:

| Segment | likes / 1k views |
|---|---|
| Fandom-driven artists (j-hope 48.8, ENHYPEN 44.8, Conan Gray 26.9) | ~25–49 |
| Kids' & background content (The Wiggles 0.1, The Kiboomers 1.3, La Sonora Dinamita 1.6) | ~0.1–1.6 |

Engagement rate varies by roughly 300x across artists with similar reach. Kids' content racks up enormous view counts, but the person watching isn't the account holder, so the likes never follow. For marketing spend, engagement rate is a much better fandom signal than raw views.

### 2. Do audio features predict streaming success? (`Q15`, `Q18`)

I checked this two ways and got the same answer both times: no.

- **Quartile cross-tab.** If "audio appeal" (danceability + energy) actually drove streams, tracks in the top audio quartile should rarely land in the bottom stream quartile. Pure independence predicts around 1,251 such tracks. The data shows 1,272, which is statistically indistinguishable from chance.
- **Correlations.** Every audio feature comes out near zero against streams (danceability, r = 0.074, is the strongest). As a sanity check, energy vs. loudness, two features that are physically related, comes out at r = 0.745, which is what you'd expect.

You can't pick hits from audio characteristics alone. Success comes down to artist, promotion, and context, which also quietly debunks the "just make it danceable" brief.

### 3. Where does listening actually happen? (`Q16`)

76.2% of tracks are streamed most on Spotify. But the artists whose catalogues live almost entirely on YouTube form a clear pattern: kids' content (CoComelon), regional-language catalogues (Jatin-Lalit, Alex Zurdo), and audio-drama series (Die drei ???). Platform strategy should be segment-specific, not one-size-fits-all.

### 4. Do singles outperform album tracks? (`Q17`)

No, and it's not close. Album tracks have a median of 54.2M streams vs. 30.8M for singles (the means show the same ordering). The album catalogue effect, listeners working through whole albums of artists they already love, beats single-release promotion in this dataset.

### 5. One-hit wonders, found by a query (`Q19`)

I used coefficient of variation (stddev ÷ mean) of per-track streams to identify catalogue shape. The query surfaces Gotye (CV 2.74) and Kimbra (CV 3.05) at the top with no artist names hardcoded anywhere, both sides of *Somebody That I Used to Know*, the textbook one-hit wonder. Most consistent catalogue: the Hamilton Original Broadway Cast (CV 0.19), because cast-album listeners tend to stream the whole thing.

### SQL techniques used

`NTILE()` quartile bucketing, `CORR()` Pearson correlation in SQL, `COUNT(*) FILTER (WHERE ...)`, `PERCENTILE_CONT() WITHIN GROUP` medians, window-function share-of-total (`SUM(COUNT(*)) OVER ()`), `STDDEV_SAMP()` coefficient of variation, `HAVING` sample-size guards.

## Guided foundation

I learned the mechanics through [najirh's Advanced SQL guided project](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL). Full credit for that project's structure, dataset selection, and practice questions (Q1–Q13) goes to najirh. [`spotify_analysis.sql`](spotify_analysis.sql) has my own worked queries for it:

- **EDA & cleaning**: counts, duration ranges, removing zero-duration junk rows
- **Core (Q1–Q10)**: filtering, aggregation, grouped metrics, `CASE WHEN` + `COALESCE` conditional-aggregation pivot (Spotify vs. YouTube streams)
- **Advanced (Q11–Q13)**: `DENSE_RANK()` partitioned by artist, subquery filtering, CTE computing per-album energy spread

## Files

| File | Description |
|------|-------------|
| [`original_analysis.sql`](original_analysis.sql) | My six original questions (Q14–Q19), PostgreSQL dialect |
| [`results/original_analysis_output.txt`](results/original_analysis_output.txt) | Verbatim output of every original query |
| [`run_original_analysis.py`](run_original_analysis.py) | Reproduces the results file end-to-end (DuckDB) |
| [`spotify_analysis.sql`](spotify_analysis.sql) | Worked queries for the guided project: schema, EDA, Q1–Q13 |

## Reproduce

```bash
# Grab cleaned_dataset.csv from the Kaggle link above, then:
pip install duckdb
python3 run_original_analysis.py path/to/cleaned_dataset.csv
```

The original queries are written in PostgreSQL dialect and run through DuckDB (which speaks it natively). For the guided part, run the `CREATE TABLE` block at the top of `spotify_analysis.sql` in PostgreSQL and import the CSV.
