import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../reusable_widget/reusable_widget.dart';
import 'loginScreen.dart';

class regisScreen extends StatefulWidget {
  const regisScreen({Key? key}) : super(key: key);

  @override
  State<regisScreen> createState() => _regisScreenState();
}

class _regisScreenState extends State<regisScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = Color.fromARGB(255, 9, 135, 91);

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference employee = firestore.collection('Employee');

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Container(
          //   height: screenHeight / 3,
          //   width: screenWidth,
          //   decoration: BoxDecoration(
          //     color: primary,
          //     borderRadius: BorderRadius.only(
          //       bottomRight: Radius.circular(70),
          //     ),
          //   ),
          //   child: Center(
          //     child: Icon(
          //       Icons.groups_sharp,
          //       color: Colors.white,
          //       size: screenWidth / 5,
          //     ),
          //   ),
          // ),
          Container(
            margin: EdgeInsets.only(
              top: screenHeight / 17,
              bottom: screenHeight / 20,
            ),
            child: Text(
              "Register",
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
                fieldTitle("Name"),
                customField("Enter your name", namaController, false),
                fieldTitle("NIK"),
                customField("Enter your NIK", idController, false),
                fieldTitle("Employee Id"),
                customField("Enter your Employee Id", emailController, false),
                fieldTitle("Password"),
                customField("Enter your password", passController, true),

                signInSignUpButton(context, false, () {
                  // FirebaseAuth.instance
                  //     .createUserWithEmailAndPassword(
                  //   email: emailController.text,
                  //   password: passController.text,
                  // )
                  //     .then((value) {
                  //   print("akun berhasil dibuat");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const loginScreen(),
                      ));
                  // }).onError((error, stackTrace) {
                  //   print("error ${error.toString()}");
                  // });
                  employee.add({
                    'email': emailController.text,
                    'password': passController.text,
                    'nama': namaController.text,
                    'nik': int.tryParse(idController.text) ?? 0
                  });
                  emailController.text = '';
                  passController.text = '';
                  namaController.text = '';
                  idController.text = '';
                }),
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
                //       "REGISTER",
                //       style: TextStyle(
                //         fontFamily: "Bold",
                //         fontSize: screenWidth / 18,
                //         color: Colors.white,
                //         letterSpacing: 2,
                //       ),
                //     ),
                //   ),
                // ),
                signInOption(),
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

  Row signInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 18),
          child: const Text(
            "Sudah Punya Akun ?",
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
                MaterialPageRoute(builder: (context) => loginScreen()));
          },
          child: Padding(
            padding: EdgeInsets.only(top: 18),
            child: const Text(
              " Login Disini",
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
