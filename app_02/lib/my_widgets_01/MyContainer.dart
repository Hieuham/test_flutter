import "package:flutter/material.dart";

class MyContainer extends StatelessWidget{
  const MyContainer({super.key});

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
        backgroundColor: Colors.lightGreen,
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
          child: Container(
            width: 300,
            height: 200,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  )
                ]
            ),

            child: Align(
              alignment: Alignment.center,
              child: const Text(
                  "Nguyễn Trung Hiếu",
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 18,
                ),
              ),
            ),
        ),
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
