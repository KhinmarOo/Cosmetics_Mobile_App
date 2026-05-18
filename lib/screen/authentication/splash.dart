import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF554518),
              Color(0xFF262116),
              Color(0xFF554518),
            ]
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Image(image: AssetImage("assets/images/cosmetic_logo.png"),
              width: 150,
              ),
              Text("Beauty with me.",
              style: TextStyle(
                fontSize: 35,fontWeight: FontWeight.bold,color: Color(0xFFC7A17A)
              ),
              ),
              _buildElegantSubtitle(),
            ],
          ),
        ),
      ),
    );
  }
}

const Color goldColor= Color(0xFFC7A17A);
Widget _buildElegantSubtitle(){
  return Row(
    children: [
      const Expanded(
        child: Divider(
          color: goldColor,
          thickness: 1.0,
          indent: 500,
          endIndent: 10,
        )
      ),
      const Text("Your Journey to Elegant",
      style: TextStyle(
        fontSize: 8,
        color: goldColor,

      ),),
      const Expanded(
        child: Divider(
          color: goldColor,
          thickness: 1.0,
          indent: 8,
          endIndent: 500,
        )
      ),
    ],
  );
}