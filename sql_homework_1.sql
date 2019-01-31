-- Use Sakila db for the following statements --
USE sakila;

-- Display first and last name columns from actor table
SELECT first_name, last_name
	FROM actor;
    
-- Add new column named ActorName
ALTER TABLE actor
ADD  `Actor Name` VARCHAR(50);

-- Add first and last name of each actor into ActorName column
UPDATE actor 
	SET `Actor Name` = CONCAT(first_name, ' ', last_name);
    
-- Display ActorName column in Upper case
SELECT `Actor Name`
	FROM actor;
 
-- Display actors whose first name is Joe
SELECT *
	FROM actor
    WHERE first_name = 'Joe';

-- Display actors with GEN in their name    
SELECT * 
	FROM actor 
    WHERE `Actor Name` like "%GEN%";
    
-- Display actors with LI in their name. Order by last then first name   
SELECT * 
	FROM actor 
    WHERE `Actor Name` like "%LI%"
    ORDER BY last_name;
    
-- Display the country_id and country columns for 3 countries 
SELECT country_id, country
	FROM country
	WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
    
-- Create a column in the table actor named description and use the data type BLOB (for binary data such as an image or audio) 
ALTER TABLE actor
ADD description BLOB;

SELECT *
	FROM actor;

-- Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

SELECT *
	FROM actor;

-- List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS `Number of Actors`
	FROM actor
	GROUP BY 1;
    
-- List last names of actors and the number of actors for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS `Number of Actors`
	FROM actor 
	GROUP BY 1
    HAVING `Number of Actors` >= 2;
    
-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor 
	SET first_name = "HARPO", `Actor Name` = "HARPO WILLIAMS"
    WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

SELECT *
	FROM actor;

 -- Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
 -- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
	SET first_name = "GROUCHO", `Actor Name` = "GROUCHO WILLIAMS"
    WHERE first_name = "HARPO" AND last_name = "WILLIAMS";
    
SELECT *
	FROM actor;
    
-- You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
 
-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address
	FROM staff AS s
    JOIN address AS a
    ON s.address_id = a.address_id; 


-- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(p.amount) `Total Amount`
	FROM staff AS s
    JOIN payment AS p
    ON s.staff_id = p.staff_id
    WHERE p.payment_date >= '2005-08-01' AND p.payment_date  <= '2005-08-31'
    GROUP BY 1;
    
-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, SUM(fa.actor_id) `Number of Actors`
	FROM film AS f
    JOIN film_actor AS fa
    ON f.film_id = fa.film_id
    GROUP BY 1;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, SUM(i.inventory_id) `Number of Copies`
	FROM film AS f
    JOIN inventory AS i
    ON f.film_id = i.film_id
    WHERE f.title = "Hunchback Impossible"
    GROUP BY 1;

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT c.last_name, c.first_name, SUM(p.amount) `Total Payment`
	FROM customer AS c
    JOIN payment AS p
    ON c.customer_id = p.customer_id
    GROUP BY 1
    ORDER BY 1 ASC;
    
SELECT *
	FROM language;

-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
	FROM film
    WHERE language_id IN 
 (
    SELECT language_id
    FROM language 
    WHERE `name` = "English" AND title IN
(	SELECT title
	FROM film
    WHERE title LIKE 'K%' OR title Like 'Q%'
)
); 
        
-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
	FROM actor
    WHERE actor_id IN 
 (
    SELECT actor_id
    FROM film 
    WHERE `title` = "Alone Trip" 
); 

-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
-- Method 1
SELECT c.last_name, c.first_name, c.email 
	FROM customer AS c
    JOIN address AS a
    ON c.address_id = a.address_id
    WHERE a.city_id IN 
(
	SELECT city_id
    FROM city cy
    JOIN country co
    ON cy.country_id = co.country_id
    WHERE `country` = "Canada" 
);

-- Method 2
SELECT c.last_name, c.first_name, c.email 
	FROM customer c
	JOIN address a
		ON c.address_id = a.address_id
	JOIN city cy
		ON a.city_id = cy.city_id
	JOIN country co 
		ON cy.country_id = co.country_id
	WHERE `country` = "Canada" ;

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
-- Method 1
SELECT f.title
	FROM film f
    JOIN film_category fc
    ON f.film_id = fc.film_id
    WHERE fc.category_id IN
(
    SELECT category_id
    FROM category 
    WHERE `name` = "Family" 
);

-- Method 2
SELECT f.title 
	FROM film f
	JOIN film_category fc
		ON f.film_id = fc.film_id
	JOIN category ca
		ON fc.category_id = ca.category_id
	WHERE `name` = "Family";

-- Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(f.film_id) `Number of times rented`
	FROM film f
	JOIN inventory i
		ON f.film_id = i.film_id
	JOIN rental r
		ON i.inventory_id = r.inventory_id
	GROUP BY 1
    ORDER BY 2 DESC;

-- Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) `Amount of Business ($)`
	FROM store s
	JOIN inventory i
		ON s.store_id = i.store_id
	JOIN rental r
		ON i.inventory_id = r.inventory_id
	JOIN payment p
		ON r.customer_id = p.customer_id
	GROUP BY 1;

-- Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, co.country
	FROM store s
	JOIN address a
		ON s.address_id = a.address_id
	JOIN city c
		ON a.city_id = c.city_id
	JOIN country co
		ON c.country_id = co.country_id
	GROUP BY 1;

-- List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT ca.name, SUM(p.amount) `Gross Revenue`
	FROM category ca
    JOIN film_category fc
		ON fc.category_id = ca.category_id
	JOIN inventory i
		ON fc.film_id = i.film_id
	JOIN rental r
		ON i.inventory_id = r.inventory_id
	JOIN payment p
		ON r.customer_id = p.customer_id
	GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 5;

-- In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top5_genres_bygrossrevenue AS
SELECT ca.name, SUM(p.amount) `Gross Revenue`
	FROM category ca
    JOIN film_category fc
		ON fc.category_id = ca.category_id
	JOIN inventory i
		ON fc.film_id = i.film_id
	JOIN rental r
		ON i.inventory_id = r.inventory_id
	JOIN payment p
		ON r.customer_id = p.customer_id
	GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 5;

-- How would you display the view that you created in 8a?
SELECT *
	FROM top5_genres_bygrossrevenue;

-- You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top5_genres_bygrossrevenue;