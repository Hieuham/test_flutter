import 'package:flutter/material.dart';

class MyButton_2 extends StatelessWidget {
  const MyButton_2({super.key});

  @override
  Widget build(BuildContext context) {
    // Trả về Scaffold - widget cung cấp bố cục Material Design cơ bản
    return Scaffold(
      // Tiêu đề của ứng dụng
      appBar: AppBar(
        title: Text("App_02"),

        backgroundColor: Colors.lightBlueAccent,
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              print("b1");
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              print("b2");
            },
            icon: Icon(Icons.abc),
          ),
          IconButton(
            onPressed: () {
              print("b3");
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50),

            // ElevatedButton là một nút bấm được nâng lên với hiệu ứng đổ bóng,
            // thường dùng cho các hành động chính trong ứng dụng.
            ElevatedButton(
              onPressed: () {
                print("ElevateButton");
              },
              child: Text("ElevateButton", style: TextStyle(fontSize: 24)),
              style: ElevatedButton.styleFrom(
                // màu nền
                backgroundColor: Colors.green,
                // màu của các nội dung bên trong
                foregroundColor: Colors.white,
                // dạng hình
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                // padding
                padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15),
                // elevate
                elevation: 15,
              ),
            ),
            SizedBox(height: 80),
            // Chọn thêm ít nhất 1 dạng nút nhấn khác để thiết kế
            TextButton(
              onPressed: () {
                print("TextButton");
              },
              child: Text("TextButton", style: TextStyle(fontSize: 24)),
              style: TextButton.styleFrom(
                // màu nền
                backgroundColor: Colors.amberAccent,
                // màu của các nội dung bên trong
                foregroundColor: Colors.white,
                // dạng hình
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                // padding
                padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20),
                // elevate
                elevation: 20,
              ),
            ),
            SizedBox(height: 80,),

            InkWell(
              onTap: (){
                print("Inkwell được nhấn");
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                ),
                child: Text("Button tùy chỉnh với Inkwell"),
              ),
            )
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {print("pressed");
        },
        child: const Icon(Icons.more_vert),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm kiếm"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
        ],
      ),
    );
  }
}