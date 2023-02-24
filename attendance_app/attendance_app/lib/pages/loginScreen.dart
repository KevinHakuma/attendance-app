import 'package:attendance_app/pages/regisScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reusable_widget/reusable_widget.dart';
import 'homeScreen.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = Color.fromARGB(255, 9, 135, 91);

  late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: screenHeight / 3,
            width: screenWidth,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(70),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.groups_sharp,
                color: Colors.white,
                size: screenWidth / 5,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: screenHeight / 16,
              bottom: screenHeight / 20,
            ),
            child: Text(
              "Login",
              style: TextStyle(
                fontSize: screenWidth / 18,
                fontFamily: "Bold",
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(
              horizontal: screenWidth / 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fieldTitle("Employee Id"),
                customField("Enter your employee id", emailController, false),
                fieldTitle("Password"),
                customField("Enter your password", passController, true),
                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    String email = emailController.text.trim();
                    String password = passController.text.trim();

                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Email is still empty!"),
                        ),
                      );
                    } else if (password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Password is still empty!"),
                        ),
                      );
                    } else {
                      QuerySnapshot snaps = await FirebaseFirestore.instance
                          .collection("Employee")
                          .where('email', isEqualTo: email)
                          .get();

                      try {
                        if (password == snaps.docs[0]['password']) {
                          sharedPreferences =
                              await SharedPreferences.getInstance();

                          sharedPreferences
                              .setString('employeeId', email)
                              .then((_) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => homeScreen()),
                            );
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Password is not correct!"),
                            ),
                          );
                        }
                      } catch (e) {
                        String error = " ";
                        // print(e.toString());
                        if (e.toString() ==
                            "RangeError (index): Invalid value: Valid value range is empty: 0") {
                          setState(() {
                            error = "Employee Id does not exist!";
                          });
                        } else {
                          setState(() {
                            error = "error occurred!";
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    height: 60,
                    width: screenWidth,
                    margin: EdgeInsets.only(top: screenHeight / 45),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.all(
                        Radius.circular(35),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "LOGIN",
                        style: TextStyle(
                          fontFamily: "Bold",
                          fontSize: screenWidth / 26,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                // signInSignUpButton(context, true, () async {
                // FirebaseAuth.instance
                //     .signInWithEmailAndPassword(
                //         email: emailController.text,
                //         password: passController.text)
                //     .then((value) {
                //   Navigator.push(context,
                //       MaterialPageRoute(builder: (context) => homeScreen()));
                // });
                // sharedPreferences = await SharedPreferences.getInstance();

                // sharedPreferences.setString('employeeId', email);

                // }),
                // Container(
                //   height: 60,
                //   width: screenWidth,
                //   margin: EdgeInsets.only(top: screenHeight / 45),
                //   decoration: BoxDecoration(
                //     color: primary,
                //     borderRadius: BorderRadius.all(
                //       Radius.circular(35),
                //     ),
                //   ),
                //   child: Center(
                //     child: Text(
                //       "LOGIN",
                //       style: TextStyle(
                //         fontFamily: "Bold",
                //         fontSize: screenWidth / 26,
                //         color: Colors.white,
                //         letterSpacing: 2,
                //       ),
                //     ),
                //   ),
                // ),
                signUpOption(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget fieldTitle(String title) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth / 26,
          fontFamily: "Bold",
        ),
      ),
    );
  }

  Widget customField(
      String hint, TextEditingController controller, bool obsecure) {
    return Container(
      width: screenWidth,
      margin: EdgeInsets.only(bottom: screenHeight / 70),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth / 6,
            child: Icon(
              Icons.mail,
              color: primary,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 12),
              child: TextFormField(
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight / 50,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                ),
                maxLines: 1,
                obscureText: obsecure,
              ),
            ),
          )
        ],
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 18),
          child: const Text(
            "Belum Punya Akun ?",
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Bold",
              fontSize: 17,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => regisScreen()));
          },
          child: Padding(
            padding: EdgeInsets.only(top: 18),
            child: const Text(
              " Daftar Disini",
              style: TextStyle(
                color: Color.fromARGB(255, 9, 135, 91),
                fontFamily: "Bold",
                fontSize: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
