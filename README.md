# Spotify Streaming Data Analysis — SQL

SQL analysis of a 20,000-track [Spotify/YouTube dataset from Kaggle](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset), in two parts:

1. **[Original analysis](#original-analysis--my-own-questions)** — six business questions I designed and answered myself ([`original_analysis.sql`](original_analysis.sql), results captured verbatim in [`results/original_analysis_output.txt`](results/original_analysis_output.txt))
2. **[Guided foundation](#guided-foundation)** — my worked solutions to [najirh's Advanced SQL practice project](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL), which taught the mechanics I then built on

## Original analysis — my own questions

Each question is framed the way a label or streaming-platform analyst would ask it. All results below are actual query output against the dataset — nothing is illustrative.

### 1. Which artists convert viewers into fans? (`Q14`)

Views measure reach; likes measure investment. Ranking artists by **likes per 1,000 views** (≥10 tracks, ≥100M total views) splits the dataset dramatically:

| Segment | likes / 1k views |
|---|---|
| Fandom-driven artists (j-hope 48.8, ENHYPEN 44.8, Conan Gray 26.9) | ~25–49 |
| Kids' & background content (The Wiggles 0.1, The Kiboomers 1.3, La Sonora Dinamita 1.6) | ~0.1–1.6 |

**Insight:** engagement rate varies by ~300× across artists with similar reach. Kids' content racks up enormous views, but the viewer isn't the account holder — so likes never follow. For marketing spend, engagement rate is a far better fandom signal than raw views.

### 2. Do audio features predict streaming success? (`Q15`, `Q18`)

Two methods, same answer — **no**:

- **Quartile cross-tab:** if "audio appeal" (danceability + energy) drove streams, top-audio-quartile tracks should rarely land in the bottom stream quartile. Under pure independence you'd expect ~1,251 such tracks; the data shows **1,272** — statistically indistinguishable from chance.
- **Correlations:** every audio feature vs streams comes out near zero (danceability r = 0.074 is the strongest). As a sanity check on the method, energy vs loudness — which are physically related — shows r = 0.745.

**Insight:** you cannot pick hits from audio characteristics alone; success is driven by artist, promotion and context. (This also quietly debunks the "just make it danceable" brief.)

### 3. Where does listening actually happen? (`Q16`)

76.2% of tracks are streamed most on Spotify — but the artists whose catalogues live ~100% on YouTube form a clear pattern: kids' content (CoComelon), regional-language catalogues (Jatin-Lalit, Alex Zurdo) and audio-drama series (Die drei ???). **Insight:** platform strategy should be segment-specific, not one-size-fits-all.

### 4. Do singles outperform album tracks? (`Q17`)

Counterintuitively, no: album tracks have a **median 54.2M streams vs 30.8M for singles** (means show the same ordering). The album catalogue effect — listeners streaming whole albums of artists they love — beats single-release promotion in this dataset.

### 5. One-hit wonders, found by a query (`Q19`)

Coefficient of variation (stddev ÷ mean) of per-track streams identifies catalogue shape. The query independently surfaces **Gotye (CV 2.74) and Kimbra (CV 3.05)** at the top — both sides of *Somebody That I Used to Know*, the textbook one-hit wonder — with no artist names hardcoded anywhere. Most consistent: the **Hamilton** Original Broadway Cast (CV 0.19), because cast-album listeners stream the whole album.

### SQL techniques used

`NTILE()` quartile bucketing · `CORR()` Pearson correlation in SQL · `COUNT(*) FILTER (WHERE ...)` · `PERCENTILE_CONT() WITHIN GROUP` medians · window-function share-of-total (`SUM(COUNT(*)) OVER ()`) · `STDDEV_SAMP()` coefficient of variation · `HAVING` sample-size guards

## Guided foundation

The mechanics were learned through [najirh's Advanced SQL guided project](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL) — full credit for that project's structure, dataset selection and practice questions (Q1–Q13) goes to najirh. [`spotify_analysis.sql`](spotify_analysis.sql) contains my own worked queries for it:

- **EDA & cleaning** — counts, duration ranges, removing zero-duration junk rows
- **Core (Q1–Q10)** — filtering, aggregation, grouped metrics, `CASE WHEN` + `COALESCE` conditional-aggregation pivot (Spotify vs YouTube streams)
- **Advanced (Q11–Q13)** — `DENSE_RANK()` partitioned by artist, subquery filtering, CTE computing per-album energy spread

## Files

| File | Description |
|------|-------------|
| [`original_analysis.sql`](original_analysis.sql) | My six original questions (Q14–Q19), PostgreSQL dialect |
| [`results/original_analysis_output.txt`](results/original_analysis_output.txt) | Verbatim output of every original query |
| [`run_original_analysis.py`](run_original_analysis.py) | Reproduces the results file end-to-end (DuckDB) |
| [`spotify_analysis.sql`](spotify_analysis.sql) | Worked queries for the guided project — schema, EDA, Q1–Q13 |

## Reproduce

```bash
# Grab cleaned_dataset.csv from the Kaggle link above, then:
pip install duckdb
python3 run_original_analysis.py path/to/cleaned_dataset.csv
```

The original queries are written in PostgreSQL dialect and executed via DuckDB (which speaks it natively); for the guided part, run the `CREATE TABLE` block at the top of `spotify_analysis.sql` in PostgreSQL and import the CSV.
