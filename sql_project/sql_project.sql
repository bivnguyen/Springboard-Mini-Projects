/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:



The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT 	facilities.name
FROM 	country_club.Facilities facilities
WHERE 	membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT 	COUNT(facilities.name) as Free_Facilities
FROM 	country_club.Facilities facilities
WHERE 	membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 	facilities.facid,
	facilities.name,
	facilities.membercost,
	facilities.monthlymaintenance
FROM 	country_club.Facilities facilities
WHERE 	facilities.membercost > 0 AND facilities.membercost < (facilities.monthlymaintenance * .2)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT 	*
FROM 	country_club.Facilities facilities
WHERE facid IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT 	facilities.name,
	facilities.monthlymaintenance,
	CASE WHEN facilities.monthlymaintenance <= 100 THEN 'cheap'
	ELSE 'expensive' END as label
FROM 	country_club.Facilities facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT 	members.firstname,
	members.surname,
	members.joindate
FROM 	country_club.Members as members
ORDER BY members.joindate DESC

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT 	DISTINCT CONCAT(CONCAT(members.firstname, ' '), members.surname) as member_name,
	facilities.name as facility_name
FROM 	country_club.Members as members
INNER JOIN country_club.Bookings as bookings
ON 	members.memid = bookings.memid
LEFT JOIN country_club.Facilities as facilities
ON 	bookings.facid = facilities.facid
WHERE 	facilities.name LIKE 'Tennis%'
ORDER BY member_name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT 	facilities.name as facility_name,
	CONCAT(CONCAT(members.firstname, ' '), members.surname) as member_name,
	CASE WHEN members.memid = 0 THEN facilities.guestcost * bookings.slots
	     WHEN members.memid != 0 THEN facilities.membercost * bookings.slots
	     END as cost
FROM 	country_club.Members members
INNER JOIN country_club.Bookings bookings
ON 	members.memid = bookings.memid
LEFT JOIN country_club.Facilities facilities
ON 	bookings.facid = facilities.facid
WHERE 	(bookings.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59')
AND	((members.memid = 0 AND (facilities.guestcost * bookings.slots) > 30) OR
         (members.memid != 0 AND (facilities.membercost * bookings.slots) > 30))
ORDER BY cost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub.*
FROM (
	SELECT facilities.name AS facility_name, CONCAT( CONCAT( members.firstname, ' ' ) , members.surname ) AS member_name,
	CASE WHEN members.memid =0 THEN facilities.guestcost * bookings.slots
	     WHEN members.memid !=0 THEN facilities.membercost * bookings.slots
	     END AS cost
	FROM country_club.Members members
	INNER JOIN country_club.Bookings bookings ON members.memid = bookings.memid
	LEFT JOIN country_club.Facilities facilities ON bookings.facid = facilities.facid
	WHERE (bookings.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59')
	ORDER BY cost DESC
)sub
WHERE sub.cost >30

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT 	sub.facility_name,
	SUM(sub.cost) AS total_revenue
FROM (
	SELECT 	facilities.name as facility_name,
		CONCAT(CONCAT(members.firstname, ' '), members.surname) AS member_name,
		CASE WHEN members.memid = 0 THEN facilities.guestcost * bookings.slots
		     WHEN members.memid != 0 THEN facilities.membercost * bookings.slots
		     END AS cost
	FROM 	country_club.Members members
	INNER JOIN country_club.Bookings bookings
	ON 	members.memid = bookings.memid
	LEFT JOIN country_club.Facilities facilities
	ON 	bookings.facid = facilities.facid
	ORDER BY cost DESC
    ) sub
GROUP BY sub.facility_name
HAVING total_revenue < 1000
ORDER BY total_revenue DESC
