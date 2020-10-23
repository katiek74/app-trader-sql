/* star ratings by: Genre, Content_Rating, Price
Which are available in both stores?

Are measures different in each store?
APP STORE								PLAY STORE
primary_genre							category (or genres?)
content_rating (4+, 9+, 12+, 17+)		Everyone, Everyone 10+, Teen, Mature 17+, Adults only 18+, Unrated
rating 0, 1.0, 1.5 (by .5)				by .1					
price 0.00-299.99 (no $,numeric format)	0 to $400.00 - note, no $ on 0, but on all others, text format
*/

--to remove the + from install count: SELECT translate(install_count,'+','') as new_install_count FROM play_store_apps

SELECT *
FROM app_store_apps
LIMIT 20;

SELECT *
FROM play_store_apps
LIMIT 20;


/*
Costs:
•	Purchase Price = 10,000 times the price of the app (For apps price $0 - $1 the purchase price is $10,000)
•	$1000 per month to market an app (If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month which is preferred)

Earnings:
•	All apps earn $5000 per month on average from in-app advertising and in-app purchases 
•	For every half point that an app gains in rating, its projected lifespan increases by one year 
	o	i.e. an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years. 
	o	Ratings should be rounded to the nearest 0.5 to evaluate an app's likely longevity. */

--Develop a Top 10 List of the apps that App Trader should buy next week for its Black Friday debut.

SELECT app_store_apps.name AS app_store_name, app_store_apps.price AS app_store_price, play_store_apps.price AS play_store_price,
		app_store_apps.rating AS app_store_rating, play_store_apps.rating AS play_store_rating, 
		ROUND(app_store_apps.rating + play_store_apps.rating)/2 AS avg_rating, play_store_apps.install_count, app_store_apps.review_count
FROM app_store_apps
		FULL JOIN play_store_apps
		ON app_store_apps.name = play_store_apps.name
WHERE play_store_apps.name IS NOT NULL
AND app_store_apps.name IS NOT NULL
AND app_store_apps.price < 2.00
AND app_store_apps.rating >= 4.5
GROUP BY app_store_name, app_store_rating, play_store_rating, app_store_price, play_store_price, play_store_apps.install_count, app_store_apps.review_count
ORDER BY avg_rating DESC;

/*Based on ratings, price, install & review counts (to determine popularity), we picked the following:
Egg Inc. - free, 5 star - cost: $10,000 to purchase, $1000/month; earnings: $5000/month for 11 years
Domino's Pizza USA - free, 5 star - cost: $10,000 to purchase, $1000/month; earnings: $5000/month for 11 years
Geometry Dash Lite - free, 5 star - cost: $10,000 to purchase, $1000/month; earnings: $5000/month for 11 years
PewDiePie's Tuber Simulator - free, 5 star - cost: $10,000 to purchase, $1000/month; earnings: $5000/month for 11 years
Cytus - $1.99 in app store, free in play store, 5 star - cost: $19,900 to purchase, $1000/month; earnings: $5000/month for 11 years
The Guardian - free, 5 star - cost: $10,000 to purchase, $1000/month; earnings: $5000/month for 11 years
ASOS - free, 5 star - cost: $10,000 to purchase, $1000/month; earnings: $5000/month for 11 years
Clash Royale (94) - free, 4.5 star, 100M+ downloads, 250k+ review count - cost: $10,000 to purchase, $1000/month; earnings: $5000/month for 10 years
Bible (86) - free, 4.5 star, 100M+ downloads, nearly 1M review count - cost: $10,000 to purchase, $1000/month; earnings: $5000/month for 10 years
Clash of Clans (67) - free, 4.5 star, 100M+ downloads, 2M+ review count - cost: $10,000 to purchase, $1000/month; earnings: $5000/month for 10 years
*/

--Develop some general recommendations as to the price range

--this shows average rating and price
SELECT  app_store_apps.price AS app_store_price, count(app_store_apps.*), CAST(CAST(play_store_apps.price as money) as numeric) AS play_store_price,
		ROUND(app_store_apps.rating + play_store_apps.rating)/2 AS avg_rating
FROM app_store_apps
		FULL JOIN play_store_apps
		ON app_store_apps.name = play_store_apps.name
WHERE play_store_apps.name IS NOT NULL
AND app_store_apps.name IS NOT NULL
GROUP BY app_store_price, play_store_price, avg_rating 
ORDER BY app_store_price;

--this shows user ratings by price
SELECT app_store_apps.price,
		AVG((app_store_apps.rating + play_store_apps.rating)/2) AS avg_rating,COUNT(app_store_apps.name)
FROM app_store_apps
		FULL JOIN play_store_apps
		ON app_store_apps.name = play_store_apps.name
WHERE play_store_apps.name IS NOT NULL
AND app_store_apps.name IS NOT NULL
GROUP BY app_store_apps.price
ORDER BY app_store_apps.price DESC;

--free apps show more profit based on the information given


--Develop some general recommendations as to the genre

--this shows the average count, price and rating by genre
SELECT 'app_store' as platform,
primary_genre, COUNT(*), CAST(AVG(price) as money) as avg_price, ROUND(AVG(rating),2) as avg_rating  
FROM app_store_apps
GROUP BY primary_genre
UNION ALL
SELECT 'play_store' as platform,
category, COUNT(*), cast(avg(CAST((CAST(price as money)) as numeric)) as money) as avg_price, ROUND(AVG(rating),2) as avg_rating  
FROM play_store_apps
GROUP BY category
ORDER BY avg_rating desc;

/*top 10 genres APP store:
"Games"
"Entertainment"
"Education"
"Photo & Video"
"Utilities"
"Health & Fitness"
"Productivity"
"Social Networking"
"Lifestyle"
"Music"

top 10 categories PLAY store:
"FAMILY"
"GAME"
"TOOLS"
"MEDICAL"
"BUSINESS"
"PRODUCTIVITY"
"PERSONALIZATION"
"COMMUNICATION"
"SPORTS"
"LIFESTYLE"*/

/*Develop some general recommendations as to the content rating
APP STORE								PLAY STORE
content_rating (4+, 9+, 12+, 17+)		Everyone, Everyone 10+, Teen, Mature 17+, Adults only 18+, Unrated*/
		
--this shows the average price and rating across the two stores by content rating:		
SELECT 'app_store' as platform,
content_rating, ROUND(AVG(rating),2) as avg_rating, CAST(avg(price) as money) as avg_price, count(*)
FROM app_store_apps
GROUP BY content_rating
UNION ALL
SELECT 'play_store' as platform,
content_rating, ROUND(AVG(rating),2) as avg_rating, cast(avg(CAST((CAST(price as money)) as numeric)) as money) as avg_price, count(*)
FROM play_store_apps 
WHERE content_rating NOT LIKE 'Unrated' AND content_rating NOT LIKE 'Adults%'
GROUP BY content_rating
ORDER BY avg_rating DESC;

--This shows the genres/categories that have each content rating
SELECT 'play_store' as platform,
category, content_rating
FROM play_store_apps
WHERE content_rating NOT LIKE 'Unrated'
GROUP BY category, content_rating
UNION ALL
SELECT 'app_store' as platform,
primary_genre, content_rating
FROM APP_store_apps
GROUP BY primary_genre, content_rating
ORDER BY content_rating;

--Develop some general recommendations as to anything else for apps that the company should target - app size??

