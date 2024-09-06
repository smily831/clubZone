import 'package:flutter/material.dart';


class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  navigateToLogin(BuildContext context) async{
    Future.delayed(Duration(seconds: 3),(){
      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  @override
  Widget build(BuildContext context) {

    navigateToLogin(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/unnamed.png", width: 300, height: 300,),
            const SizedBox(height: 12),
            const Text("The Sutlej Club", style: TextStyle(color: Colors.blue, fontSize: 28,),),
            const Divider(),
            const SizedBox(height: 6,),
            const Text("Ludhiana, Punjab ", style: TextStyle(color: Colors.lightBlue, fontSize: 20),)
          ],
        ),
      ),
    );
  }
}
