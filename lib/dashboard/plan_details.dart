import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sutlej_club/dashboard/profile_page.dart';
import 'package:sutlej_club/dashboard/splash_screen.dart';
import 'package:intl/intl.dart';

class PlanDetails extends StatefulWidget {
  final String phoneNumber;
  final String id;


  const PlanDetails({super.key, required this.phoneNumber, required this.id,});

  @override
  State<PlanDetails> createState() => _PlanDetailsState();
}

class _PlanDetailsState extends State<PlanDetails> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userFuture;

  String planName = '';
  String description = '';
  int validity =0 ;
  int amountPay = 0;
  int amountGet = 0;

  @override
  void initState(){
    super.initState();
    _userFuture = _getUserDetails();
    fetchPlans();
  }

  void sellPlan() async {
    try {
      // Fetch the plan details
      final planDoc = await FirebaseFirestore.instance
          .collection('plans')
          .doc(widget.id) // Assuming widget.id is the plan ID
          .get();

      if (planDoc.exists) {
        // Get the amount from the plan document
        final planData = planDoc.data();
        final amount = planData?['amountGet'];
        final planName = planData?['planName'];

        // Get the current balance of the customer
        final customerDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(widget.phoneNumber)
            .get();

        if (customerDoc.exists) {
          // If the customer document exists, update the balance
          final customerData = customerDoc.data();
          final currentBalance = customerData?['balance'] ?? 0; // Default to 0 if balance doesn't exist

          // Calculate the new balance
          final newBalance = currentBalance + amount;
          DateTime now = DateTime.now();
          String startDate = DateFormat('dd-MM-yyyy').format(now);
          DateTime endDate = now.add(Duration(days: validity));
          String formattedEndDate = DateFormat('dd-MM-yyyy').format(endDate);

          // Update the currentPlan field and balance in the customers collection
          await FirebaseFirestore.instance
              .collection('customers')
              .doc(widget.phoneNumber)
              .update({'currentPlan': widget.id, 'balance': newBalance, 'startDate': startDate,
            'endDate': formattedEndDate,});

          String date = DateFormat('dd-MM-yyyy').format(now);
          String time = DateFormat('HH:mm').format(now);

          // Create a subcollection named "history" within the plan document
          await FirebaseFirestore.instance
              .collection('plans')
              .doc(widget.id)
              .collection('history')
              .add({
            'planName': planName,
            'planId': widget.id,
            'phoneNumber': widget.phoneNumber,
            'date': date,
            'time': time,
          });

          // Navigate to another screen after selling the plan

        } else {
          // If customer document doesn't exist, create it with the new balance
          await FirebaseFirestore.instance
              .collection('customers')
              .doc(widget.phoneNumber)
              .set({'currentPlan': widget.id, 'balance': amount});

          // Navigate to another screen after selling the plan
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage(phoneNumber: widget.phoneNumber)),
          );
        }

        print('Plan sold successfully.');
      } else {
        print('Plan with ID ${widget.id} not found.');
      }
    } catch (error) {
      print('Error selling plan: $error');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserDetails() async {
    return FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.phoneNumber)
        .get();

  }
  Future<void> fetchPlans() async {
    try {
      // Fetch the document with the specified ID
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('plans').doc(widget.id).get();

      // Check if the document exists
      if (docSnapshot.exists) {
        setState(() {
          // Assign values to properties
          planName = docSnapshot['planName'] ?? '';
          description = docSnapshot['planDescription'] ?? '';
          validity = docSnapshot['validity'] ?? 0;
          amountPay = docSnapshot['amountPay'] ?? 0;
          amountGet = docSnapshot['amountGet'] ?? 0;
        });
      } else {
        // Handle the case where the document doesn't exist
        print('Document with ID ${widget.id} does not exist');
      }
    } catch (error) {
      // Handle errors
      print('Error fetching plans: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff124076),
      appBar: AppBar(
        backgroundColor: Color(0xff124076),
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white,));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found'));
          }

          var userData = snapshot.data!.data()!;
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Color(0xff124076),
                  height: MediaQuery.of(context).size.width*0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          userData['fullName'],
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade400,
                          ),
                        ),

                        SizedBox(height: 10),

                        _buildDetailRow(
                          icon: Icons.phone,
                          label: 'Phone Number ',
                          value: widget.phoneNumber,
                        ),
                        SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.email,
                          label: 'Email ',
                          value: userData['email'],
                        ),
                        SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.home,
                          label: 'Address ',
                          value: userData['address'],
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height*0.6,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)
                      )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Color(0xff124076), width: 1),
                        ),
                        child: Text(
                          planName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff124076),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14.0,
                          color : Colors.grey.shade600,
                        ),
                      ),

                      SizedBox(height: 10),

                      Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Color(0xff124076)
                              ),
                              child: Icon(
                                Icons.timer_outlined,
                                size: 12,
                                color: Colors.white,
                              )
                          ),

                          SizedBox(width: 10),

                          Text(
                            'Validity : ',
                            style: TextStyle(
                              fontSize: 16,
                              // fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            validity.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          Text(
                            ' days',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Container(
                            padding: EdgeInsets.symmetric(horizontal:4,vertical: 0.5),
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Color(0xff124076)
                            ),
                            child: Text('\u{20B9}',style: TextStyle(color: Colors.white,fontSize: 12),),
                          ),

                          SizedBox(width: 10),

                          Text(
                            'Pay ',
                            style: TextStyle(
                              fontSize: 16,
                              // fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            amountPay.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600
                            ),
                          ),

                          Text(
                            ' \u2192 Get ',
                            style: TextStyle(
                              fontSize: 16,
                              // fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            amountGet.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10,),

                      Container(
                        width: MediaQuery.of(context).size.width*0.95,
                        child: ElevatedButton(
                          onPressed: () {
                            sellPlan();

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SplashScreen()),
                            );
                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => ProfilePage(phoneNumber: widget.phoneNumber)),
                              );
                            });
                          },
                          child: Text(
                            'Sell Plan',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff124076), // Set background color
                            elevation: 0, // Remove shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    Color iconColor = Colors.white;

    if (icon == Icons.phone) {
      iconColor = Colors.grey.shade400;
    } else if (icon == Icons.email) {
      iconColor = Colors.grey.shade400;
    } else if (icon == Icons.home) {
      iconColor = Colors.grey.shade400;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.1,),
        Icon(
          icon,
          size: 24,
          color: iconColor,
        ),
        SizedBox(width: 10),
        Text(
          '$label: $value',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );

  }

}