#!/usr/bin/env python3
import psycopg2

#####################################################
##  Database Connection
#####################################################

def openConnection():
    # connection parameters - ENTER YOUR LOGIN AND PASSWORD HERE
    userid = "y25s2c9120_froz0299"
    passwd = "abcRozin123"
    myHost = "awsprddbs4836.shared.sydney.edu.au"

    # Create a connection to the database
    conn = None
    try:
        # Parses the config file and connects using the connect string
        conn = psycopg2.connect(database=userid,
                                    user=userid,
                                    password=passwd,
                                    host=myHost)
        return conn

    except psycopg2.Error as sqle:
        print("psycopg2.Error : " + sqle.pgerror)
    
    # return the connection to use
    
'''
Validate user login credentials against the database
Login comparison is case insensitive, password comparison is case sensitive
Parameters:
    login: login ID
    password: User password
Returns:
    [login, firstName, lastName, role] if valid, None if invalid
'''
def checkLogin(login, password):
    try:
        # Open database connection and cursor
        db_conn = openConnection()
        db_curs = db_conn.cursor()

        # Query for check login
        query_check_login = """
            SELECT 
                acc.login AS "login", 
                acc.firstname AS "firstName", 
                acc.lastname AS "lastName", 
                acc.role AS "role"
            FROM 
                account AS acc
            WHERE 
                LOWER(acc.login) = LOWER(%s) 
                AND acc.password = %s
        """

        # Execute the query_check_login and store to query_result
        db_curs.execute(query_check_login, (login,  password))
        query_result = db_curs.fetchone() # Since acc.login is unique

        # Checking query_result validity
        if query_result:
            result = [query_result[0], query_result[1], query_result[2], query_result[3]]
            return result
        else:
            return None

    except psycopg2.Error as e:
        # Print error message
        print("Error: ", e.pgerror)
        return None
    
    finally:
        # Close database cursor and connection
        if db_curs:
            db_curs.close()
        if db_conn:
            db_conn.close()

"""
Retrieve all tracks from the database with associated artist information and average ratings
Returns:
    List of dictionaries containing track information:
        - trackid: Track ID
        - title: Track title
        - duration: Track duration
        - age_restriction: Boolean indicating if track has age restrictions
        - singer_name: Full name of the singer
        - composer_name: Full name of the composer
        - avg_rating: Average rating from all reviews (0 if no reviews)
"""
def list_tracks(): 
    try:
        # Open database connection and cursor
        db_conn = openConnection()
        db_curs = db_conn.cursor()

        # Query for list tracks
        query_list_tracks = """
            SELECT 
                tra.id AS "trackid", 
                tra.title AS "title", 
                tra.duration AS "duration", 
                tra.age_restriction AS "age_restriction", 
                CONCAT(acc_sin.firstname, ' ', acc_sin.lastname) AS "singer_name", 
                CONCAT(acc_com.firstname, ' ', acc_com.lastname) AS "composer_name", 
                COALESCE(ROUND(AVG(rev.rating), 2), 0) AS "avg_rating"
            FROM 
                track AS tra
            LEFT JOIN 
                artist AS art_sin ON tra.singer = art_sin.login
            LEFT JOIN 
                account AS acc_sin ON art_sin.login = acc_sin.login
            LEFT JOIN 
                artist AS art_com ON tra.composer = art_com.login
            LEFT JOIN 
                account AS acc_com ON art_sin.login = acc_com.login
            LEFT JOIN 
                review AS rev ON tra.id = rev.trackid
            GROUP BY 
                tra.id, 
                tra.title, 
                tra.duration, 
                tra.age_restriction, 
                acc_sin.firstname, 
                acc_sin.lastname, 
                acc_com.firstname, 
                acc_com.lastname
            ORDER BY 
                tra.id ASC
        """

        # Execute the query_list_tracks and store to query_result
        db_curs.execute(query_list_tracks)
        query_result = db_curs.fetchall()

        # Checking query_result validity
        if query_result:
            result = []
            for record in query_result:
                record_dictionary = {
                    "trackid": record[0],
                    "title": record[1],
                    "duration": record[2],
                    "age_restriction": record[3],
                    "singer_name": record[4],
                    "composer_name": record[5],
                    "avg_rating": record[6]
                }
                result.append(record_dictionary)
            return result
        else:
            return None

    except psycopg2.Error as e:
        # Print error message
        print("Error: ", e.pgerror)
        return None

    finally:
        # Close database cursor and connection
        if db_curs:
            db_curs.close()
        if db_conn:
            db_conn.close()

"""
Retrieve all users from the database
Returns:
    List of dictionaries containing user information:
        - login: User login ID
        - firstname: User's first name
        - lastname: User's last name
        - email: User's email address
        - role: User's role (Customer, Artist, Staff)
"""
def list_users(): 
    try:
        # Open database connection and cursor
        db_conn = openConnection()
        db_curs = db_conn.cursor()

        # Query for list users
        query_list_users = """
            SELECT 
                acc.login AS "login", 
                acc.firstname AS "firstname", 
                acc.lastname AS "lastname", 
                acc.email AS "email", 
                acc.role AS "role"
            FROM 
                account AS acc
            ORDER BY 
                acc.role ASC,
                acc.login ASC
        """

        # Execute the query_list_users and store to query_result
        db_curs.execute(query_list_users)
        query_result = db_curs.fetchall()

        # Checking query_result validity
        if query_result:
            result = []
            for record in query_result:
                record_dictionary = {
                    "login": record[0],
                    "firstname": record[1],
                    "lastname": record[2],
                    "email": record[3],
                    "role": record[4]
                }
                result.append(record_dictionary)
            return result
        else:
            return None

    except psycopg2.Error as e:
        # Print error message
        print("Error: ", e.pgerror)
        return None

    finally:
        # Close database cursor and connection
        if db_curs:
            db_curs.close()
        if db_conn:
            db_conn.close()

"""
Retrieve all reviews from the database with associated track and customer information
Returns:
    List of dictionaries containing review information:
        - reviewid: Review ID
        - track_title: Title of the reviewed track
        - rating: Review rating (1-5)
        - content: Review content text
        - customer_login: Login ID of the reviewer
        - customer_name: Full name of the reviewer
        - review_date: Date when the review was written
"""
def list_reviews(): 
    try:
        # Open database connection and cursor
        db_conn = openConnection()
        db_curs = db_conn.cursor()

        # Query for list reviews
        query_list_reviews = """
            SELECT 
                rev.reviewid AS "reviewid", 
                tra.title AS "track_title", 
                rev.rating AS "rating", 
                rev.content AS "content", 
                rev.customerid AS "customer_login", 
                CONCAT(acc.firstname, ' ', acc.lastname) AS "customer_name", 
                rev.reviewdate AS "review_date"
            FROM 
                review AS rev
            LEFT JOIN 
                track AS tra ON rev.trackid = tra.id
            LEFT JOIN 
                account AS acc ON rev.customerid = acc.login
            ORDER BY 
                rev.reviewdate DESC,
                rev.reviewid ASC
        """

        # Execute the query_list_reviews and store to query_result
        db_curs.execute(query_list_reviews)
        query_result = db_curs.fetchall()

        # Checking query_result validity
        if query_result:
            result = []
            for record in query_result:
                record_dictionary = {
                    "reviewid": record[0],
                    "track_title": record[1],
                    "rating": record[2],
                    "content": record[3],
                    "customer_login": record[4],
                    "customer_name": record[5],
                    "review_date": record[6]
                }
                result.append(record_dictionary)
            return result
        else:
            return None

    except psycopg2.Error as e:
        # Print error message
        print("Error: ", e.pgerror)
        return None

    finally:
        # Close database cursor and connection
        if db_curs:
            db_curs.close()
        if db_conn:
            db_conn.close()

"""
Search for tracks based on a search string
Parameters:
    searchString: Search term to find matching tracks
Returns:
    List of dictionaries containing matching track information:
        - trackid: Track ID
        - title: Track title
        - duration: Track duration
        - age_restriction: Boolean indicating if track has age restrictions
        - singer_name: Full name of the singer
        - composer_name: Full name of the composer
        - avg_rating: Average rating from all reviews (0 if no reviews)
"""
def find_tracks(searchString):
    
    return None

"""
Add a new user to the database
Parameters:
    login: User's login ID
    firstname: User's first name
    lastname: User's last name
    password: User's password
    email: User's email address (can be empty)
    role: User's role (Customer, Artist, Staff)
Returns:
    True if user added successfully, False if error occurred
"""
def add_user(login, firstname, lastname, password, email, role):

    return True

"""
Add a new review to the database
Parameters:
    trackid: ID of the track being reviewed
    rating: Review rating (1-5)
    customer_login: Login ID of the customer writing the review
    content: Review content text (can be null)
    review_date: Date when the review was written
Returns:
    True if review added successfully, False if error occurred
"""
def add_review(trackid, rating, customer_login, content, review_date):
   
    return True

"""
Update an existing track in the database
Parameters:
    trackid: ID of the track to update
    title: Updated track title
    duration: Updated track duration
    age_restriction: Updated age restriction setting
    singer_login: Updated singer's login ID (must exist as Artist, case insensitive)
    composer_login: Updated composer's login ID (must exist as Artist, case insensitive)
Returns:
    True if track updated successfully, False if error occurred
"""
def update_track(trackid, title, duration, age_restriction, singer_login, composer_login):

    return True

"""
Update an existing review in the database
If update is successful, the review date will be updated to the current date
Parameters:
    reviewid: ID of the review to update
    rating: Updated review rating (1-5)
    content: Updated review content text (can be null)
Returns:
    True if review updated successfully, False if error occurred
"""
def update_review(reviewid, rating, content):

    return True

"""
Update an existing user in the database
Parameters:
    user_login: Login ID of the user to update
    firstname: Updated user's first name
    lastname: Updated user's last name
    email: Updated user's email address (can be null)
Returns:
    True if user updated successfully, False if error occurred
"""
def update_user(user_login, firstname, lastname ,email ):

    return True

