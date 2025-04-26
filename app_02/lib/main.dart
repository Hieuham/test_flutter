import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_02/userMS_API_v2/view/UserListScreen.dart';
import 'package:app_02/userMS_API_v2/view/LoginScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý người dùng',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const _AuthCheckWidget(),
    );
  }
}

// Widget riêng biệt để kiểm tra xác thực
class _AuthCheckWidget extends StatelessWidget {
  const _AuthCheckWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return LoginScreen();
        }

        final prefs = snapshot.data!;
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        if (isLoggedIn) {
          // Đã đăng nhập, chuyển đến màn hình danh sách người dùng
          return UserListScreen(
            onLogout: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Khởi động lại ứng dụng để quay lại màn hình đăng nhập
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) =>  LoginScreen()),
                    (route) => false,
              );
            },
          );
        } else {
          // Chưa đăng nhập, hiển thị màn hình đăng nhập
          return  LoginScreen();
        }
      },
    );
  }
}