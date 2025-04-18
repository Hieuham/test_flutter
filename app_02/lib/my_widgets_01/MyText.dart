import "package:flutter/material.dart";

class MyText extends StatelessWidget{
  const MyText({super.key});

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

      body: Center(child: Column(
          children: [
            const SizedBox(height: 50,),
            // Text co ban
            const Text("Nguyen Trung Hieu"),
            const SizedBox(height: 20,),

            const Text(
              "Xin chào các bạn đang học lập trình Flutter !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  letterSpacing: 1.5,
                ),
            ),
            const SizedBox(height: 20,),
            const Text(
              "Flutter là một SDK phát triển ứng dụng di động nguồn mở được tạo ra bởi Google. Nó được sử dụng để phát triển ứng ứng dụng cho Android và iOS, cũng là phương thức chính để tạo ứng dụng cho Google Fuchsia.",
                textAlign: TextAlign.center,
                maxLines: 10, // Số dòng tối đa
                // overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
            ),
          ],
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
