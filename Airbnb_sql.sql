-- KPI Queries

--1.Write a query to count the total number of listings in the dataset.

	SELECT COUNT(id) AS total_number_of_listings
	FROM listings;
	
--2.Write a query to find the average price of all listings.

	SELECT ROUND(AVG(p.price),2) AS Avg_price_of_all_listings
	FROM pricing p 
	JOIN listings l ON l.id = p.listing_id;
	
--3.Write a query to show the number of listings for each room_type.

	SELECT room_type, COUNT(id) AS number_of_listings
	FROM listings
	GROUP BY 1
	ORDER BY 2 DESC;
	
--4.Write a query to count the distinct number of hosts.

	SELECT DISTINCT COUNT(host_id) AS distinct_number_of_host
	FROM hosts;
	
--5.Write a query to find the number of listings in each borough (neighbourhood_group).

	SELECT neighbourhood_group, COUNT(id) AS number_of_listings
	FROM listings
	GROUP BY 1
	ORDER BY 2 DESC;
	

--6.Write a query to calculate the average price per room_type in each borough.
SELECT l.neighbourhood_group,
       l.room_type,
       ROUND(AVG(p.price), 2) AS avg_price
FROM listings l
JOIN pricing p ON l.id = p.listing_id
GROUP BY l.neighbourhood_group, l.room_type
ORDER BY l.neighbourhood_group, l.room_type;

	
--7.Write a query to list the top 10 neighbourhoods by total number of listings.
SELECT l.neighbourhood,
       COUNT(*) AS total_listings
FROM listings l
GROUP BY l.neighbourhood
ORDER BY total_listings DESC
LIMIT 10;

--8.Write a query to find the average availability (availability_365) for each room_type in NYC.
SELECT room_type,
       ROUND(AVG(availability_365), 2) AS avg_availability
FROM listings
GROUP BY room_type
ORDER BY avg_availability DESC;

--9.Write a query to calculate the average reviews_per_month for each room_type.
SELECT l.room_type,
       ROUND(AVG(r.reviews_per_month), 2) AS avg_reviews_per_month
FROM listings l
JOIN reviews r ON l.id = r.listing_id
GROUP BY l.room_type
ORDER BY 2 DESC;

--10.Write a query to show the number of listings created per year (based on last_review).
SELECT EXTRACT(YEAR FROM r.last_review)::INT AS year,
       COUNT(l.id) AS total_listings
FROM listings l
JOIN reviews r ON l.id = r.listing_id
WHERE r.last_review IS NOT NULL AND r.last_review < CURRENT_DATE
GROUP BY year
ORDER BY year;

--11.Write a query to find the borough with the highest revenue potential (calculated as price × number_of_reviews).
SELECT l.neighbourhood_group,
       CASE
           WHEN SUM(p.price * r.number_of_reviews) >= 1000000000 
                THEN CONCAT('$', ROUND(SUM(p.price * r.number_of_reviews)/1000000000.0, 2), ' B')
           WHEN SUM(p.price * r.number_of_reviews) >= 1000000 
                THEN CONCAT('$', ROUND(SUM(p.price * r.number_of_reviews)/1000000.0, 2), ' M')
           WHEN SUM(p.price * r.number_of_reviews) >= 1000 
                THEN CONCAT('$', ROUND(SUM(p.price * r.number_of_reviews)/1000.0, 2), ' K')
           ELSE CONCAT('$', ROUND(SUM(p.price * r.number_of_reviews), 2))
       END AS potential_revenue
FROM listings l
JOIN pricing p ON l.id = p.listing_id
JOIN reviews r ON l.id = r.listing_id
GROUP BY l.neighbourhood_group
ORDER BY SUM(p.price * r.number_of_reviews) DESC;


--12.Write a query to identify the top 10 hosts by total revenue potential (sum of price × number_of_reviews across their listings).
SELECT h.host_id,
       h.host_name,
       CASE
           WHEN SUM(p.price * r.number_of_reviews) >= 1000000000 
                THEN CONCAT('$', ROUND(SUM(p.price * r.number_of_reviews)/1000000000.0, 2), ' B')
           WHEN SUM(p.price * r.number_of_reviews) >= 1000000 
                THEN CONCAT('$', ROUND(SUM(p.price * r.number_of_reviews)/1000000.0, 2), ' M')
           WHEN SUM(p.price * r.number_of_reviews) >= 1000 
                THEN CONCAT('$', ROUND(SUM(p.price * r.number_of_reviews)/1000.0, 2), ' K')
           ELSE CONCAT('$', ROUND(SUM(p.price * r.number_of_reviews), 2))
       END AS total_potential_revenue
FROM hosts h
JOIN listings l ON h.host_id = l.host_id
JOIN pricing p ON l.id = p.listing_id
JOIN reviews r ON l.id = r.listing_id
GROUP BY h.host_id, h.host_name
ORDER BY SUM(p.price * r.number_of_reviews) DESC
LIMIT 10;


--13.Write a query to group listings by availability_365 ranges (0–30, 31–180, 181–365) and calculate the average price in each group.
SELECT 
    CASE 
        WHEN l.availability_365 BETWEEN 0 AND 30 THEN '0-30 days'
        WHEN l.availability_365 BETWEEN 31 AND 180 THEN '31-180 days'
        WHEN l.availability_365 BETWEEN 181 AND 365 THEN '181-365 days'
    END AS availability_range,
    ROUND(AVG(p.price), 2) AS avg_price,
    COUNT(*) AS total_listings
FROM listings l
JOIN pricing p ON p.listing_id = l.id
WHERE l.availability_365 BETWEEN 0 AND 365   
GROUP BY availability_range
ORDER BY avg_price DESC;


--14.Write a query to find the top 10 neighbourhoods with high demand but low supply (highest average reviews per listing but fewer than 50 listings).
SELECT l.neighbourhood,
       ROUND(AVG(r.number_of_reviews), 2) AS avg_reviews,
       COUNT(l.id) AS total_listings
FROM listings l
JOIN reviews r ON l.id = r.listing_id
GROUP BY l.neighbourhood
HAVING COUNT(l.id) < 50
ORDER BY avg_reviews DESC
LIMIT 10;


--15.Compare the performance of different room types (Entire home/apt, Private room, Shared room) in terms of average price, reviews, and availability.
SELECT 
    l.room_type,
    ROUND(AVG(p.price), 2) AS avg_price,
    ROUND(AVG(r.number_of_reviews), 2) AS avg_reviews,
    ROUND(AVG(l.availability_365), 2) AS avg_availability,
    COUNT(*) AS total_listings
FROM listings l
JOIN pricing p ON l.id = p.listing_id
JOIN reviews r ON l.id = r.listing_id
GROUP BY l.room_type
ORDER BY avg_price DESC;

