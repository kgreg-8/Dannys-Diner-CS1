# Dannys-Diner-CS1
Danny Ma's 8 Week SQL Challenge Case Study #1 (The Taste of Success) - https://8weeksqlchallenge.com/case-study-1/ 

*_Analysis Overview_*
* Ramen is the most ordered dish (ordered 8 times).
* Customer A appears to be the most loyal customer (based on loyalty points and observations of behavior), but Customer B visited the restaurant the most times (6).
* Recommendations:
>* Increase Membership 
>>* With more data over time, exploring the meals people have before becoming a member can allow you to begin defining demographics of your audience and run promos tailored to incentivize customers to try the menu items most likely to lead to them becoming a member.

*_Complexities_*
* CTEs (Common Table Expressions)
* Group By Aggregates
* Window Functions
* Table Joins

*_Answers to Case Study Questions_* (note: you will find the queries & steps I used to find these answers in the CS1_Queries file)
1. What is the total amount each customer spent at the restaurant?
>* Customer A spent $76 | B: $74 | C: $36
2. How many days has each customer visited the restaurant?
>* Customer A has visited the restaurant on 4 different days | B: 6 days | C: 2 days.
3. What was the first item from the menu purchased by each customer?
>* Customer A orderd sushi, Customer B ordered curry, and Customer C ordered ramen as their first purchase.
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
>* Ramen was ordered 8 times
5. Which item was the most popular for each customer?
>* Customer A's most ordered dish is ramen. Customer B's is curry. Customer C's is ramen.
6. Which item was purchased first by the customer after they became a member?
>* Customer A ordered sushi first after becoming a member. Customer B ordered curry. Customer C has not become a member yet based on the data.
7. Which item was purchased just before the customer became a member?
>* Customer A had curry right before becoming a member. Customer B had sushi.
8. What is the total items and amount spent for each member before they became a member?
>* Customers A & B (C did not become a member) ordered 3 items and spent $40 before becoming a member.
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
>* Points by Customer: A = 86 | B = 94 | C = 36
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
>* Total points by customer: A = 137 | B = 94 | C = 36 (the big benefitor of the new rule/logic is customer A - means they ordered either the most within the week following their membership or the didn't always order sushi - customer B didn't benefit from new rule but ordered several times after becoming a member)


