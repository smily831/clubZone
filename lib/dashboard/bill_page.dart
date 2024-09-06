import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sutlej_club/dashboard/profile_page.dart';
import 'package:sutlej_club/dashboard/sell_product.dart';
import 'package:sutlej_club/globals.dart' as globals;

class BillPage extends StatefulWidget {

  final String phoneNumber;

  const BillPage({Key? key, required this.phoneNumber});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  List<Map<String, dynamic>> productDetails = [];
  int enteredPin = 0;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  void fetchProductDetails() async {
    List<Map<String, dynamic>> details = [];
    for (var item in globals.productList) {
      var querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('products')
          .where('id', isEqualTo: item['productId'])
          .get();

      for (var docSnapshot in querySnapshot.docs) {
        var data = docSnapshot.data();
        details.add({
          'productId': item['productId'],
          'productName': data?['productName'] ?? 'Product Name Not Available',
          'Price': data?['Price'] ?? 'Price Not Available',
          'quantity': item['quantity']
        });
      }
    }
    setState(() {
      productDetails = details;
    });
  }

  void updateProductQuantity(String productId, int newQuantity) {
    setState(() {
      for (var item in globals.productList) {
        if (item['productId'] == productId) {
          item['quantity'] = newQuantity;
          break;
        }
      }
      for (var product in productDetails) {
        if (product['productId'] == productId) {
          product['quantity'] = newQuantity;
          break;
        }
      }

      // Remove product from lists if quantity is 0
      if (newQuantity == 0) {
        globals.productList.removeWhere((item) =>
        item['productId'] == productId);
        productDetails.removeWhere((product) =>
        product['productId'] == productId);
      }
      if (globals.productList.isEmpty) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                SellProduct(phoneNumber: widget.phoneNumber)));
        globals.totalQuantity = 0;
      }
    });
  }

  int calculateTotalPrice(int price, int quantity) {
    return price * quantity;
  }

  int calculateTotalBill() {
    int totalBill = 0;
    for (var product in productDetails) {
      int totalPrice = calculateTotalPrice(
          product['Price'] as int, product['quantity'] as int);
      totalBill += totalPrice;
    }
    return totalBill;
  }

  void addTransaction(String phoneNumber, List productList,
      int totalBill) async {
    try {
      DateTime now = DateTime.now();
      String year = now.year.toString();
      String month = DateFormat('MMMM').format(now);
      String date = DateFormat('dd-MM-yyyy').format(now);
      String time = DateFormat('HH:mm').format(now);

      final currentCustomerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.phoneNumber)
          .get();
      final balance = currentCustomerDoc['balance'];

      if (totalBill > balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient Balance'),
            duration: Duration(seconds: 2),
          ),
        );
        return; // Stop further execution if balance is insufficient
      }


      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(year)
          .collection(month)
          .add({
        'phoneNumber': phoneNumber,
        'productList': productList,
        'totalBill': totalBill,
        'date': date,
        'time': time,
        // You can add more fields here if needed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding transaction: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void verifyPinAndSell() async {
    // Get the correct PIN from your database
    int correctPin = await getCorrectPinFromDatabase();

    // Show an alert dialog to enter the PIN
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Define the alert dialog content
        return AlertDialog(
          title: Text('Enter PIN'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'PIN',
            ),
            onChanged: (value) {
              setState(() {
                enteredPin = int.tryParse(value) ?? 0;
                print(enteredPin);
              });
            },
          ),

          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Check if the entered PIN matches the correct PIN
                if (enteredPin == correctPin) {
                  print(enteredPin);
                  // Proceed with the transaction
                  addTransaction(widget.phoneNumber, globals.productList,
                      calculateTotalBill());
                  // Navigate to the profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage(phoneNumber: widget.phoneNumber, totalBill: calculateTotalBill(),)),
                  );
                  globals.totalQuantity = 0;
                  globals.productList = [];
                } else {
                  // Display an error message indicating incorrect PIN
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect PIN. Please try again.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }


  // Method to get the correct PIN from your database
  Future<int> getCorrectPinFromDatabase() async {
    final customerDoc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.phoneNumber)
        .get();
    if (customerDoc.exists) {
      final pin = customerDoc['pin'] as int? ?? 0;
      return pin;
    }
    return 0;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        int totalQuantity = 0;
        // Calculate the sum of all quantities in productList
        for (var product in globals.productList) {
          totalQuantity +=
          product['quantity'] as int; // Explicitly convert to int
        }
        globals.totalQuantity = totalQuantity;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                SellProduct(phoneNumber: widget.phoneNumber)));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Bill Page"),
          backgroundColor: Colors.blue,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          leading: IconButton(
            color: Colors.white,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              int totalQuantity = 0;
              // Calculate the sum of all quantities in productList
              for (var product in globals.productList) {
                totalQuantity +=
                product['quantity'] as int; // Explicitly convert to int
              }
              globals.totalQuantity = totalQuantity;
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      SellProduct(phoneNumber: widget.phoneNumber)));
            },
          ),
        ),

        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: productDetails.length,
                itemBuilder: (context, index) {
                  final product = productDetails[index];
                  final totalPrice = calculateTotalPrice(
                      product['Price'] as int, product['quantity'] as int);

                  return Card(
                    elevation: 1.0,
                    margin: EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 7.0),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['productName'],
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                '₹ ${product['Price']}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          SizedBox(width: 10,),
                          Stack(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: ElevatedButton(

                                          onPressed: () {},
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Expanded(
                                                child: IconButton(
                                                  icon: Icon(
                                                      Icons.remove, size: 16),
                                                  onPressed: () {
                                                    int newQuantity = product['quantity'] -
                                                        1;
                                                    if (newQuantity >= 0) {
                                                      updateProductQuantity(
                                                          product['productId'],
                                                          newQuantity);
                                                      print(
                                                          globals.productList);
                                                    }
                                                  },
                                                ),
                                              ),
                                              Text(
                                                '${product['quantity']}',
                                                style: TextStyle(
                                                    fontSize: 14.0),
                                              ),
                                              Expanded(
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.add, size: 16,),
                                                  onPressed: () {
                                                    int newQuantity = product['quantity'] +
                                                        1;
                                                    updateProductQuantity(
                                                        product['productId'],
                                                        newQuantity);
                                                    print(globals.productList);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius
                                                    .circular(10),
                                                side: BorderSide(
                                                    color: Colors.blue
                                                        .shade900),
                                              ),
                                            ),
                                            backgroundColor: MaterialStateProperty
                                                .resolveWith<Color>(
                                                  (states) {
                                                if (states.contains(
                                                    MaterialState.pressed)) {
                                                  return Colors.blue.shade100;
                                                }
                                                return Colors.blue.shade100;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    '₹ $totalPrice',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // TextFormField(
                  //   keyboardType: TextInputType.number,
                  //   decoration: InputDecoration(
                  //     labelText: 'Enter PIN',
                  //   ),
                  //   onChanged: (value) {
                  //     setState(() {
                  //       enteredPin = value;
                  //     });
                  //   },
                  // ),
                  Text(
                    'Total Bill: ₹ ${calculateTotalBill()}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 1,
                    child: ElevatedButton(onPressed: () {
                      verifyPinAndSell();
                    },
                      child: Text(
                        'Sell',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.blue.shade900),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.resolveWith<
                            Color>(
                              (states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.blue;
                            }
                            return Colors.blue;
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}