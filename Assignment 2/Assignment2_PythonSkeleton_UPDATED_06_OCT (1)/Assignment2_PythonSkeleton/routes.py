# Importing the frameworks
from flask import *
from datetime import datetime
import database

user_details = {}
session = {}
page = {}
# Initialise the application
app = Flask(__name__)
app.secret_key = 'aab12124d346928d14710610f'

#####################################################
##  INDEX
#####################################################

@app.route('/')
def index():
    # Check if the user is logged in
    if('logged_in' not in session or not session['logged_in']):
        return redirect(url_for('login'))
    page['title'] = 'Sydney Music'
    return redirect(url_for('list_tracks'))

    #return render_template('index.html', session=session, page=page, user=user_details)

#####################################################
##  LOGIN
#####################################################

@app.route('/login', methods=['POST', 'GET'])
def login():
    # Check if they are submitting details, or they are just logging in
    if (request.method == 'POST'):
        # submitting details
        login_return_data = check_login(request.form['id'], request.form['password'])

        # If they have incorrect details
        if login_return_data is None:
            page['bar'] = False
            flash("Incorrect login info, please try again.")
            return redirect(url_for('login'))

        # Log them in
        page['bar'] = True
        welcomestr = 'Welcome back, ' + login_return_data['firstName'] + ' ' + login_return_data['lastName']
        flash(welcomestr)
        session['logged_in'] = True

        # Store the user details
        global user_details
        user_details = login_return_data

        session['isstaff'] = True if login_return_data['role'] == 'Staff' else False
        session['iscustomer'] = True if login_return_data['role'] == 'Customer' else False
        session['user'] = login_return_data['login']
        return redirect(url_for('index'))

    elif (request.method == 'GET'):
        return(render_template('login.html', page=page))

def check_login(login, password):
    userInfo = database.checkLogin(login, password)

    if userInfo is None:
        return None
    else:
        tuples = {
            'login': userInfo[0],
            'firstName': userInfo[1],
            'lastName': userInfo[2],
            'role': userInfo[3]
        }
        return tuples

#####################################################
##  LOGOUT
#####################################################

@app.route('/logout')
def logout():
    session['logged_in'] = False
    page['bar'] = True
    flash('You have been logged out. See you soon!')
    return redirect(url_for('index'))

#####################################################
##  List Tracks
#####################################################

@app.route('/tracks', methods=['POST', 'GET'])
def list_tracks():
    # Check if user is logged in
    if ('logged_in' not in session or not session['logged_in']):
        return redirect(url_for('login'))

    # User is just viewing the page
    if (request.method == 'GET'):
        track_list = database.list_tracks()
        if (track_list is None):
            track_list = []
            flash("There are no tracks in the system")
            page['bar'] = False
        return render_template('list_tracks.html', track_list=track_list, session=session, page=page)

    # Otherwise try to get from the database
    elif (request.method == 'POST'):
        search_term = request.form['search']
        
        track_list = database.find_tracks(search_term)
        if (track_list is None):
            track_list = []
            flash("Searching \'{}\' does not return any result".format(request.form['search']))
            page['bar'] = False
        return render_template('list_tracks.html', track_list=track_list, session=session, page=page)

#####################################################
##  List Users
#####################################################
@app.route('/users', methods=['POST', 'GET'])
def list_users():
    # Check if user is logged in
    if ('logged_in' not in session or not session['logged_in']):
        return redirect(url_for('login'))

    # User is just viewing the page
    if (request.method == 'GET'):
        # Get all users from database
        users = database.list_users()
        if (users is None):
            users = []
            flash("There are no users in the system")
            page['bar'] = False
        return render_template('list_users.html', user_list=users, session=session, page=page)

#####################################################
##  Add User
#####################################################
@app.route('/users/add' , methods=['GET', 'POST'])
def add_user():
    print("add_user")
    # Check if the user is logged in
    if ('logged_in' not in session or not session['logged_in']):
        return redirect(url_for('login'))

    # If we're just looking at the 'add user' page
    if(request.method == 'GET'):
        times = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
        return render_template('add_user.html', user=user_details, times=times, session=session, page=page)

	# If we're adding a new user
    success = database.add_user(validate_form_data(request.form['login']),
                                validate_form_data(request.form['firstname']),
                                validate_form_data(request.form['lastname']),
                                validate_form_data(request.form['password']),
                                validate_form_data(request.form['email']),
                                request.form['role'])
    if(success == True):
        page['bar'] = True
        flash("New user added successfully!")
        return(redirect(url_for('list_users')))
    else:
        page['bar'] = False
        flash("There was an error adding a new user.")
        return(redirect(url_for('add_user')))
    
#####################################################
##  List Reviews
#####################################################
@app.route('/reviews', methods=['POST', 'GET'])
def list_reviews():
    # Check if user is logged in
    if ('logged_in' not in session or not session['logged_in']):
        return redirect(url_for('login'))

    # User is just viewing the page
    if (request.method == 'GET'):
        # Get all reviews from database
        reviews = database.list_reviews()
        if (reviews is None):
            reviews = []
            flash("There are no reviews in the system")
            page['bar'] = False
        return render_template('list_reviews.html', review_list=reviews, session=session, page=page)

#####################################################
## ADD Reviews
#####################################################
@app.route('/reviews/add' , methods=['GET', 'POST'])
def add_review():
    print("add_review")
    # Check if the user is logged in
    if ('logged_in' not in session or not session['logged_in']):
        return redirect(url_for('login'))

    # If we're just looking at the 'add review' page
    if(request.method == 'GET'):
        times = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
        return render_template('add_review.html', user=user_details, times=times, session=session, page=page)

	# If we're adding a new review
    success = database.add_review(request.form['trackid'],
                                request.form['rating'],
                                user_details['login'],
                                validate_form_data(request.form['content']),
                                validate_form_data(request.form['review_date']))
    if(success == True):
        page['bar'] = True
        flash("New review added successfully!")
        return(redirect(url_for('list_reviews')))
    else:
        page['bar'] = False
        flash("There was an error adding a new review.")
        return(redirect(url_for('add_review')))
    
#####################################################
## Update Reviews
#####################################################
@app.route('/reviews/update', methods=['GET', 'POST'])
def update_review():
    print("update_review")
    # Check if the user is logged in
    if ('logged_in' not in session or not session['logged_in']):
        return redirect(url_for('login'))

    if (request.method == 'POST'):

        update = {
            'reviewid': request.form.get('reviewid'),
            'rating': request.form.get('rating'),
            'content': validate_form_data(request.form.get('content'))
        }

        success = database.update_review(update['reviewid'], update['rating'], update['content'])

        if (success == True):
            page['bar'] = True
            flash("Review updated successfully!")
            return(redirect(url_for('list_reviews')))
        else:
            page['bar'] = False
            flash("There was an error updating the review.")
            return(redirect(url_for('list_reviews')))
    else:
        return(redirect(url_for('list_reviews')))

#####################################################
## Update Users
#####################################################
@app.route('/users/update', methods=['GET', 'POST'])
def update_user():
    # Check if the user is logged in
    if ('logged_in' not in session or not session['logged_in']):
        return redirect(url_for('login'))

    if (request.method == 'POST'):

        update = {
            'user':validate_form_data(request.form.get('id')),
            'firstname': validate_form_data(request.form.get('firstname')),
            'lastname': validate_form_data(request.form.get('lastname')),
            'email': validate_form_data(request.form.get('email'))
        }

        success = database.update_user(update['user'], update['firstname'], update['lastname'], update['email'])

        if (success == True):
            page['bar'] = True
            flash("User updated successfully!")
            return(redirect(url_for('list_users')))
        else:
            page['bar'] = False
            flash("There was an error updating the user.")
            return(redirect(url_for('list_users')))
    else:
        return(redirect(url_for('list_users')))

#####################################################
## Update Tracks
#####################################################
@app.route('/tracks/update', methods=['GET', 'POST'])
def update_track():
    # Check if the user is logged in
    if ('logged_in' not in session or not session['logged_in']):
        return redirect(url_for('login'))

    if (request.method == 'POST'):
        print(request.form.get('composer'))
        print(request.form.get('composer') == '')
        update = {
            'trackid':request.form.get('trackid'),
            'title': validate_form_data(request.form.get('title')),
            'duration':request.form.get('duration'),
            'age_restriction': request.form.get('age_restriction'),
            'singer_login': validate_form_data(request.form.get('singer')),
            'composer_login': validate_form_data(request.form.get('composer')),
        }

        success = database.update_track(update['trackid'], update['title'], update['duration'], 
                                    update['age_restriction'], update['singer_login'], update['composer_login'])

        if (success == True):
            page['bar'] = True
            flash("Track updated successfully!")
            return(redirect(url_for('list_tracks')))
        else:
            page['bar'] = False
            flash("There was an error updating the track.")
            return(redirect(url_for('list_tracks')))
    else:
        return(redirect(url_for('list_tracks')))

def validate_form_data(data):  
    if isinstance(data, str) and data.strip() == '':
            return None
    return data
    