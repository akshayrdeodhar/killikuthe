#!flask/usr/bin/python3
from flask import Flask, render_template, request, session, redirect
from modifications import *
from queries import *
from database import database
from config import *

app = Flask(__name__)
app.config.from_pyfile('config.py')
app.secret_key = b'_5#y2Laljd9797832/'
db = database(KILLIDBCONFIG)

@app.route('/', methods = ['GET'])
def main_screen():
    session.clear()
    return render_template("index.html")

@app.route('/register', methods = ['GET'])
def registration():
    return render_template("register.html")

@app.route('/keys', methods= ['POST'])
def signin_register():
    firstname = request.form.get('firstName')
    password = request.form.get('password')
    password2 = request.form.get('password1')
    lastname = request.form['lastName']
    mis = request.form['username']
    email = request.form['email'] 
    phoneno = request.form['phoneno']

    registered = registeruser(db, mis, firstname, lastname, phoneno, email, password, password2)

    errorlist = [(LARGENAME, "Name too large"), (MISERROR, "MIS Invalid"), (EMAIL, "Email Invalid"), (WRONGNO, "Phone number invalid"), (ALREADYREGISTERED, "Invalid Registration"), (PASSWORD, "Passowords Don't Match")]
    if registered != 0:
        for error in errorlist:
            if registered == error[0]:
                message = error[1]
                break
            
        if not message:
            message = "Please try again"

        return render_template("register.html", error = message)

    return render_template("index.html")

@app.route('/user', methods = ["GET", "POST"])
def userlogin():
    return render_template("userlogin.html")

@app.route('/user/mykeys', methods = ["POST", "GET"])
def userkeys():
    error = None
    if "inputusername" in request.form:
        if not user_login(db, request.form["inputusername"], request.form["password"]):
            return render_template("error.html", mainerror = "Sorry", suberror = "Unable to Log In")

        mis = request.form["inputusername"]

        session["mis"] = mis

    elif "register" in request.form:
        firstname = request.form.get('firstName')
        lastname = request.form['lastName']
        mis = request.form['username']
        email = request.form['email'] 
        phoneno = request.form['phoneno']
        password = request.form['password']
        password1 = request.form['password1']

        registered = registeruser(db, mis, firstname, lastname, phoneno, email, password, password1)

        errorlist = [(LARGENAME, "Name too large"), (MISERROR, "MIS Invalid"), (EMAIL, "Email Invalid"), (WRONGNO, "Phone number invalid"), (ALREADYREGISTERED, "Invalid Registration"), (PASSWORD, "Passwords do not match")]
        message = None
        if registered != 0:
            for error in errorlist:
                if registered == error[0]:
                    message = error[1]
                    break
            
            if not message:
                message = "Please try again"

            return render_template("register.html", error = message)

        session["mis"] = mis

    else:
        mis = session["mis"]
        if "where_to_keep" in request.form:
            # place key 
            key_place_pid, key_id = map(int, request.form["which_key"].split())
            store_place = int(request.form["where_to_keep"])
            retval = place_key(db, mis, key_place_pid, key_id, store_place)
            if retval != 0:
                error = "Cannot Keep Key There"

        elif "pickup_key" in request.form:

            key_place_pid, key_id = map(int, request.form["pickup_key"].split())
            retval = pickup_key(db, mis, key_place_pid, key_id)

            if retval != 0:
                error = "Cannot Pick Up That Key"

        elif "request_key" in request.form:

            key_place_pid, key_id = map(int, request.form["request_key"].split())
            retval = request_key(db, mis, key_place_pid, key_id)

            if retval != 0:
                error = "Cannot request that key"

        elif "transfer_key" in request.form:

            transfer_info = request.form["transfer_key"].split()
            key_place_pid, key_id= map(int, transfer_info[1:3])
            destination_mis = transfer_info[0]
            retval = transfer_key(db, destination_mis, key_place_pid, key_id)
            if retval != 0:
                error = "Cannot make that transfer"

    
    # show updated page / show page for the first time
    accessible_keys_stored = get_accessible_placed_keys(db, mis)
    accessible_keys_held_by_others = get_accessible_held_unrequested_keys(db, mis)
    keys_you_have = get_keys_held(db, mis)
    requested_keys = get_requested_keys(db, mis)
    keys_requested_from_me = get_key_requests_to_me(db, mis)

    # for each key, list of places where it can be kept
    keys_had_and_places = [(pid, kid, placename, valid_places_for_key(db, pid)) for placename, pid, kid in keys_you_have] 
            

    return render_template("keys.html", 
            stored = accessible_keys_stored, 
            others = accessible_keys_held_by_others, 
            held = keys_had_and_places, 
            error = error, 
            requested = requested_keys,
            requested_from_me = keys_requested_from_me)


@app.route('/user/myclubs', methods = ["GET"])
def showclubs():
    
    if "mis" not in session:
        return render_template("error.html", mainerror = "You may not access this URL", suberror = "Keep your prying hands to yourself")

    my_mis = session["mis"]
    clubs_I_manage = clubs_managed_by(db, my_mis)

    return render_template("manageclubs.html", clubs = clubs_I_manage, me = session["mis"])

@app.route('/user/managethisclub', methods = ["POST"])
def manageclub():
    if "mis" not in session or ("whichclub" not in request.form and ("removeuser" not in request.form and "add" not in request.form)):
        return render_template("error.html", mainerror = "You may not access this URL", suberror = "Keep your prying hands to yourself")

    my_mis = session["mis"]
    if "whichclub" in request.form:
        cid = int(request.form["whichclub"])
        session["whichclub"] = cid
    else:
        cid = session["whichclub"]

    error = None
    if "removeuser" in request.form:
        who_to_kick = request.form["removeuser"]
        retval = kickuser(db, my_mis, who_to_kick, cid)
        if retval != 0:
            error = "Cannot Kick That Person"
    elif "add" in request.form:
        who_to_add = request.form["who_to_add"]
        retval = addclubmember(db, cid, who_to_add)
        if retval != 0:
            error = "Cannot Add That Person"
    
    members = getmembersofclubimanage(db, cid, my_mis)

    return render_template("managethisclub.html", members = members, error = error, all_users = getallcandidates(db, cid), me = session["mis"])


@app.route('/user/mymembership', methods = ["GET", "POST"])
def myclubs():
    if "mis" not in session:
            return render_template("error.html", mainerror = "You may not access this URL", suberror = "Keep your prying hands to yourself")

    if request.method == "POST":
        if "makemanager" in request.form and "whichclub" in session:
            club_cid = int(session["whichclub"])
            new_manager = request.form["makemanager"]
            session.pop("whichclub")
            retval = changemanager(db, club_cid, new_manager)
            if retval != 0:
                session["whichclub"] = club_cid
        else:
            return render_template("error.html", mainerror = "You may not access this URL", suberror = "Keep your prying hands to yourself")

    mis = session["mis"]
    return render_template("myclubs.html", clubs = get_myclubs(db, mis), me = session["mis"])





@app.route('/admin', methods = ["GET"])
def adminjobs():
    return render_template("admin.html")


@app.route('/admin/places', methods = ["GET", "POST"])
def manageplaces():
    error = None
    if request.method == "POST":
        if "add" in request.form:
            placename = request.form['newplace']
            if "isstorage" in request.form:
                store = True
            else:
                store = False
            retval = registerplace(db, placename, store)
            if retval == ALREADYREGISTERED:
                error = "Duplicate Place"
            elif retval != 0:
                error = "Unable to register place " + placename
        elif "change_store" in request.form:
            which_place = int(request.form["change_store"])
            ret = change_storage(db, which_place)
        elif "close" in request.form:
            which_place = int(request.form["close"])
            ret = close_place_down(db, which_place)
            if ret != 0:
                pass


    place_data = getplaces(db)
    return render_template("places.html", places = place_data, error = error)


@app.route('/admin/placekeys', methods = ["GET", "POST"])
def managekeys():
    place_pid = None
    if "keys" in request.form:
        place_pid = int(request.form["keys"])
        session["place_pid"] = place_pid
    elif "add" in request.form and "place_pid" in session:
        # coming here with intention to add from same page
        key_id = int(request.form["add"])
        club_cid = int(request.form["which_club"])
        place_pid = session["place_pid"]
        retval = grantkeypermission(db, club_cid, place_pid, key_id)
        if retval != 0:
            pass
    elif "remove" in request.form and "place_pid" in session:
        key_id = int(request.form["remove"])
        club_cid = int(request.form["which_club"])
        place_pid = session["place_pid"]
        retval = removekeypermission(db, club_cid, place_pid, key_id)
        if retval != 0:
            pass
    elif "addkey" in request.form:
        place_pid = session["place_pid"]
        retval = addkey(db, place_pid)
        if retval != 0:
            pass

    placename = getplacename(db, place_pid)
    keysinfo = getkeysinfo(db, place_pid)
    return render_template("placekeys.html", keys = keysinfo, placename = placename)


@app.route('/admin/clubs', methods = ["GET", "POST"])
def manageclubs():
    error = None
    if request.method == "POST":
        if "add" in request.form:
            placename = request.form['newclub']
            manager = request.form['manager']
            retval = registerclub(db, placename, manager)
            if retval == ALREADYREGISTERED:
                error = "Duplicate Place"
            elif retval == INVALIDMANAGER:
                error = "Manager chosen invalid"
            elif retval != 0:
                error = "Unable to register club" + placename

        elif "remove" in request.form:
            who_to_remove = int(request.form["remove"])
            retval = removeclub(db, who_to_remove)
            if retval != 0:
                pass

    people_list = getpeople(db)
    club_data = getclubs(db)
    return render_template("clubs.html", clubs =  club_data, people = people_list, error = error)



if __name__ == "__main__":
    app.run(host="0.0.0.0", port = 8000)
