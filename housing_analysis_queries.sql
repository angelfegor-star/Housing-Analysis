SELECT *
FROM housing;

-- Q1a. Median and average price by state
WITH state_prices AS (
	SELECT
		state,
        COUNT(*)					AS listing_count,
        ROUND(AVG(price), 0)		AS avg_price,
        ROUND(MIN(price), 0)		AS min_price,
        ROUND(MAX(price), 0)		AS max_price
	FROM housing
    WHERE price IS NOT NULL
    GROUP BY state
),
national_avg AS (
	SELECT ROUND(AVG(price), 0)		AS national_price
    FROM housing
)
SELECT
	sp.*,
    na.national_price,
    ROUND((sp.avg_price - na.national_price)
    / na.national_price * 100, 1)	AS pct_vs_national
    FROM state_prices sp
    CROSS JOIN national_avg na
    ORDER BY avg_price DESC;
    
    -- Q2a. Average price per sqft by state
    WITH sqft_by_state AS (
		SELECT
			state,
            ROUND(AVG(price_per_sqft), 2)		AS avg_price_sqft,
            ROUND(AVG(house_size),  0)			AS avg_house_size,
            COUNT(*)							AS listings
		FROM housing
        WHERE price_per_sqft IS NOT NULL
			AND price_per_sqft < 2000
		GROUP BY state
        HAVING listings >= 50    
    )
    SELECT *
    FROM sqft_by_state
    ORDER BY avg_price_sqft DESC;
    
-- Q2b. How does price per sqft change with house size?
SELECT
	CASE
		WHEN house_size < 1000	THEN 'Under 1000 sqft'
        WHEN house_size < 2000	THEN '1000-2000 sqft'
        WHEN house_size < 3000	THEN '2000-3000 sqft'
        WHEN house_size < 5000	THEN '3000-5000 sqft'
        ELSE 'Over 5000 sqft'
	END									AS size_band,
	COUNT(*)							AS listings,
    ROUND(AVG(price_per_sqft),  2)		AS avg_price_sqft,
    ROUND(AVG(price),  0)				AS avg_total_price
FROM housing
WHERE price_per_sqft < 2000
GROUP BY size_band
ORDER BY avg_price_sqft DESC;

-- Q3a. Average price by bedroom count
SELECT
	bed,
    COUNT(*)						AS listings,
    ROUND(AVG(price),  0)			AS avg_price,
    ROUND(AVG(price_per_sqft),  2)	AS avg_price_sqft
FROM housing
WHERE bed BETWEEN 1 AND 7
	AND price IS NOT NULL
GROUP BY bed
ORDER BY bed;

-- Q3b. Incrementalprice per additional bedroom
WITH bed_prices AS (
	SELECT
		bed,
        ROUND(AVG(price),  0)			AS avg_price
	FROM housing
	WHERE bed BETWEEN 1 AND 7
	AND price IS NOT NULL
	GROUP BY bed
)
SELECT
	bed,
    avg_price,
    LAG(avg_price) OVER(ORDER BY bed)		AS prev_bed_price,
    avg_price -  LAG(avg_price) OVER(ORDER BY bed)		AS incremental_value
FROM bed_prices;
    