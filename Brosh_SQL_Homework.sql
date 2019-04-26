-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT *, concat(first_name, " ", last_name) AS Actor_Name
FROM sakila.actor;

-- drop last update column
ALTER TABLE sakila.actor 
DROP COLUMN last_update;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM sakila.actor 
WHERE first_name = 'Joe';
 
-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name
FROM sakila.actor 
WHERE last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, last_name, first_name
FROM sakila.actor 
WHERE last_name LIKE '%li%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM sakila.country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB
ALTER TABLE sakila.actor 
ADD COLUMN description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE sakila.actor 
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS Number_Of_Actors
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS Number_Of_Actors
FROM actor
GROUP BY last_name
HAVING COUNT(*) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE sakila.actor SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE sakila.actor SET first_name = 'GROUCHO' 
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
DESCRIBE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
USE sakila;

SELECT first_name, last_name, address
FROM staff
INNER JOIN address ON address.address_id = staff.address_id;

-- * Check lines in staff *
SELECT COUNT(*) FROM staff;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT payment.amount, staff.first_name, staff.last_name, payment.payment_date
FROM payment
INNER JOIN staff ON payment.payment_id = staff.address_id AND payment.payment_date LIKE '%2005-08%';

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title AS 'Film Title', COUNT(film_actor.actor_id) AS `Number of Actors`
FROM film_actor
INNER JOIN film
ON film_actor.film_id= film.film_id
GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, (
SELECT COUNT(*) FROM inventory
WHERE film.film_id = inventory.film_id
) AS 'Number of Copies'
FROM film
WHERE title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, sum(payment.amount) AS `Total Paid`
FROM customer
JOIN payment
ON customer.customer_id= payment.customer_id
GROUP BY customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT film.title
from film
where title like 'Q%' or title like 'K%'
and language_id in (select language_id from language where name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select actor.first_name, actor.last_name
from actor
where actor_id in (select actor_id from film_actor where film_id = 
(select film_id from film where title = 'Alone Trip'));


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select customer.email, customer.first_name, customer.last_name
from customer
inner join address on customer.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id
where country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT film.title, category.name
FROM category
INNER JOIN film_category on film_category.category_id = category.category_id
INNER JOIN film on film.film_id = film_category.film_id
WHERE category.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title AS 'Film_Title', COUNT(rental.rental_id) As 'Number_Of_Rentals'
FROM rental
INNER JOIN inventory on rental.inventory_id = inventory.inventory_id
INNER JOIN film on film.film_id = inventory.film_id
GROUP BY film.title
ORDER BY Number_Of_Rentals DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(payment.amount) As 'Total_Payment'
FROM store
INNER JOIN staff on staff.store_id = store.store_id
INNER JOIN payment on payment.staff_id = staff.staff_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address on address.address_id = store.address_id
INNER JOIN city on city.city_id = address.city_id
INNER JOIN country on country.country_id = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name AS 'Genre', SUM(payment.amount) AS 'Gross_Revenue'
FROM category
INNER JOIN film_category ON film_category.category_id = category.category_id
INNER JOIN inventory ON inventory.film_id = film_category.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW revenue_by_genre AS 
SELECT category.name AS 'Genre', SUM(payment.amount) AS 'Gross_Revenue'
FROM category
INNER JOIN film_category ON film_category.category_id = category.category_id
INNER JOIN inventory ON inventory.film_id = film_category.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM revenue_by_genre;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW revenue_by_genre;


