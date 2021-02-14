import 'package:expenses/model/user.dart';
import 'package:expenses/main.dart';

import 'package:expenses/services/auth.dart';
import 'package:expenses/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();

}

class _RegisterState extends State<Register> {


  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  final formkey = GlobalKey<FormState>();
  TextEditingController mUserName = new TextEditingController();
  TextEditingController mEmail = new TextEditingController();
  TextEditingController mPassword = new TextEditingController();

  createAcc(){
    if (formkey.currentState.validate()){
      //print ("validate liao " + mEmail.text + " " + mPassword.text );
      authMethods.signUpWithEmailAndPassword (mEmail.text, mPassword.text).then((val){
        //print("authmetood ok ");

        FirebaseAuth.instance.currentUser().then((user) {

          //print("created ");

          if (user != null) {
            Map<String, String> userMap = {
              "userId" : user.uid,
              "name" : mUserName.text,
              "email": mEmail.text,
              "image" : "",
              "status" : "I am here"
            };
            databaseMethods.writeUserToDatabase(userMap); // write to Users list, for admin purpose only

            final userData = User(
              userId: user.uid,
              userEmail: mEmail.text,
              userName: mUserName.text,
            );
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ExpensesMain()));

          }else{
            Toast.show("User might have existed", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);}
        });

        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

  login(){
    //print ("login liao");
    //Toast.show("Login here", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
    if (formkey.currentState.validate()){
      //print ("validae liao  " + mEmail.text);
      authMethods.signInWithEmailAndPassword (mEmail.text, mPassword.text).then((val){
//print("object");
        FirebaseAuth.instance.currentUser().then((user) {
          if (user != null) {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ExpensesMain()));}else{
            Toast.show("Login failed", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);}
        });


      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return new WillPopScope(
      onWillPop: () async => false,//to prevent back button clicking
      child: Scaffold(

        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Register',
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 1,
              color: Colors.white,

            ),
          ),
        ),

        body: Container(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Form(
            key: formkey,
            child: Column(
              children: [
                TextFormField (
                  validator: (val){ return
                    val.isEmpty || val.length <3 ? "User name is not valid" : null;},
                  controller: mUserName,
                  decoration: InputDecoration(hintText: "User Name"),
                ),
                TextField (
                  controller: mEmail,
                  decoration: InputDecoration(hintText: "email"),
                ),
                TextFormField (
                  obscureText: true,
                  validator: (val) { return
                    val.length <6 ? "Password must be more than 6 characters" : null;},
                  controller: mPassword,
                  decoration: InputDecoration(hintText: "password"),
                ),
                SizedBox (height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {login();},
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),

                    ),
                    FlatButton(
                      onPressed: () {createAcc();},
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Text(
                        "CreateAcc",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }




}