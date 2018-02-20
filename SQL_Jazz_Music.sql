
-- Jazz Music

-- Table "public.song_master_data"
-- Column         |          Type           | Collation | Nullable | Default
-- ------------------------+-------------------------+-----------+----------+---------
-- index                  | integer                 |           |          |
-- id                     | integer                 |           |          |
-- filename               | character varying(70)   |           |          |
-- artist                 | character varying(1200) |           |          |
-- title                  | character varying(1200) |           |          |
-- year                   | integer                 |           |          |
-- mp3_avaliable          | character varying(70)   |           |          |
-- link                   | character varying(70)   |           |          |
-- style_label            | character varying(70)   |           |          |
-- notes                  | character varying(1200) |           |          |
-- superlike              | character varying(1200) |           |          |
-- superlike_true         | integer                 |           |          |
-- swing_danceable        | integer                 |           |          |
-- other_danceable        | integer                 |           |          |
-- danceable              | integer                 |           |          |
-- not_great              | integer                 |           |          |
-- poor_quality_recording | integer                 |           |          |
-- lindy                  | integer                 |           |          |
-- blues                  | integer                 |           |          |
-- slow_swing             | integer                 |           |          |
-- balboa                 | integer                 |           |          |
-- shag                   | integer                 |           |          |
-- charleston             | integer                 |           |          |
-- none                   | integer                 |           |          |
-- random                 | integer                 |           |          |
--
-- Table "public.song_audio_features"
-- Column     |          Type           | Collation | Nullable | Default
-- ---------------+-------------------------+-----------+----------+---------
-- id            | integer                 |           |          |
-- filename      | character varying(1200) |           |          |
-- h_tempo       | double precision        |           |          |
-- h_beats       | integer                 |           |          |
-- p_temo        | double precision        |           |          |
-- p_beats       | integer                 |           |          |
-- rmse_mean     | double precision        |           |          |
-- rmse_median   | double precision        |           |          |
-- rmse_std      | double precision        |           |          |
-- song_duration | double precision        |           |          |

-- Table "public.song_pitch_features"
-- Column  |         Type          | Collation | Nullable | Default
-- ----------+-----------------------+-----------+----------+---------
-- id       | integer               |           |          |
-- filename | character varying(70) |           |          |
-- b        | double precision      |           |          |
-- a_srp    | double precision      |           |          |
-- a        | double precision      |           |          |
-- g_srp    | double precision      |           |          |
-- g        | double precision      |           |          |
-- f_srp    | double precision      |           |          |
-- f        | double precision      |           |          |
-- e_srp    | double precision      |           |          |
-- d_srp    | double precision      |           |          |
-- d        | double precision      |           |          |
-- c_srp    | double precision      |           |          |
-- c        | double precision      |           |          |



-- How Many poor Quality Recordings are there for each genre as a percentage
-- of songs in that genre

SELECT style_label
      , count(1) as counts
      , CAST(count(1) as float8) / total_style_count * 100 as percentage
FROM song_master_data as poor_q
INNER JOIN (
          SELECT style_label as labels
               , count(1) as total_style_count
          FROM song_master_data
          GROUP BY style_label
        ) as total_counts
        ON poor_q.style_label = total_counts.labels
WHERE poor_quality_recording = 1
GROUP BY style_label, total_style_count;


-- How many song have 'Blues' in the name and have blues category vs non-blues


SELECT count(1) as Count_Blues_named_songs
       , CASE WHEN Blues = 1 THEN 'Blues Music' ELSE 'Not Blues Music' END
FROM song_master_data
WHERE title LIKE '%Blues%'
GROUP BY Blues
ORDER BY Blues DESC;

-- List all of Sidney Bechet's and Louis Armstrong Songs in dataset

SELECT title
      , year
      , artist
      , style_label
FROM song_master_data
WHERE artist LIKE '%ouis%rmstrong%'
OR artist LIKE '%idney%echet%'
ORDER BY year, title, artist ASC;


-- List each Year and most predominant dance style category

SELECT year
      ,max_songs_count
      ,style_label
FROM (
      SELECT year
            ,style_label
            , count(1) as count
      FROM song_master_data as t1
      WHERE style_label IN ('Lindy', 'Blues', 'Balboa', 'Shag','Charleston')
      AND year BETWEEN 1926 AND 1959
      GROUP BY year, style_label
      ORDER BY Year
      ) as summary_by_year

INNER JOIN (
        SELECT DISTINCT(year) as yr
         , max(count2) as max_songs_count
         FROM (
                SELECT year
                      ,style_label
                      , count(1) as count2
                FROM song_master_data as t1
                WHERE style_label IN ('Lindy', 'Blues', 'Balboa', 'Shag','Charleston')
                GROUP BY year, style_label
                ORDER BY Year
              ) as summary_by_year_lookup
          GROUP BY year
          ORDER BY year ASC
        ) as summary_by_year_lookup2
    ON year = yr
    AND count = max_songs_count;

    -- Whats the percentage of blues song fit the slow-swing category and what's
    -- their average harmonic tempo, percussive tempo and root mean squared energy?

-- percentage

SELECT CAST(slow_swing_count as float8) / blues_count as slow_swing_percentage

FROM (
      SELECT slow_swing
            , count(1) as slow_swing_count
      FROM song_master_data
      WHERE slow_swing = 1
      GROUP BY slow_swing
      ) as sw
INNER JOIN (
    SELECT blues
          , count(1) as blues_count
    FROM song_master_data
    WHERE blues = 1
    GROUP BY blues
      ) as b
ON sw.slow_swing = b.blues;


-- Slow swing Blues

SELECT slow_swing
      , count(1) as slow_swing_count
      , round(CAST(avg(a.h_tempo) as numeric),2) as avg_harmonic_tempo
      , round(CAST(avg(a.p_temo) as numeric),2) as avg_percussive_tempo
      , round(CAST(avg(a.rmse_mean) as numeric),2) as root_mean_squared_energy_avg
FROM song_master_data as m
INNER JOIN song_audio_features as a
        ON m.filename = a.filename
WHERE slow_swing = 1
GROUP BY slow_swing;

-- Non-slow-swing Blues

SELECT blues
      , count(1) as blues_count
      , round(CAST(avg(a.h_tempo) as numeric),2) as avg_harmonic_tempo
      , round(CAST(avg(a.p_temo) as numeric),2) as avg_percussive_tempo
      , round(CAST(avg(a.rmse_mean) as numeric),2) as root_mean_squared_energy_avg
FROM song_master_data as m
INNER JOIN song_audio_features as a
        ON m.filename = a.filename
WHERE blues = 1
AND slow_swing = 0
GROUP BY blues;
