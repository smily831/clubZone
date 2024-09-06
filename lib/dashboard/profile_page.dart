import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sutlej_club/dashboard/plan_history.dart';
import 'package:sutlej_club/dashboard/plans.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sutlej_club/dashboard/sell_product.dart';

class ProfilePage extends StatefulWidget {
  final String phoneNumber;
  final int? totalBill;

  const ProfilePage({super.key, required this.phoneNumber, this.totalBill});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userFuture;
  late String currentPlanId = '';
  late Map<String, dynamic> currentPlanData = {};
  late String planName = '';
  late int balance = 0;
  late Map<String, dynamic> userData = {}; // Declare userData here
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();
  bool isScrollDone = false;
  List<Map<String, dynamic>> totaltransactions = [];
  List<Map<String, dynamic>> transactions = [];
  int start = 0, end = 7;

  @override
  void initState() {
    super.initState();
    _userFuture = _getUserDetails();
    _scrollController.addListener(scrollListner);
    fetchData();
    fetchTransactions();
    print(widget.phoneNumber);
    fetchCurrentPlan();
    print(widget.totalBill);
  }

  void fetchData() async {
    // Simulating some asynchronous data fetching process
    await Future.delayed(Duration(seconds: 2)); // Simulate 2 seconds delay
    setState(() {
      isLoading =
      false; // Set isLoading to false when data fetching is completed
    });
  }

  void scrollListner() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (isScrollDone || transactions.length == totaltransactions.length) {
        return;
      }
      setState(() {
        isScrollDone = true;
      });
      await Future.delayed(Duration(seconds: 2));

      print("scroll listner called");
      if ((totaltransactions.length - transactions.length) < 5) {
        print("hi");
        setState(() {
          transactions = totaltransactions;

          isScrollDone = false;
        });
        return;
      }

      if (totaltransactions.length > transactions.length) {
        setState(() {
          start += 7;
          end += 7;
          transactions = transactions + totaltransactions.sublist(start, end);
          isScrollDone = false;
        });
        return;
      }
    }
  }

  void fetchTransactions() async {
    setState(() {
      isLoading = true;
    });
    List<Map<String, dynamic>> fetchedTransactions = [];

    // Get the current year
    int currentYear = DateTime.now().year;

    // Iterate over the months in descending order within the current year
    for (int month = 12; month >= 1; month--) {
      String monthName =
      DateFormat('MMMM').format(DateTime(currentYear, month));

      var docRef = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(currentYear.toString())
          .collection(monthName)
          .where('phoneNumber', isEqualTo: widget.phoneNumber)
          .orderBy('date',
          descending: true) // Order by date in descending order
          .orderBy('time',
          descending: true) // Then order by time in descending order
          .get();

      docRef.docs.forEach((doc) async {
        Map<String, dynamic> transactionData = doc.data();

        List<Map<String, dynamic>> productDetails = [];

        // Iterate through the productList
        for (var productEntry in transactionData['productList']) {
          var productId =
          productEntry['productId']; // Get productId from productEntry
          var quantity =
          productEntry['quantity']; // Get quantity from productEntry

          // Query the 'products' collection using collectionGroup
          var productQuery = await FirebaseFirestore.instance
              .collectionGroup('products')
              .where('id', isEqualTo: productId) // Adjust to match 'id' field
              .get();

          // Check if any documents were found
          if (productQuery.docs.isNotEmpty) {
            // Extract the product name
            var productName = productQuery.docs.first['productName'];

            // Add the product name and quantity to productDetails list
            productDetails.add({
              'productName': productName,
              'quantity': quantity,
            });
          }
        }

        // Add productDetails to transactionData
        transactionData['productDetails'] = productDetails;
        fetchedTransactions.add(transactionData);
      });
    }

    // Sort fetched transactions based on date and time
    fetchedTransactions.sort((a, b) {
      // Parse date and time strings using DateFormat
      DateTime dateTimeA =
      DateFormat('dd-MM-yyyy HH:mm').parse(a['date'] + ' ' + a['time']);
      DateTime dateTimeB =
      DateFormat('dd-MM-yyyy HH:mm').parse(b['date'] + ' ' + b['time']);
      return dateTimeB.compareTo(dateTimeA); // Sort in descending order
    });

    setState(() {
      totaltransactions = fetchedTransactions;
      // print(totaltransactions);
      if (end < fetchedTransactions.length) {
        transactions = fetchedTransactions.sublist(start, end);
      } else {
        transactions = fetchedTransactions;
      }
      isLoading = false;
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserDetails() async {
    return FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.phoneNumber)
        .get();
  }

  Future<void> fetchCurrentPlan() async {
    try {
      final customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.phoneNumber)
          .get();

      if (customerDoc.exists) {
        print(customerDoc);
        final currentPlanId = customerDoc['currentPlan'] ?? '';
        final currentPlanDoc = await FirebaseFirestore.instance
            .collection('plans')
            .doc(currentPlanId)
            .get();

        if (currentPlanDoc.exists) {
          final amount = currentPlanDoc['amountGet'] ?? 0;
          final customerBalance = customerDoc['balance'];

          final updatedBalance = customerBalance - (widget.totalBill ?? 0);
          await FirebaseFirestore.instance
              .collection('customers')
              .doc(widget.phoneNumber)
              .update({'balance': updatedBalance});

          setState(() {
            balance = updatedBalance;
          });

          setState(() {
            planName = currentPlanDoc['planName'];
          });

          // Check if the current date matches the end date
          final endDateString = customerDoc[
          'endDate']; // Assuming endDate is a string representing a date in the format "dd-MM-yyyy"
          if (endDateString != null) {
            try {
              final parts = endDateString.split('-');
              if (parts.length == 3) {
                final day = int.parse(parts[0]);
                final month = int.parse(parts[1]);
                final year = int.parse(parts[2]);

                final endDate =
                DateTime(year, month, day); // Construct DateTime object
                if (endDate.isBefore(DateTime.now())) {
                  await FirebaseFirestore.instance
                      .collection('customers')
                      .doc(widget.phoneNumber)
                      .update({'currentPlan': '', 'balance': 0});
                  setState(() {
                    planName = '';
                    balance = 0;

                    print(planName);
                    print(balance);
                  });
                }
              } else {
                print("Invalid date format");
              }
            } catch (e) {
              print("Error parsing date: $e");
            }
          }
        } else {
          print('Current plan not found');
        }
      }
    } catch (error) {
      print('Error fetching current plan: $error');
      // Handle error gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xff124076),
        appBar: AppBar(
          backgroundColor: Color(0xff124076),
          leading: IconButton(
            color: Colors.white,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          actions: [
            Builder(builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlanHistory(
                            phoneNumber: widget.phoneNumber,
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.history,
                      color: Colors.white,

                    ),
                  ),
                  SizedBox(width: 10),
                  if (planName != '')
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: Color(0xff124076),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          if (planName != '')
                            Row(

                              children: [

                                IntrinsicWidth(
                                  child: Container(
                                    padding: EdgeInsets.all(3),
                                    height: 25,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(7)),
                                    child: Text(
                                      "$planName",
                                      style: TextStyle(
                                        color: Color(0xff124076),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "\u{20B9} $balance",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.account_balance_wallet_rounded,
                              color: Colors.white, size: 17),
                        ],
                      ),
                    ),
                ]),
              );
            })
          ],
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white), // Change color here
          ),
        )
            : FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('User not found'));
            }

            var userData = snapshot.data!.data()!;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),

                    ]),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    // border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          SizedBox(width: 10,),
                          Text(
                            userData['fullName'],
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),

                        ],
                      ),

                      SizedBox(height: 10),
                      _buildDetailRow(
                        icon: Icons.phone,
                        label: 'Phone Number ',
                        value: widget.phoneNumber,
                        color: Colors.white,
                      ),
                      SizedBox(height: 10),
                      _buildDetailRow(
                        icon: Icons.email,
                        label: 'Email ',
                        value: userData['email'],
                        color: Colors.white,
                      ),
                      SizedBox(height: 10),
                      _buildDetailRow(
                        icon: Icons.home,
                        label: 'Address ',
                        value: userData['address'],
                        color: Colors.white,

                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(6),
                        height: 35,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Color(0xff124076))),
                        child: GestureDetector(
                          onTap: () {
                            _showQRPopup(context, widget.phoneNumber,
                                userData['fullName']);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.download,
                                color: Color(0xff124076),
                                size: 15,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Generate QR',
                                style: TextStyle(
                                  color: Color(0xff124076),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                SizedBox(height: 10),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Visibility(
                      visible: isLoading || transactions.isEmpty,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xff124076)),
                        ),
                      ),
                      replacement: ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: transactions.length +
                            1, // Add 1 for the loader
                        itemBuilder: (BuildContext context, int index) {
                          if (index == transactions.length) {
                            // This is the loader item
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: 20, // Adjust width as needed
                                  height: 20, // Adjust height as needed
                                  child: CircularProgressIndicator(
                                    strokeWidth:
                                    1, // Adjust the thickness of the indicator
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        Color(0xff124076)),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // This is a transaction item
                            var transaction = transactions[index];
                            // Color tileColor = index % 2 == 0 ? Colors.grey[200]! : Colors.white;
                            return ListTile(
                              tileColor: Colors.grey.shade100,
                              title: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  for (var productDetail
                                  in transaction['productDetails'])
                                    Text(
                                      '${productDetail['quantity']} x ${productDetail['productName']}',
                                    ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${transaction['date']} at ${transaction['time']}',
                                      ),
                                      Text(
                                        '\u20B9 ${transaction['totalBill']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(color: Colors.grey.shade400.withOpacity(0.2),),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          if (planName != '')
                            SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.5,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlanPage(
                                                phoneNumber: widget.phoneNumber,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Select Plan',
                                          style: TextStyle(
                                              color: Colors.white), // Set text color
                                        ),
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              side:
                                              BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          backgroundColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                                (states) {
                                              if (states.contains(
                                                  MaterialState.pressed)) {
                                                return Color(0xff124076);
                                              }
                                              return Color(0xff124076);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.5,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SellProduct(
                                                phoneNumber: widget.phoneNumber,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Sell Product',
                                          style: TextStyle(
                                              color: Colors.white), // Set text color
                                        ),
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              side:
                                              BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          backgroundColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                                (states) {
                                              if (states.contains(
                                                  MaterialState.pressed)) {
                                                return Color(0xff124076);
                                              }
                                              return Color(0xff124076);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PlanHistory(
                                              phoneNumber: widget.phoneNumber,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.history,
                                        color: Colors.white,
                                      ),
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            side:
                                            BorderSide(color: Colors.white),
                                          ),
                                        ),
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                              (states) {
                                            if (states.contains(
                                                MaterialState.pressed)) {
                                              return Color(0xff124076);
                                            }
                                            return Color(0xff124076);
                                          },
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PlanPage(
                                              phoneNumber: widget.phoneNumber,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Select Plan',
                                        style: TextStyle(
                                            color: Colors.white), // Set text color
                                      ),
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            side:
                                            BorderSide(color: Colors.white),
                                          ),
                                        ),
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                              (states) {
                                            if (states.contains(
                                                MaterialState.pressed)) {
                                              return Color(0xff124076);
                                            }
                                            return Color(0xff124076);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon, required String label, required String value, required Color color}) {
    Color iconColor = Colors.white;

    if (icon == Icons.phone) {
      iconColor = Colors.white;
    } else if (icon == Icons.email) {
      iconColor = Colors.white;
    } else if (icon == Icons.home) {
      iconColor = Colors.white;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
        ),
        Icon(
          icon,
          size: 24,
          color: iconColor,
        ),
        SizedBox(width: 10),
        Text(
          '$label: $value',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}

void _showQRPopup(BuildContext context, String number, String name) async {
  // Request storage permission
  var status = await Permission.storage.request();
  if (status.isGranted) {
    // Permission is granted, proceed with generating QR code
    String qrData = number;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.blue.shade400)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Generated QR Code',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                _buildQrWithLogo(qrData, name),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => _downloadQR(context, qrData),
                      child: Text('Download',
                          style: TextStyle(color: Colors.blue.shade400)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.blue.shade400),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  } else {
    // Permission is not granted, show a message or handle it as needed
    print("Storage permission is required to download QR code.");
  }
}

Future<void> _downloadQR(BuildContext context, String qrData) async {
  try {
    RenderRepaintBoundary boundary =
    _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    final directory = await getTemporaryDirectory();
    final tempPath = directory.path;
    final tempFile = await File('$tempPath/temp_image.png').create();
    await tempFile.writeAsBytes(pngBytes);
    await ImageGallerySaver.saveImage(pngBytes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'QR code saved to gallery',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
    );
  } catch (e) {
    print(e.toString());
  }
}

GlobalKey _globalKey = GlobalKey();

Widget _buildQrWithLogo(String qrData, String name) {
  return RepaintBoundary(
    key: _globalKey,
    child: Container(
      // width: 220,
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Minimize vertical size
        children: [
          Image.asset(
            'assets/unnamed.png',
            width: 60,
            height: 50,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 15), // Add spacing between name and QR code
          Container(
            width: 150, // Reduce QR code width for better proportion
            height: 150, // Reduce QR code height for better proportion
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              // Add border radius for rounded corners
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  // Add shadow for depth effect
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Transform.scale(
              scale: 0.96,
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200, // This is the base size of the QR code
                backgroundColor: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 10),

          Text(name, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}