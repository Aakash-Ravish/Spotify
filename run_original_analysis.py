#!/usr/bin/env python3
"""Reproduce results/original_analysis_output.txt.

Loads the Kaggle CSV into DuckDB (PostgreSQL-compatible dialect), applies the
same cleaning step as the guided project (drop duration_min = 0 rows), then
runs every statement in original_analysis.sql and prints the results.

Usage:
    pip install duckdb
    python3 run_original_analysis.py path/to/cleaned_dataset.csv
"""
import sys
from pathlib import Path

import duckdb

if len(sys.argv) != 2:
    sys.exit(__doc__)

csv_path = sys.argv[1]
sql_path = Path(__file__).parent / "original_analysis.sql"

con = duckdb.connect()
con.execute(f"""
CREATE TABLE spotify AS
SELECT
  Artist AS artist, Track AS track, Album AS album, Album_type AS album_type,
  Danceability AS danceability, Energy AS energy, Loudness AS loudness,
  Speechiness AS speechiness, Acousticness AS acousticness,
  Instrumentalness AS instrumentalness, Liveness AS liveness, Valence AS valence,
  Tempo AS tempo, Duration_min AS duration_min, Title AS title, Channel AS channel,
  Views AS views, Likes AS likes, Comments AS comments, Licensed AS licensed,
  official_video, Stream AS stream, EnergyLiveness AS energy_liveness,
  most_playedon AS most_played_on
FROM read_csv_auto(?)
""", [csv_path])

# Same cleaning step as the guided project's EDA.
con.execute("DELETE FROM spotify WHERE duration_min = 0")
print(f"rows after cleaning: {con.execute('SELECT COUNT(*) FROM spotify').fetchone()[0]}\n")

# Walk the file line by line: comments are stripped before statements are
# split on ';' (comments may themselves contain semicolons), and the last
# seen '-- Qnn.' line is used as the printed header for the next statement.
header = ""
buffer: list[str] = []
for line in sql_path.read_text().splitlines():
    stripped = line.strip()
    if stripped.startswith("--"):
        if stripped.startswith("-- Q"):
            header = stripped.lstrip("- ").strip()
        continue
    buffer.append(line)
    if stripped.endswith(";"):
        body = "\n".join(buffer).strip().rstrip(";")
        buffer = []
        if not body:
            continue
        print("=" * 72)
        if header:
            print(header)
        res = con.execute(body)
        cols = [d[0] for d in res.description]
        print(" | ".join(cols))
        for row in res.fetchall():
            print(" | ".join(str(x) for x in row))
        print()
