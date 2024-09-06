import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool showLoader = false;

  TextEditingController ageController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  int? selectedAge;
  String? selectedGender;

  List<int> ages = List.generate(100, (index) => index + 1);

  void registerUser() async {
    if (passwordController.text.trim() != confirmpasswordController.text.trim()) {
      Fluttertoast.showToast(
        msg: "Passwords do not match.",
        gravity: ToastGravity.TOP,
      );
      Navigator.pushReplacementNamed(context, '/register');
      return;
    }

    try {
      // Check if email already exists
      bool emailExists = await isEmailAlreadyInUse(emailController.text.trim());
      if (emailExists) {
        Fluttertoast.showToast(
          msg: "Email already in use.",
          gravity: ToastGravity.TOP,
        );
        Navigator.pushReplacementNamed(context, '/register');
        return;
      }

      // Check if phone number already exists
      bool phoneNumberExists = await isPhoneNumberAlreadyInUse(phonenumberController.text.trim());
      if (phoneNumberExists) {
        Fluttertoast.showToast(
          msg: "Phone number already in use.",
          gravity: ToastGravity.TOP,
        );
        Navigator.pushReplacementNamed(context, '/register');
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set({
        "name": nameController.text.trim(),
        "age": ageController.text.trim(),
        "gender": selectedGender,
        "phoneNumber": phonenumberController.text.trim(),
        "email": emailController.text.trim(),
        "createdOn": DateTime.now(),
      }).then((value) => Navigator.pushReplacementNamed(context, "/home"));
    } on FirebaseAuthException catch (e) {
      print("Something Went Wrong:" + e.message.toString());
      print("Error Code:" + e.code.toString());
      Navigator.pushReplacementNamed(context, '/register');
    }
  }

  Future<bool> isEmailAlreadyInUse(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> isPhoneNumberAlreadyInUse(String phoneNumber) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("phoneNumber", isEqualTo: phoneNumber)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // State variable to track whether passwords match
  bool passwordsMatch = false;
  String? _confirmPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text("Sign Up"),
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   titleTextStyle: const TextStyle(
      //   color: Colors.black,
      //   fontSize: 20,
      //     fontWeight: FontWeight.bold,
      //   ),
      // ),
      body: showLoader? Center(child: CircularProgressIndicator(),):
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height:70),

              Text("Sign Up", style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.blue,
              ),
              ),

              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width * 0.9,
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(30.0),
                //   border: Border.all(
                //     color: Colors.blue,
                //   ),
                // ),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: nameController,
                  style: TextStyle(color: Colors.black),
                  cursorColor: Colors.blue, // Cursor color
                  decoration: InputDecoration(
                    hintText: "Full Name", // Hint text
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)), // Opacity for hint text
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: Colors.blue),
                  ),
                ),
              ),



              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width * 0.9,
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(30.0),
                //   border: Border.all(
                //     color: Colors.blue,
                //   ),
                // ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: ageController,
                  style: TextStyle(color: Colors.black),
                  cursorColor: Colors.blue, // Cursor color
                  decoration: InputDecoration(
                    hintText: "Age", // Hint text
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)), // Opacity for hint text
                    border: InputBorder.none, // Remove border
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),// Remove border when focused
                    labelText: 'Age',
                    labelStyle: TextStyle(color: Colors.blue),
                  ),
                ),
              ),

              // const SizedBox(height: 10),

              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width * 0.9,
                // decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(30.0),
                //     border: Border.all(
                //       color: Colors.blue,
                //     )
                // ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: phonenumberController,
                  style: TextStyle(color: Colors.black),
                  cursorColor: Colors.blue, // Cursor color
                  decoration: InputDecoration(
                    hintText: "Phone Number", // Hint text
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)), // Opacity for hint text
                    border: InputBorder.none, // Remove border
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.blue),
                  ),
                ),
              ),

              // const SizedBox(height: 10),

              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width * 0.9,
                // decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(30.0),
                //     border: Border.all(
                //       color: Colors.blue,
                //     )
                // ),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  style: TextStyle(color: Colors.black),
                  cursorColor: Colors.blue, // Cursor color
                  decoration: InputDecoration(
                    hintText: "Email Id", // Hint text
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)), // Opacity for hint text
                    border: InputBorder.none, // Remove border
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelText: 'Email Id',
                    labelStyle: TextStyle(color: Colors.blue),
                  ),
                ),
              ),

              // const SizedBox(height: 10),

              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width * 0.9,
                // decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(30.0),
                //     border: Border.all(
                //       color: Colors.blue,
                //     )
                // ),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: passwordController,
                  style: TextStyle(color: Colors.black),
                  cursorColor: Colors.blue, // Cursor color
                  decoration: InputDecoration(
                    hintText: "Password", // Hint text
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)), // Opacity for hint text
                    border: InputBorder.none, // Remove border
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.blue),
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      passwordsMatch = value == confirmpasswordController.text;
                    });
                  },
                ),
              ),

              // const SizedBox(height: 10),

              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: confirmpasswordController,
                  onChanged: (value) {
                    setState(() {
                      if(value == ''){
                        _confirmPassword=null;
                      }else {
                        _confirmPassword = value;
                      }
                    });
                  },
                  style: TextStyle(color: Colors.black),
                  cursorColor: Colors.blue, // Cursor color
                  decoration: InputDecoration(
                    hintText: "Confirm Password", // Hint text
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.75)), // Opacity for hint text
                    border: InputBorder.none, // Remove border
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: Colors.blue),
                    suffixIcon: _confirmPassword != null && _confirmPassword == passwordController.text
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : _confirmPassword != null && _confirmPassword != passwordController.text
                        ? Icon(Icons.cancel, color: Colors.red)
                        : null, // Display green tick or red cross based on password match
                  ),
                  obscureText: true,
                ),
              ),

              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                    color: Colors.transparent
                ),
                child:Row(
                  children: [
                    Text('Gender : ',style: TextStyle(color: Colors.blue),),
                    Radio<String>( value: "Male",
                      groupValue: selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                    const Text("Male",
                      style: TextStyle(color: Colors.blue),
                    ),
                    Radio<String>(
                      value: "Female",
                      groupValue: selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                    const Text("Female",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.all(1.0),
                width: MediaQuery.of(context).size.width * 0.9, // Adjust width with MediaQuery
                // Set a fixed height or adjust with MediaQuery
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlue,
                      Colors.blue,
                      Colors.lightBlue,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),

                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showLoader = true;
                    });
                    registerUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Set transparent color
                    elevation: 0, // Remove shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text("Register",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Existing User ? ",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                  InkWell(
                    child: Text("Login Here",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "/login");
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}