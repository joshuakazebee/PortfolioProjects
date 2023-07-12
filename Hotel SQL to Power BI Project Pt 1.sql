-- Combine the three years into one temporary table

CREATE VIEW PortfolioProjects.hotelview
AS

WITH hotels AS (
SELECT * FROM dbo.[2018]
UNION
SELECT * FROM dbo.[2019]
UNION
SELECT * FROM dbo.[2020]
)
-- This is some exploratory analysis by creating a new column showing revenue and aggregating by year

--SELECT arrival_date_year, 
--hotel,
--ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights) * adr),0)
--AS revenue
--FROM hotels
--GROUP BY arrival_date_year, hotel

-- This completes the full table that will exported to 
-- Power BI by using a left join to bring in the meal cost and market segment tables

SELECT * FROM hotels
LEFT JOIN
dbo.market_segment
ON
hotels.market_segment = market_segment.market_segment
LEFT JOIN
dbo.meal_cost
ON
hotels.meal = meal_cost.meal

ALTER TABLE hotels DROP COLUMN market_segment
