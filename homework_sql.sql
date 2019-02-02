use sakila;
#DONE 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name 
FROM sakila.actor;

#DONE 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT concat(first_name,' ',last_name) ActorName
FROM sakila.actor;

#DONE 2a. You need to find the ID number, first name, and last name of an actor, of whom you know 
#only the first name, "Joe." What is one query would you use to obtain this information?
select 
	actor_id, first_name, last_name
from 
	sakila.actor
where first_name = 'JOE';

#DONE 2b. Find all actors whose last name contain the letters `GEN`:
select 
	first_name, last_name
from
	sakila.actor
where
	last_name like '%Gen%';
    
#done 2c. Find all actors whose last names contain the letters `LI`. This time, 
#order the rows by last name and first name, in that order:
select 
	first_name, last_name
from 
	sakila.actor
where
	last_name like '%LI%'
ORDER BY
	last_name, first_name;

#DONE   2d. Using `IN`, display the `country_id` and `country` columns of the following 
#countries: Afghanistan, Bangladesh, and China:
#select * from sakila.country
select
	country_id, country
from 
	sakila.country
where
	country IN ('Afghanistan', 'Bangladesh', 'China');

#DONE 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
#so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the 
#type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description blob;

#SELECT * from sakila.actor;
#DONE   3b. Very quickly you realize that entering descriptions for each actor is too much effort.
#Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

#SELECT * from sakila.actor;
#DONE    4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*)
FROM actor
GROUP BY last_name;

#DONE 4b. List last names of actors and the number of actors who have that last name,
# but only for names that are shared by at least two actors
SELECT last_name, count(*)
FROM actor
GROUP BY last_name
HAVING count(*) >= 2;

#DONE4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`.
# Write a query to fix the record.
select last_name, first_name
from sakila.actor
WHERE LAST_NAME ='williams';# and first_name = 'groucho';

update actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and LAST_NAME ='williams';


#DONE    4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
#In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' and LAST_NAME ='williams';

#DONE	5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
#SHOW TABLES;
describe address;

#DONE           6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
#Use the tables `staff` and `address`:
#SELECT * from sakila.payment;
#SELECT * from sakila.address;

select first_name, last_name, address
from staff
join address
using(address_id);

#DONE       6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
#test - ok -- SELECT staff_id, amount, payment_date from sakila.payment;

select st.first_name, st.last_name, st.staff_id, sum(py.amount) as 'Aug 2005 total receipts'
from staff st, payment py 
WHERE py.staff_id = st.staff_id 
  and YEAR(py.payment_date) = 2005 
  and month(py.payment_date) = 08
group by py.staff_id
;

#DONE		 6c. List each film and the number of actors who are 
#   listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT fi.title, count(fa.actor_id) as 'Total Actors by film'
from sakila.film fi, sakila.film_actor fa
where fi.film_id = fa.film_id
group by fi.film_id;

######################
#DONE	6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
#SELECT * from sakila.film where film_id = 439;
#SELECT * from sakila.inventory where film_id = 439;

SELECT fi.title, fi.film_id, count(inv.inventory_id)
from sakila.inventory inv, sakila.film fi
where fi.film_id = inv.film_id
	and fi.film_id in 
	(
		SELECT fi2.film_id
		from film fi2
		where fi2.title = 'Hunchback Impossible'
	);

#DONE     6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
# List the customers alphabetically by last name:
select cu.first_name, cu.last_name, sum(py.amount)
from sakila.payment py, sakila.customer cu
where py.customer_id = cu.customer_id
group by cu.last_name;

#DONE      7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters `K` and `Q` have also soared in popularity.
# Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select fi.title as 'English films starting wit Q or K'
from sakila.film fi, sakila.language lang
where fi.language_id = lang.language_id
and lang.language_id in
	(
    select lang2.language_id
    from sakila.language lang2
    where lang2.name = 'English'
    )
and fi.title in
	(
    select fi2.title
    from sakila.film fi2
    where fi2.title like 'K%' or fi2.title like 'Q%'
    )
;
#DONE		7b. Use subqueries to display all actors who appear in the film `Alone Trip`
select first_name, last_name
from actor
where actor_id IN
(
select actor_id
from film_actor
where film_id IN
(
select film_id
from film
where title like 'Alone Trip')
);
    
#DONE		7c. You want to run an email marketing campaign in Canada, 
#for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select 
	cust.email, cust.first_name, cust.last_name
from sakila.customer cust
where cust.address_id in 
	(
    SELECT address_id 
    from sakila.address
    where city_id in
    (
	select city_id 
    from sakila.city
    where country_id in 
    (
    select country_id
    from sakila.country
    where country = "Canada")
    )
    );
#DONE	7d. Sales have been lagging among young families, 
# and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films. 
SELECT f.title#, count(inv.store_id)
from sakila.film f
where f.film_id in
	(
    select film_id
    from film_category
    where category_id in 
    (
	select cat.category_id #, count(inv.store_id)
	from sakila.category cat
	where name = "Family"
    ));
#DONE	 7e. Display the most frequently rented movies in descending order.
SELECT f.title
from sakila.film f
where film_id in 
	(
	SELECT inv.film_id
	from sakila.inventory inv
	group by inv.film_id desc
    );
#SELECT title from sakila.film; 
#SELECT * from sakila.rental;

#DONE	 7f. Write a query to display how much business, in dollars, each store brought in.
#SELECT title from sakila.payment; 
#SELECT * from sakila.customer;
select cust.store_id as "Store", sum(pay.amount) as "Total by Store"
from sakila.customer cust, sakila.payment pay
where cust.customer_id = pay.customer_id
group by cust.store_id;


#DONE 	7g. Write a query to display for each store its store ID, city, and country.
#select * from sakila.address limit 10;

select st.store_id, st2.address, c.city, cou.country
from sakila.store st, sakila.address st2, sakila.city c, sakila.country cou
WHERE st.address_id = st2.address_id
	and st2.city_id = c.city_id
	and cou.country_id  = c.country_id;

#DONE 	7h. List the top five genres in gross revenue in descending order. 
#(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT cat.name, sum(pay.amount)
from sakila.category cat, sakila.film_category fc, sakila.payment pay, sakila.rental r, sakila.inventory inv
where pay.rental_id = r.rental_id
and r.inventory_id = inv.inventory_id
and inv.film_id = fc.film_id
and fc.category_id = cat.category_id
group by cat.name
order by  sum(pay.amount) desc
limit 5;

#select * from sakila.film_category;
#* 	8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view amount_genre as
(SELECT cat.name, sum(pay.amount)
from sakila.category cat, sakila.film_category fc, sakila.payment pay, sakila.rental r, sakila.inventory inv
where pay.rental_id = r.rental_id
and r.inventory_id = inv.inventory_id
and inv.film_id = fc.film_id
and fc.category_id = cat.category_id
group by cat.name
order by  sum(pay.amount) desc
limit 5);
# 	8b. How would you display the view that you created in 8a?
select * from amount_genre;
#	8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view amount_genre;