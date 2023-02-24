import 'package:attendance_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class jadwalScreen extends StatefulWidget {
  const jadwalScreen({super.key});

  @override
  State<jadwalScreen> createState() => _jadwalScreenState();
}

class _jadwalScreenState extends State<jadwalScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = Color.fromARGB(255, 9, 135, 91);

  String _month = DateFormat('MMMM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 32),
              child: Text(
                "My Attendance",
                style: TextStyle(
                  fontFamily: "Bold",
                  fontSize: screenWidth / 20,
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 32),
                  child: Text(
                    _month,
                    style: TextStyle(
                      fontFamily: "Bold",
                      fontSize: screenWidth / 20,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(top: 32),
                  child: GestureDetector(
                    onTap: () async {
                      final month = await showMonthYearPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2099),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: primary,
                                  secondary: primary,
                                  onSecondary: Colors.white,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    primary: primary,
                                  ),
                                ),
                                textTheme: const TextTheme(
                                  headline4: TextStyle(
                                    fontFamily: "Bold",
                                  ),
                                  overline: TextStyle(
                                    fontFamily: "Bold",
                                  ),
                                  button: TextStyle(
                                    fontFamily: "Bold",
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          });

                      if (month != null) {
                        setState(() {
                          _month = DateFormat('MMMM').format(month);
                        });
                      }
                    },
                    child: Text(
                      "Pick a Month",
                      style: TextStyle(
                        fontFamily: "Bold",
                        fontSize: screenWidth / 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight / 1.45,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Employee")
                    .doc(User.id)
                    .collection("Record")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final snaps = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: snaps.length,
                      itemBuilder: (context, Index) {
                        return DateFormat('MMMM')
                                    .format(snaps[Index]['date'].toDate()) ==
                                _month
                            ? Container(
                                margin: EdgeInsets.only(
                                    top: Index > 0 ? 12 : 0, left: 6, right: 6),
                                height: 150,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(),
                                        decoration: BoxDecoration(
                                          color: primary,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            DateFormat('EE\n dd').format(
                                                snaps[Index]['date'].toDate()),
                                            style: TextStyle(
                                              fontFamily: "Bold",
                                              fontSize: screenWidth / 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Jam Masuk",
                                            style: TextStyle(
                                              fontFamily: "Regular",
                                              fontSize: screenWidth / 25,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            snaps[Index]['checkIn'],
                                            style: TextStyle(
                                              fontFamily: "Bold",
                                              fontSize: screenWidth / 15,
                                              color:
                                                  Color.fromARGB(178, 0, 0, 0),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Jam Keluar",
                                            style: TextStyle(
                                              fontFamily: "Regular",
                                              fontSize: screenWidth / 25,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            snaps[Index]['checkOut'],
                                            style: TextStyle(
                                              fontFamily: "Bold",
                                              fontSize: screenWidth / 15,
                                              color:
                                                  Color.fromARGB(178, 0, 0, 0),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox();
                      },
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
