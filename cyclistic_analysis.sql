--1.Remove duplicates
SELECT DISTINCT *
FROM `capstone-project-1-511517.Cyclistic_bike_share.combined_tripdata`

--2.Find ride duration summary(total_rides,avg_duration_mins,median_duration_mins,min_duration_mins,max_duration_mins) by rider type
WITH trip_durations AS (
  SELECT
    member_casual,
    TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 60 AS duration_mins
  FROM
    `capstone-project-1-511517.Cyclistic_bike_share.clean_combined_tripdata`
  WHERE
    TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 60
    AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 86400
)
SELECT
  member_casual,
  COUNT(*) AS total_rides,
  ROUND(AVG(duration_mins), 2) AS avg_duration_mins,
  ROUND(APPROX_QUANTILES(duration_mins, 2)[OFFSET(1)], 2) AS median_duration_mins,
  ROUND(MIN(duration_mins), 2) AS min_duration_mins,
  ROUND(MAX(duration_mins), 2) AS max_duration_mins
FROM
  trip_durations
GROUP BY
  member_casual;

--3.Compare ride volume and average ride duration for casual riders and members across the week.
SELECT
  member_casual,
  EXTRACT(DAYOFWEEK FROM started_at) AS day_of_week_num,
  FORMAT_DATETIME('%A', started_at) AS day_of_week_name,
  COUNT(*) AS total_rides,
  ROUND(AVG(TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 60), 2) AS avg_duration_mins
FROM
  `capstone-project-1-511517.Cyclistic_bike_share.clean_combined_tripdata`
WHERE
  TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 60
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 86400
GROUP BY
  member_casual,
  day_of_week_num,
  day_of_week_name
ORDER BY
  day_of_week_num,
  member_casual;


--Compare type of bike used by casual riders and annual members and measure popularity of each bike within each rider group.
SELECT
  member_casual,
  rideable_type,
  COUNT(*) AS total_rides,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY member_casual), 2) AS percentage_share
FROM
  `capstone-project-1-511517.Cyclistic_bike_share.clean_combined_tripdata`
WHERE
  TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 60
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 86400
GROUP BY
  member_casual,
  rideable_type
ORDER BY
  member_casual,
  total_rides DESC;


--Find top 10 start stations by casual ride volume.
SELECT
  start_station_name,
  COUNT(*) AS casual_trip_count
FROM
  `capstone-project-1-511517.Cyclistic_bike_share.clean_combined_tripdata`
WHERE
  member_casual = 'casual'
  AND start_station_name IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 60
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 86400
GROUP BY
  start_station_name
ORDER BY
  casual_trip_count DESC
LIMIT 10;


--Find end stations that have the highest number of casual rides.
SELECT
  end_station_name,
  COUNT(*) AS casual_trip_count
FROM
  `capstone-project-1-511517.Cyclistic_bike_share.clean_combined_tripdata`
WHERE
  member_casual = 'casual'
  AND end_station_name IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 60
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 86400
GROUP BY
  end_station_name
ORDER BY
  casual_trip_count DESC
LIMIT 10;


--Find frequently used routes by casual riders and annual members.
SELECT
  member_casual,
  start_station_name,
  end_station_name,
  COUNT(*) AS trip_count
FROM
  `capstone-project-1-511517.Cyclistic_bike_share.clean_combined_tripdata`
WHERE
  start_station_name IS NOT NULL
  AND end_station_name IS NOT NULL
  AND start_station_name != ''
  AND end_station_name != ''
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 60
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 86400
GROUP BY
  member_casual,
  start_station_name,
  end_station_name
ORDER BY
  trip_count DESC


--Find routes between different stations that have the highest casual ride volume.
SELECT
  start_station_name,
  end_station_name,
  COUNT(*) AS casual_trip_count
FROM
  `capstone-project-1-511517.Cyclistic_bike_share.clean_combined_tripdata`
WHERE
  member_casual = 'casual'
  AND start_station_name IS NOT NULL
  AND end_station_name IS NOT NULL
  AND start_station_name != ''
  AND end_station_name != ''
  AND start_station_name != end_station_name
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 60
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 86400
GROUP BY
  start_station_name,
  end_station_name
ORDER BY
  casual_trip_count DESC
LIMIT 10;


--Compare the hourly ride patterns of casual riders and annual members and identify periods when their usage differs.
SELECT
  member_casual,
  EXTRACT(HOUR FROM started_at) AS hour_of_day,
  COUNT(*) AS total_rides
FROM
  `capstone-project-1-511517.Cyclistic_bike_share.clean_combined_tripdata`
WHERE
  TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 60
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 86400
GROUP BY
  member_casual,
  hour_of_day
ORDER BY
  hour_of_day,
  member_casual;


--To analyze monthly ride volume for casual riders and annual members and identify changes in riding activity throughout the year.
EXTRACT(YEAR FROM started_at) AS ride_year,
  EXTRACT(MONTH FROM started_at) AS ride_month,
  FORMAT_DATETIME('%B', started_at) AS month_name,
  COUNT(*) AS total_rides
FROM
  `capstone-project-1-511517.Cyclistic_bike_share.clean_combined_tripdata`
WHERE
  TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 60
  AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 86400
GROUP BY
  member_casual,
  ride_year,
  ride_month,
  month_name
ORDER BY
  ride_year,
  ride_month,
  member_casual;






