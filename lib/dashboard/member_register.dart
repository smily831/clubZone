import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sutlej_club/dashboard/profile_page.dart';

class MemberRegistrationPage extends StatefulWidget {
  final String? phoneNumber;

  const MemberRegistrationPage({Key? key,this.phoneNumber}) : super(key: key);

  @override
  _MemberRegistrationPageState createState() => _MemberRegistrationPageState();
}

class _MemberRegistrationPageState extends State<MemberRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String? firstName;
  String? lastName;
  String phoneNumber = '';
  String? gender;
  String? address;
  int? pin;
  String? email;
  bool showGenerateButton = false;


  @override
  void initState() {
    super.initState(); // Set the initial value of phoneNumber
    phoneNumber = widget.phoneNumber ?? "";
  }

  void _saveData() {
    print(phoneNumber);
    if (_formKey.currentState!.validate()) {
      String fullName = '$firstName $lastName';

      // Save data to Firestore
      FirebaseFirestore.instance.collection('customers').doc(phoneNumber).set({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'address': address,
        'email': email,
        'pin': pin,
      }).then((value) {
        // Data saved successfully
        print('Data saved successfully');
        // Set showDownloadButton to true
        setState(() {
          showGenerateButton = true;
        });
        // Show a snackbar to indicate that data is saved
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved successfully')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(phoneNumber: phoneNumber)),
        );
      }).catchError((error) {
        // An error occurred while saving data
        print('Error saving data: $error');
        // Show a snackbar to indicate error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Registration"),
        backgroundColor: Color(0xff124076),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width * 0.93,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 0.5),
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Color(0xff124076)),
                    cursorColor: Color(0xff124076),
                    decoration: InputDecoration(
                      hintText: "Enter First Name", // Hint text
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)), // Opacity for hint text
                      border: InputBorder.none, // Remove border
                      enabledBorder: InputBorder.none,
                      focusedBorder:InputBorder.none,
                      labelText: 'First Name',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        firstName = value;
                      });
                    },
                  ),
                ),


                SizedBox(height: 10),


                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width * 0.93,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400,width: 0.5),
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Color(0xff124076)),
                    cursorColor: Color(0xff124076),
                    decoration: InputDecoration(
                      hintText: "Enter Last Name",
                      // Hint text
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)),
                      // Opacity for hint text
                      border: InputBorder.none,
                      // Remove border
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      labelText: 'Last Name',
                      labelStyle: TextStyle(color:Colors.grey.shade700),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        lastName = value;
                      });
                    },
                  ),
                ),

                SizedBox(height: 10),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width * 0.93,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400,width: 0.5),
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Color(0xff124076)),
                    cursorColor: Color(0xff124076),
                    decoration: InputDecoration(
                      hintText: "Enter Phone Number",
                      // Hint text
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)),
                      // Opacity for hint text
                      border: InputBorder.none,
                      // Remove border
                      enabledBorder:InputBorder.none,
                      focusedBorder: InputBorder.none,
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                    initialValue: widget.phoneNumber,
                    onChanged: (value) {
                      setState(() {
                        phoneNumber = value;
                      });
                    },
                  ),
                ),

                SizedBox(height: 10),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width * 0.93,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400,width: 0.5),
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.black),
                    cursorColor:Color(0xff124076),
                    decoration: InputDecoration(
                      hintText: "Enter Email",
                      // Hint text
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)),
                      // Opacity for hint text
                      border: InputBorder.none,
                      // Remove border
                      enabledBorder:InputBorder.none,
                      focusedBorder: InputBorder.none,
                      labelText: 'Email',
                      labelStyle: TextStyle(color:Colors.grey.shade700),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Gender: ',
                        style: TextStyle(
                            color: Color(0xff124076),
                            fontSize: 15
                        ),
                      ),
                      Radio(
                        value: 'Male',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                          });
                        },
                        activeColor: Color(0xff124076),
                      ),
                      Text(
                        'Male',
                        style: TextStyle(color: Color(0xff124076)),
                      ),
                      Radio(
                        value: 'Female',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                          });
                        },
                        activeColor: Color(0xff124076),
                      ),
                      Text(
                        'Female',
                        style: TextStyle(color: Color(0xff124076)),
                      ),
                    ],
                  ),
                ),


                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width * 0.93,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400,width: 0.5),
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.black),
                    cursorColor: Color(0xff124076),
                    decoration: InputDecoration(
                      hintText: "Enter Address",
                      // Hint text
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)),
                      // Opacity for hint text
                      border: InputBorder.none,
                      // Remove border
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      labelText: 'Address',
                      labelStyle: TextStyle(color:Colors.grey.shade700),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        address = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width * 0.93,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 0.5),
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.black),
                    cursorColor: Color(0xff124076),
                    decoration: InputDecoration(
                      hintText: "Enter PIN",
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      labelText: 'PIN',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4), // Limit to 4 digits
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter PIN';
                      } else if (value.length != 4) {
                        return 'PIN must be 4 digits';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        pin = int.tryParse(value);
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),

                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white), // Set text color
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff124076), // Set background color
                        elevation: 4, // Remove shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color:Color(0xff124076)), // Set border color
                        ),
                      ),
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}