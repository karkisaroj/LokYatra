import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/loginPage.dart';

class register extends StatelessWidget {
  const register({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
      }, icon: Icon(Icons.arrow_back)),),
      body: Column(
        children: [
          Center(child: Image.asset("assets/images/lokyatra_logo.png",width: 100,height: 70,)),

        ],
      ),
    );
  }
}
