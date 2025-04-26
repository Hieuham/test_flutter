import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hiển thị ảnh',
      home: Scaffold(
        appBar: AppBar(title: Text("Hiện thị hình ảnh")),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Image.asset('assets/images/1.png', height: 150),
              ),
              Expanded(
                child: Image.asset('assets/images/2.png', height: 150),
              ),
              Expanded(
                child: Image.asset('assets/images/3.png', height: 150),
              ),
            ],
          ),
        ),
      ),
    );
  }
}