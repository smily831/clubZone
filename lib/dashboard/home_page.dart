import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sutlej_club/dashboard/profile_page.dart';
import 'member_register.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  Color borderColor = Colors.transparent; // Initially set to transparent

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login page or any other page after signout
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future<void> _showSignOutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sign Out'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to sign out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sign Out'),
              onPressed: () {
                _signOut(context); // Call signout function with context
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkUserExists(String phoneNumber) async {
    // Use Firebase Firestore to check if user exists with given phone number
    var users = await FirebaseFirestore.instance
        .collection('customers')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    if (users.docs.isNotEmpty) {
      // If user already exists, navigate to profile page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            phoneNumber: phoneNumber,
          ),
        ),
      );
    }  else {
      // If user does not exist, navigate to member register page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemberRegistrationPage(
            phoneNumber: phoneNumber,
          ),
        ),
      );

    }
  }

  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);

  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    setState(() {
      final textLength = _searchController.text.length;
      if (textLength == 10) {
        borderColor = Colors.green;
      } else if (textLength > 0 && textLength < 10) {
        borderColor = Colors.red;
      } else {
        borderColor = Colors.transparent;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        backgroundColor: Color(0xff124076),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              _showSignOutConfirmationDialog(context);
            },
          ),
        ],
      ),


      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.02),
            Container(
              padding: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width * 0.93,
              decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(30.0)
              ),
              child: TextField(
                controller: _searchController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(14),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  prefixIcon: Icon(Icons.phone, color: Color(0xff124076)),
                  hintText: 'Search phone number....',
                  hintStyle:
                  TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w400),
                  // Label text color

                ),
                onChanged: (value) {
                  _onSearchTextChanged();
                  // Implement search functionality here
                },
                onSubmitted: (value) {
                  _searchPressed();
                },
              ),
            ),


            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: _searchPressed,
                child: Text('Search',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff124076), // Set background color
                  elevation: 4, // Remove shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(color: Color(0xff596FB7)), // Set border color
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height*0.02),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, '/categoryList');
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        color:  Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(25)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                border: Border.all(color : Color(0xff124076)),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(500)
                            ),
                            child: Icon(Icons.category,
                              color: Color(0xff124076) ,
                              size: 30,)),

                        SizedBox(height: 10),

                        Text('Categories',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Color(0xff124076),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, '/productList');
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        color:  Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(25)
                    ),child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xff124076)),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: Icon(Icons.production_quantity_limits,
                            color: Color(0xff124076) ,
                            size: 30,)),

                      SizedBox(height: 10),

                      Text('Products',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Color(0xff124076),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).size.height*0.02),

            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemberRegistrationPage(
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(10),
                height: 95,
                width: MediaQuery.of(context).size.width*0.85,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color:  Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(25)
                ),child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: Color(0xff124076)),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: Icon(Icons.person,
                        color: Color(0xff124076) ,
                        size: 30,)),

                  SizedBox(width: 10),

                  Text('Add Members',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Color(0xff124076),
                    ),
                  ),
                ],
              ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height*0.02),

            GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, '/scanner');
              },
              child: Container(
                padding: EdgeInsets.all(10),
                height: 95,
                width: MediaQuery.of(context).size.width*0.85,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color:  Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(25)
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xff124076)),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: Icon(Icons.qr_code_scanner,
                          color: Color(0xff124076) ,
                          size: 30,)),

                    SizedBox(width: 10),

                    Text('QR Scanner',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Color(0xff124076),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchPressed() {
    String phoneNumber = _searchController.text.trim();
    if (phoneNumber.length == 10) {
      _checkUserExists(phoneNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid phone number'),
        ),
      );
    }
  }

}