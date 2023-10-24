/* --------------------
   Case Study Questions
   --------------------*/
-- 1. What is the total amount each customer spent at the restaurant?
      -- A: $76 | B: $74 | C: $36 
-- 2. How many days has each customer visited the restaurant?
      -- A: 4 days | B: 6 days | C: 2 days
-- 3. What was the first item from the menu purchased by each customer?
      -- A: 1 | B: 2 | C: 3 Key: defining window function in CTE
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- #1: What is the total amount each customer spent at the restaurant?
SELECT
	s.customer_id,
    SUM(m.price) AS total_spent
FROM dannys_diner.sales AS s
		JOIN 
    dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY s.customer_id -- the group by at this level consolidates customer_id so that no duplicate rows display --
ORDER BY s.customer_id; 
-- A: $76 | B: $74 | C: $36 


-- #2: How many days has each customer visited the restaurant?
SELECT 
	customer_id,
    COUNT(DISTINCT order_date)
FROM dannys_diner.sales 
GROUP BY customer_id;
-- A: 4 days | B: 6 days | C: 2 days

-- #3: What was the first item from the menu purchased by each customer?
WITH cte AS (
  SELECT
	ROW_NUMBER() OVER w as row_num,
    customer_id,
    order_date,
    product_id
FROM dannys_diner.sales
WINDOW w AS (PARTITION BY customer_id ORDER BY order_date))

SELECT
    customer_id,
    product_id
FROM cte
WHERE row_num = 1;
-- A: 1 | B: 2 | C: 3 Key: defining window function in CTE


-- #4: What is the most purchased item on the menu and how many times was it purchased by all customers?
# Step 1) Find the count of each product (use to validate answer)
SELECT
	product_id,
    COUNT(product_id) as num_purchased
FROM sales
GROUP BY product_id;

# Step 2) Find the MAX count of menu items purchased (using a subquery) & a join to return the menu item's name
SELECT
	pc.product_id,
    m.product_name,
    pc.num_purchased as most_ordered_item
FROM (
	SELECT
		product_id,
		COUNT(product_id) as num_purchased
	FROM sales
	GROUP BY product_id) as pc
		JOIN
	menu m ON pc.product_id = m.product_id
GROUP BY pc.product_id, m.product_name
ORDER BY most_ordered_item DESC;
-- Ramen was ordered 8 times
	

-- #5: Which item was the most popular for each customer?
# notes: similar to question 4 with the focus on the customer
# Step 1) 
WITH cte AS (
SELECT
	customer_id,
    product_id,
    COUNT(product_id) as times_ordered,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) as row_num
FROM sales
GROUP BY customer_id, product_id
)

SELECT
	customer_id,
    m.product_name
FROM cte
		JOIN
	menu m ON cte.product_id = m.product_id
WHERE row_num = 1
ORDER BY customer_id;
-- Customer A's most ordered dish is ramen | B: curry | C: ramen


-- 6: Which item was purchased first by the customer after they became a member?
# Step 1) Join sales & member table
SELECT
	s.customer_id,
    s.order_date,
    s.product_id,
    m.join_date
FROM
	sales s
		JOIN
	members m ON s.customer_id = m.customer_id;

# Step 2) Rank the items the members ordered after becoming members (note: customer C did not become a member & is excluded from the data)
SELECT
	s.customer_id,
    s.product_id,
    s.order_date,
    RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as row_num
FROM
	sales s
		JOIN
	members m ON s.customer_id = m.customer_id
WHERE s.order_date >= m.join_date
;

# Step 3) use a cte of the previous query to allow you to extract only the first items ordered for each customer after they became members
WITH cte AS (
SELECT
	s.customer_id,
    s.product_id,
    s.order_date,
    RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as row_num
FROM
	sales s
		JOIN
	members m ON s.customer_id = m.customer_id
WHERE s.order_date >= m.join_date
)
SELECT
	customer_id,
    product_id
FROM cte
WHERE row_num = 1;
-- Customer A ordered item 2 first after becoming a member | B: 1 (could replace product_id with product_name with another join, if needed)

-- 7: Which item was purchased just before the customer became a member?
# Reverse the logic of the previous problem: WHERE order_date <= join_date AND ORDER BY order_date DESC - this will get you the item the cust. ordered right before becoming a member
WITH cte AS (
SELECT
	s.customer_id,
    s.product_id,
    s.order_date,
    RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) as row_num
FROM
	sales s
		JOIN
	members m ON s.customer_id = m.customer_id
WHERE s.order_date <= m.join_date
)
SELECT
	cte.customer_id,
    m.product_name
FROM cte
		JOIN
	menu m ON cte.product_id = m.product_id
WHERE row_num = 1
ORDER BY customer_id;
-- Customer A had curry right before becoming a member | B: sushi
  # with more data, could be worth exploring the meals people have before becoming a member & begin defining demographics (one way of possibly increasing membership)
  

-- 8: What is the total items and amount spent for each member before they became a member?
# Step 1) create the data set to use
SELECT
	s.customer_id,
    s.product_id,
    s.order_date,
    menu.price
FROM
	sales s
		JOIN
	members m ON s.customer_id = m.customer_id
		JOIN
	menu ON s.product_id = menu.product_id
WHERE s.order_date <= m.join_date
ORDER BY customer_id;

# Step 2) Query the new data set 
WITH cte AS (
SELECT
	s.customer_id,
    s.product_id,
    s.order_date,
    menu.price
FROM
	sales s
		JOIN
	members m ON s.customer_id = m.customer_id
		JOIN
	menu ON s.product_id = menu.product_id
WHERE s.order_date <= m.join_date
)

SELECT
	customer_id,
    COUNT(product_id) as total_items,
    SUM(price) as total_spent -- assumption: each item is qty 1 on each order, thus no need to multiple price * qty 
FROM cte
GROUP BY customer_id;
-- Customers A & B (C did not become a member) ordered 3 items and spent $40 before becoming a member.


-- 9:  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
# Step 1) Define points per menu item
SELECT
	product_id,
    product_name,
    price,
    CASE WHEN product_name = 'sushi' THEN price * 2 ELSE price END AS points
FROM menu;

# Step 2) Find total $ spent per customer
SELECT
	s.customer_id,
    SUM(price) as total_spent
FROM sales s
		JOIN
	menu m ON s.product_id = m.product_id
GROUP BY s.customer_id; # (A: $76 | B: $74 | C: $36)

# Step 3) Translate $ spent per to points
WITH cte AS (
SELECT
	product_id,
    product_name,
    price,
    CASE WHEN product_name = 'sushi' THEN price * 2 ELSE price END AS points
FROM menu
)

SELECT
	s.customer_id,
    SUM(cte.price) as total_spent,
	SUM(cte.points) as total_points
FROM sales s
		JOIN
	cte ON s.product_id = cte.product_id
GROUP BY s.customer_id;
-- Points by Customer: A = 86 | B = 94 | C = 36


-- 10: In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
# Step 1) Define the point system (prob. 9 + 2x points on all items during week of membership)
SELECT
	s.customer_id,
    m.product_id,
    m.product_name,
    s.order_date,
    mem.join_date,
    m.price,
    CASE
		WHEN DATEDIFF(s.order_date, mem.join_date) BETWEEN 0 AND 7 THEN m.price * 2
        ELSE m.price
	END AS points
FROM menu m
		LEFT JOIN
	sales s ON m.product_id = s.product_id
		LEFT JOIN
	members mem ON s.customer_id = mem.customer_id
WHERE order_date <= '2021-01-31'
ORDER BY customer_id, order_date;

# Step 2) Expand the case statement logic     
SELECT
	s.customer_id,
    m.product_id,
    m.product_name,
    s.order_date,
    mem.join_date,
    m.price,
    CASE
		WHEN m.product_name = 'sushi' THEN m.price * 2  
        WHEN DATEDIFF(s.order_date, mem.join_date) BETWEEN 0 AND 7 THEN m.price * 2
        ELSE m.price
	END AS points
FROM menu m
		LEFT JOIN
	sales s ON m.product_id = s.product_id
		LEFT JOIN
	members mem ON s.customer_id = mem.customer_id
WHERE order_date <= '2021-01-31'
ORDER BY customer_id, order_date;

# Step 3) Wrap this up as a CTE and aggregate the data to find total points (similar to final query in #9)
WITH cte AS (
SELECT
	s.customer_id,
    m.product_id,
    m.product_name,
    s.order_date,
    mem.join_date,
    m.price,
    CASE
		WHEN m.product_name = 'sushi' THEN m.price * 2  
        WHEN DATEDIFF(s.order_date, mem.join_date) BETWEEN 0 AND 7 THEN m.price * 2
        ELSE m.price
	END AS points
FROM menu m
		LEFT JOIN
	sales s ON m.product_id = s.product_id
		LEFT JOIN
	members mem ON s.customer_id = mem.customer_id
WHERE order_date <= '2021-01-31'
ORDER BY customer_id, order_date
)

SELECT
	customer_id,
    SUM(points) AS total_points
FROM cte
GROUP BY customer_id;
-- Total points by customer: A = 137 | B = 94 | C = 36 (the big benefitor of the new rule/logic is customer A - means they ordered either the most within the week following their membership or the didn't always order sushi - customer B didn't benefit from new rule but ordered several times after becoming a member)