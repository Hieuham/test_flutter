import "package:flutter/material.dart";

class MyAppBar extends StatelessWidget{
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context){
    //Tra ve Scaffold - widget cung cap bo cuc Material Design
    // Man hinh
    return Scaffold(
      // Tieu de cua ung dung
      appBar: AppBar(
        // Tiêu đề
        title: Text("App 02"),
        // Màu nền
        backgroundColor: Colors.amberAccent,
        // Do nang/ do bong cua AppBar
        elevation: 4,
        actions: [
          IconButton(
            onPressed:() {
              print("b1");
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: (){
              print("b2");
            },
            icon: Icon(Icons.abc),
          ),
          IconButton(
            onPressed: (){
              print("b3");
            },
            icon: Icon(Icons.more_vert),
          )
        ],
      ),
      body: Center(
        child: Text("Nội dung chính"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){print("pressed");},
        child: const Icon(Icons.more_vert),
      ),

      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm kiếm"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
      ]),
    );
  }
}