import 'dart:async';

import 'package:attendance_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shared_preferences/shared_preferences.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  double screenHeight = 0;
  double screenWidth = 0;

  String checkIn = "--:--";
  String checkOut = "--:--";
  String location = " ";
  String scanResult = " ";
  String officeCode = " ";

  Color primary = const Color.fromARGB(255, 9, 135, 91);

  @override
  void initState() {
    super.initState();
    _getRecord();
    _getOfficeCode();
  }

  void _getOfficeCode() async {
    DocumentSnapshot snaps = await FirebaseFirestore.instance
        .collection("Attributes")
        .doc("office1")
        .get();

    setState(() {
      officeCode = snaps['code'];
    });
  }

  Future<void> scanQRandCheck() async {
    String result = " ";
    try {
      result = await FlutterBarcodeScanner.scanBarcode(
        "#ffffff",
        "Cancel",
        false,
        ScanMode.QR,
      );
    } catch (e) {
      print("error");
    }

    setState(() {
      scanResult = result;
    });

    if (scanResult == officeCode) {
      if (User.lat != 0) {
        _getLocation();

        QuerySnapshot snaps = await FirebaseFirestore.instance
            .collection("Employee")
            .where('email', isEqualTo: User.employeeId)
            .get();

        DocumentSnapshot snaps2 = await FirebaseFirestore.instance
            .collection("Employee")
            .doc(snaps.docs[0].id)
            .collection("Record")
            .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
            .get();

        try {
          String checkIn = snaps2['checkIn'];

          setState(() {
            checkOut = DateFormat('kk:mm').format(DateTime.now());
          });

          await FirebaseFirestore.instance
              .collection("Employee")
              .doc(snaps.docs[0].id)
              .collection("Record")
              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
              .update({
            'date': Timestamp.now(),
            'checkIn': checkIn,
            'checkOut': DateFormat('kk:mm').format(DateTime.now()),
            'location': location,
          });
        } catch (e) {
          setState(() {
            checkIn = DateFormat('kk:mm').format(DateTime.now());
          });
          await FirebaseFirestore.instance
              .collection("Employee")
              .doc(snaps.docs[0].id)
              .collection("Record")
              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
              .set({
            'date': Timestamp.now(),
            'checkIn': DateFormat('kk:mm').format(DateTime.now()),
            'checkOut': "--:--",
            'location': location,
          });
        }
      } else {
        Timer(const Duration(seconds: 3), () async {
          _getLocation();

          QuerySnapshot snaps = await FirebaseFirestore.instance
              .collection("Employee")
              .where('email', isEqualTo: User.employeeId)
              .get();

          DocumentSnapshot snaps2 = await FirebaseFirestore.instance
              .collection("Employee")
              .doc(snaps.docs[0].id)
              .collection("Record")
              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
              .get();

          try {
            String checkIn = snaps2['checkIn'];

            setState(() {
              checkOut = DateFormat('kk:mm').format(DateTime.now());
            });

            await FirebaseFirestore.instance
                .collection("Employee")
                .doc(snaps.docs[0].id)
                .collection("Record")
                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                .update({
              'date': Timestamp.now(),
              'checkIn': checkIn,
              'checkOut': DateFormat('kk:mm').format(DateTime.now()),
              'checkInLocation': location,
            });
          } catch (e) {
            setState(() {
              checkIn = DateFormat('kk:mm').format(DateTime.now());
            });
            await FirebaseFirestore.instance
                .collection("Employee")
                .doc(snaps.docs[0].id)
                .collection("Record")
                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                .set({
              'date': Timestamp.now(),
              'checkIn': DateFormat('kk:mm').format(DateTime.now()),
              'checkOut': "--:--",
              'checkOutLocation': location,
            });
          }
        });
      }
    }
  }

  void _getLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(User.lat, User.long);

    setState(() {
      location =
          "${placemark[0].street}, ${placemark[0].administrativeArea}, ${placemark[0].postalCode}, ${placemark[0].country}";
    });
  }

  void _getRecord() async {
    try {
      QuerySnapshot snaps = await FirebaseFirestore.instance
          .collection("Employee")
          .where('email', isEqualTo: User.employeeId)
          .get();

      DocumentSnapshot snaps2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snaps.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      setState(() {
        checkIn = snaps2['checkIn'];
        checkOut = snaps2['checkOut'];
      });
    } catch (e) {
      setState(() {
        checkIn = "--:--";
        checkOut = "--:--";
      });
    }
  }

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
                "Welcome ",
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: "Regular",
                  fontSize: screenWidth / 20,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Hello, " + User.employeeId,
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: "Bold",
                  fontSize: screenWidth / 17,
                ),
              ),
            ),
            StreamBuilder(
                stream: Stream.periodic(Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 18),
                    child: Text(
                      DateFormat('kk:mm:ss').format(DateTime.now()),
                      style: TextStyle(
                        fontFamily: "Bold",
                        fontSize: screenWidth / 12,
                        color: Color.fromARGB(178, 0, 0, 0),
                      ),
                    ),
                  );
                }),
            Container(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                    text: DateTime.now().day.toString(),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: screenWidth / 18,
                      fontFamily: "Bold",
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat(' MMMM yyyy').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: screenWidth / 18,
                          fontFamily: "Bold",
                        ),
                      )
                    ]),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Jam Masuk",
                          style: TextStyle(
                            fontFamily: "Regular",
                            fontSize: screenWidth / 23,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          checkIn,
                          style: TextStyle(
                            fontFamily: "Bold",
                            fontSize: screenWidth / 13,
                            color: Color.fromARGB(178, 0, 0, 0),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Jam Keluar",
                          style: TextStyle(
                            fontFamily: "Regular",
                            fontSize: screenWidth / 23,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          checkOut,
                          style: TextStyle(
                            fontFamily: "Bold",
                            fontSize: screenWidth / 13,
                            color: Color.fromARGB(178, 0, 0, 0),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            location != " "
                ? Container(
                    margin: EdgeInsets.only(top: 25),
                    child: Text(
                      "Location : " + location,
                      style: TextStyle(
                        fontFamily: "Bold",
                        fontSize: screenWidth / 23,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : const SizedBox(),
            GestureDetector(
              onTap: () {
                scanQRandCheck();
              },
              child: Container(
                height: screenWidth / 2,
                width: screenWidth / 2,
                margin: const EdgeInsets.only(top: 32),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(2, 2),
                          blurRadius: 10)
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.expand,
                          size: 70,
                          color: primary,
                        ),
                        Icon(
                          FontAwesomeIcons.camera,
                          size: 25,
                          color: primary,
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Text(
                        checkIn == "--:--"
                            ? "Scan to Check In"
                            : "Scan to Check Out",
                        style: TextStyle(
                          fontFamily: "Regular",
                          fontSize: screenWidth / 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Container(
            //   margin: const EdgeInsets.only(top: 32, bottom: 32),
            //   child: Text(
            //     "Selamat beristirahat!",
            //     style: TextStyle(
            //       fontFamily: "Regular",
            //       fontSize: screenWidth / 20,
            //       color: Colors.black54,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
