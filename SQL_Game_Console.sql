
-- GAME CONSOLE

-- Table "public.console_dates"
-- Column           |          Type          | Collation | Nullable | Default
-- ---------------------------+------------------------+-----------+----------+---------
-- platform_name             | character(120)         |           |          |
-- first_retail_availability | date                   |           |          |
-- discontinued              | date                   |           |          |
-- units_sold_mill           | double precision       |           |          |
-- platform_comment          | character varying(120) |           |          |


-- Table "public.console_games"
-- Column    |          Type           | Collation | Nullable | Default
-- -------------+-------------------------+-----------+----------+---------
-- game_name   | character varying(1200) |           |          |
-- platform    | character varying(1200) |           |          |
-- game_year   | integer                 |           |          |
-- genre       | character varying(20)   |           |          |
-- publisher   | character varying(1200) |           |          |
-- na_sales    | double precision        |           |          |
-- eu_sales    | double precision        |           |          |
-- jp_sales    | double precision        |           |          |
-- other_sales | double precision        |           |          |


-- Active Platforms: Find all the names of platforms and platform comments for platforms which
-- have not been discontinued
SELECT platform_name
      , platform_comment
FROM console_dates
WHERE discontinued IS NULL;


-- Popular Genres: For each sales region, find the most popular genres and overall most popular genre

-- Global Most Popular Genres
SELECT genre as Global_Top_Genres
FROM (
  SELECT genre
       , round(CAST(sum(na_sales) as numeric),2) as North_America_Sales
       , round(CAST(sum(eu_sales) as numeric),2) as Europe_Sales
       , round(CAST(sum(jp_sales) as numeric),2) as Japan_Sales
       , round(CAST(sum(other_sales) as numeric),2) as Other_Region_Sales
  FROM console_games
  GROUP BY genre
) as genres
ORDER BY North_America_Sales + Europe_Sales + Japan_Sales + Other_Region_Sales DESC;

-- North America's Most Popular Genres
SELECT genre as North_America_Top_Genres

FROM (
  SELECT genre
       , round(CAST(sum(na_sales) as numeric),2) as North_America_Sales
       , round(CAST(sum(eu_sales) as numeric),2) as Europe_Sales
       , round(CAST(sum(jp_sales) as numeric),2) as Japan_Sales
       , round(CAST(sum(other_sales) as numeric),2) as Other_Region_Sales
  FROM console_games
  GROUP BY genre
) as genres
ORDER BY North_America_Sales DESC;

-- Europe's Most Popular Genres
SELECT genre as Europe_Top_Genres
FROM (
  SELECT genre
       , round(CAST(sum(na_sales) as numeric),2) as North_America_Sales
       , round(CAST(sum(eu_sales) as numeric),2) as Europe_Sales
       , round(CAST(sum(jp_sales) as numeric),2) as Japan_Sales
       , round(CAST(sum(other_sales) as numeric),2) as Other_Region_Sales
  FROM console_games
  GROUP BY genre
) as genres
ORDER BY Europe_Sales DESC;

-- Japan's Most Popular Genres
SELECT genre as Japan_Top_Genres
FROM (
  SELECT genre
       , round(CAST(sum(na_sales) as numeric),2) as North_America_Sales
       , round(CAST(sum(eu_sales) as numeric),2) as Europe_Sales
       , round(CAST(sum(jp_sales) as numeric),2) as Japan_Sales
       , round(CAST(sum(other_sales) as numeric),2) as Other_Region_Sales
  FROM console_games
  GROUP BY genre
) as genres
ORDER BY Japan_Sales DESC;

-- Rest of the World's Most Popular Genres
SELECT genre as Other_Top_Genres
FROM (
  SELECT genre
       , round(CAST(sum(na_sales) as numeric),2) as North_America_Sales
       , round(CAST(sum(eu_sales) as numeric),2) as Europe_Sales
       , round(CAST(sum(jp_sales) as numeric),2) as Japan_Sales
       , round(CAST(sum(other_sales) as numeric),2) as Other_Region_Sales
  FROM console_games
  GROUP BY genre
) as genres
ORDER BY Other_Region_Sales DESC;

-- Function for queying most popular genre for region

CREATE OR REPLACE FUNCTION genre_region(IN region VARCHAR(70), OUT genre VARCHAR(70), OUT sales VARCHAR(70))
AS
       'SELECT genre
              , region
       FROM (
         SELECT genre
              , round(CAST(sum(na_sales) as numeric),2) as North_America_Sales
              , round(CAST(sum(eu_sales) as numeric),2) as Europe_Sales
              , round(CAST(sum(jp_sales) as numeric),2) as Japan_Sales
              , round(CAST(sum(other_sales) as numeric),2) as Other_Region_Sales
         FROM console_games
         GROUP BY genre
       ) as genres
       ORDER BY region DESC;'
  LANGUAGE SQL;

  -- For each Year name the publisher which released the most number of games
SELECT year
       , publisher
       , max_games_published
FROM (
      SELECT  game_year
            , publisher
            , count(1) as games_published
      FROM console_games
      GROUP BY publisher, game_year
      ORDER BY game_year
    ) as counts1

INNER JOIN (
            SELECT DISTINCT(game_year) as year
                   , max(games_published) as max_games_published
            FROM (
                  SELECT  game_year
                        , publisher
                        , count(1) as games_published
                  FROM console_games
                  GROUP BY publisher, game_year
                  ORDER BY game_year
                ) as counts
            GROUP BY game_year
            ORDER BY game_year ASC
          ) as counts2
    ON counts1.games_published = counts2.max_games_published
    AND counts1.game_year = counts2.year;

-- For each Year name the publisher which had the top gross global sales

SELECT  year
       , publisher
       , Max_Global_Sales
FROM (
      SELECT  game_year
            , publisher
            , round(CAST(sum(na_sales) + sum(eu_sales) + sum(jp_sales) + sum(other_sales) as numeric),2) as Global_Sales
      FROM console_games
      GROUP BY publisher, game_year
      ORDER BY game_year
    ) as sales1

INNER JOIN (
            SELECT DISTINCT(game_year) as year
                   , max(Global_Sales) as Max_Global_Sales
            FROM (
                  SELECT  game_year
                        , publisher
                        , round(CAST(sum(na_sales) as numeric),2) as North_America_Sales
                        , round(CAST(sum(eu_sales) as numeric),2) as Europe_Sales
                        , round(CAST(sum(jp_sales) as numeric),2) as Japan_Sales
                        , round(CAST(sum(other_sales) as numeric),2) as Other_Region_Sales
                        , round(CAST(sum(na_sales) + sum(eu_sales) + sum(jp_sales) + sum(other_sales) as numeric),2) as Global_Sales
                  FROM console_games
                  GROUP BY publisher, game_year
                  ORDER BY game_year
                ) as counts
            GROUP BY game_year
            ORDER BY game_year ASC
          ) as sales2
    ON sales1.Global_Sales = sales2.Max_Global_Sales
    AND sales1.game_year = sales2.year;

-- what were the top 5 most popular games (and their genres) in Japan between 2010 and 2015?
-- How does the list compare when filtering out discontinued consoles?


-- Top 5 Games in Japan
SELECT game_name
      , platform
      , jp_sales
FROM console_games
WHERE game_year BETWEEN 2010 AND 2015
ORDER BY jp_sales DESC
LIMIT 5;


-- Top 5 Games in Japan
SELECT game_name
      , platform
      , na_sales
FROM console_games
WHERE game_year BETWEEN 2010 AND 2015
ORDER BY na_sales DESC
LIMIT 5


-- Top 5 Games in Japan (For Discontinued Consoles)
SELECT game_name
      , platform
      , jp_sales
FROM console_games
INNER JOIN (
        SELECT platform_name
             , platform_comment
        FROM console_dates
        WHERE discontinued <= '2016-01-01'
      ) as console_active
    ON platform_name = platform
WHERE game_year BETWEEN 2010 AND 2015
ORDER BY jp_sales DESC
LIMIT 5;

-- Top 5 Games in Japan (Consoles currently on the Market)
SELECT game_name
      , platform
      , jp_sales
      , game_year
FROM console_games
INNER JOIN (
        SELECT platform_name
             , platform_comment
        FROM console_dates
        WHERE discontinued IS NULL
      ) as console_active
    ON platform_name = platform
WHERE game_year BETWEEN 2010 AND 2015
ORDER BY jp_sales DESC
LIMIT 5;


-- How Many 'The Sims' games have been release and what's their stats?

-- Total count of 'The Sims' games per console

SELECT count(1) as Total_Sims_Games_Released
       , platform
FROM console_games
WHERE game_name LIKE '%The Sims %'
GROUP BY platform
ORDER BY platform ASC;


-- Total count 'Pokemon' games per console

SELECT count(1) as Pokemon_Games_Released
       , platform
FROM console_games
WHERE game_name LIKE '%Pok%mon%'
GROUP BY platform
ORDER BY platform ASC;

-- Total 'Sonic' games per consol

SELECT count(1) as Sonic_Games_Released
       , platform
FROM console_games
WHERE game_name LIKE '%Sonic%'
GROUP BY platform
ORDER BY platform ASC;

-- List of all games released on the Sega Megadrive (Sega Genesis)

SELECT game_name
      , platform
      , game_year
FROM console_games
WHERE platform = 'GEN'
ORDER BY game_year ASC;
