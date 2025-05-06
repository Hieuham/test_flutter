import 'package:flutter/material.dart';
import '../db/DatabaseHelper.dart'; // Import DatabaseHelper
import '../models/User.dart'; // Import User model

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Khai báo GlobalKey để quản lý trạng thái của Form
  final _formKey = GlobalKey<FormState>();

  // Các TextEditingController để lấy giá trị từ các trường nhập liệu
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Biến trạng thái để điều khiển việc hiển thị/ẩn mật khẩu
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Tạo một instance của DatabaseHelper để tương tác với cơ sở dữ liệu
  final _dbHelper = DatabaseHelper();

  // Các biến màu sắc để tùy chỉnh giao diện
  final Color _primaryColor = Colors.deepPurple;
  final Color _backgroundColor = Colors.grey.shade100;
  final Color _titleTextColor = Colors.deepPurple.shade800;
  final Color _labelTextColor = Colors.black87;
  final Color _registerButtonColor = Colors.deepPurpleAccent;
  final Color _registerButtonTextColor = Colors.white;
  final Color _loginTextColor = Colors.deepPurple;

  // Hàm bất đồng bộ để thực hiện quá trình đăng ký
  Future<void> _register() async {
    // Kiểm tra xem form có hợp lệ hay không bằng cách gọi phương thức validate() của GlobalKey
    if (_formKey.currentState!.validate()) {
      // Lấy giá trị từ các trường nhập liệu
      String username = _usernameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      // Lấy thời gian hiện tại để lưu vào cơ sở dữ liệu
      DateTime now = DateTime.now();

      // Tạo một ID duy nhất cho người dùng dựa trên timestamp
      String userId = now.millisecondsSinceEpoch.toString();

      // Kiểm tra xem tên đăng nhập đã tồn tại trong cơ sở dữ liệu chưa
      User? existingUserByUsername = await _dbHelper.getUserByUsername(username);

      // Kiểm tra xem email đã tồn tại trong cơ sở dữ liệu chưa
      User? existingUserByEmail = await _dbHelper.getUserByEmail(email);

      // Nếu tên đăng nhập đã tồn tại, hiển thị thông báo lỗi
      if (existingUserByUsername != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tên đăng nhập đã tồn tại')),
        );
        return; // Dừng quá trình đăng ký
      }

      // Nếu email đã tồn tại, hiển thị thông báo lỗi
      if (existingUserByEmail != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email đã được sử dụng')),
        );
        return; // Dừng quá trình đăng ký
      }

      // Tạo một đối tượng User mới
      User newUser = User(
        id: userId,
        username: username,
        password: password, // LƯU Ý: Trong ứng dụng thực tế, bạn nên mã hóa mật khẩu trước khi lưu
        email: email,
        createdAt: now,
        lastActive: now,
      );

      print("User.toMap(): ${newUser.toMap()}"); // In ra toàn bộ Map
      print("createdAt value: ${newUser.createdAt?.toIso8601String()}"); // In giá trị createdAt
      print("lastActive value: ${newUser.lastActive?.toIso8601String()}");
      // Gọi phương thức createUser của DatabaseHelper để lưu người dùng vào cơ sở dữ liệu
      int result = await _dbHelper.createUser(newUser);

      // Kiểm tra kết quả của quá trình tạo người dùng
      if (result > 0) {
        // Nếu thành công, hiển thị thông báo thành công và quay lại màn hình trước đó
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng ký thành công!')),
        );
        Navigator.pop(context); // Quay lại màn hình đăng nhập
      } else {
        // Nếu có lỗi xảy ra, hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã có lỗi xảy ra khi đăng ký')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text('Đăng ký', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Tạo tài khoản mới',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: _titleTextColor,
                  ),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập',
                    labelStyle: TextStyle(color: _labelTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _primaryColor, width: 2.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  // Validator cho trường tên đăng nhập
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên đăng nhập';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: _labelTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _primaryColor, width: 2.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  // Validator cho trường email
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword, // Sử dụng biến trạng thái để ẩn/hiện mật khẩu
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle: TextStyle(color: _labelTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _primaryColor, width: 2.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    // Thêm icon để hiển thị/ẩn mật khẩu
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility // Icon hiển thị khi mật khẩu đang ẩn
                            : Icons.visibility_off, // Icon hiển thị khi mật khẩu đang hiện
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        // Khi icon được nhấn, cập nhật trạng thái của _obscurePassword
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  // Validator cho trường mật khẩu
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword, // Sử dụng biến trạng thái để ẩn/hiện mật khẩu xác nhận
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    labelStyle: TextStyle(color: _labelTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: _primaryColor, width: 2.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    // Thêm icon để hiển thị/ẩn mật khẩu xác nhận
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility // Icon hiển thị khi mật khẩu đang ẩn
                            : Icons.visibility_off, // Icon hiển thị khi mật khẩu đang hiện
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        // Khi icon được nhấn, cập nhật trạng thái của _obscureConfirmPassword
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  // Validator cho trường xác nhận mật khẩu
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _register, // Gọi hàm _register khi nút được nhấn
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _registerButtonColor,
                    foregroundColor: _registerButtonTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Đăng ký', style: TextStyle(fontSize: 18.0)),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Quay lại màn hình trước đó (thường là màn hình đăng nhập)
                  },
                  child: Text(
                    'Đã có tài khoản? Đăng nhập',
                    style: TextStyle(color: _loginTextColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}