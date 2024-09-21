import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ứng dụng full-stack flutter đơn giản',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Controller để lấy dữ liệu từ Widget TextField
  final controller = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final codeStudentController = TextEditingController();

  /// Biến để lưu thông điệp phản hồi từ server
  String responseMessage = '';
  String codeStudent = '';
  String birthDateTime = '';
  String calculateAgeTime = '';
  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8090';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8090';
    } else {
      return 'http://localhost:8090';
    }
  }

  /// Hàm để gửi tên tới server
  Future<void> sendData() async {
    // Lấy tên từ TextField
    final name = controller.text;
    final code = codeStudentController.text;
    var birthDate = dateOfBirthController.text;
    controller.clear();
    dateOfBirthController.clear();
    codeStudentController.clear();
    final backendUrl = getBackendUrl();
    // Endpoint submit của server
    final url = Uri.parse('$backendUrl/api/v1/submit');
    try {
      // Gửi yêu cầu POST tới server
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json
                .encode({'name': name, 'code': code, 'birthDate': birthDate}),
          )
          .timeout(
            const Duration(seconds: 10),
          );
      // Kiểm tra nếu phản hồi có nội dung
      if (response.body.isNotEmpty) {
        // Giải mã phản hồi từ server
        final data = json.decode(response.body);
        // Cập nhật trạng thái với thông điệp nhận được từ server
        setState(() {
          responseMessage = data['message'];
          codeStudent = data['code'];
          birthDateTime = data['birthDate'];
          int age = calculateAge(tryParseDate(birthDate)); // Tính tuổi
          calculateAgeTime = age.toString(); // Cập nhật tuổi
        });
      } else {
        // Phản hồi không có nội dung
        setState(() {
          responseMessage = 'Không nhận được phản hồi từ server';
        });
      }
    } catch (e) {
      // Xử lý lỗi kết nối hoặc lỗi khác
      setState(() {
        responseMessage = 'Đã xảy ra lỗi: ${e.toString()}';
        print(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
        child: Text(
          'Ứng dụng full-stack flutter',
        ),
      )),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Text(
              'Nguyễn Quang Đạo - 2121050451',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Center(
              child: Text(
                'Nhập thông tin cá nhân của bạn :',
              ),
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: codeStudentController,
              decoration: const InputDecoration(labelText: 'Mã sinh viên'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: dateOfBirthController,
              decoration: const InputDecoration(labelText: 'Ngày sinh'),
              keyboardType: TextInputType.datetime,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  setState(() {
                    dateOfBirthController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: sendData,
              child: const Text('Gửi'),
            ),
            const SizedBox(height: 20),
            // Hiển thị thông điệp phản hồi từ server
            Center(
              child: Text(
                'Kết quả:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Center(
              child: Text(
                responseMessage.isNotEmpty
                    ? 'Tên của bạn là: $responseMessage'
                    : '',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Center(
              child: Text(
                birthDateTime.isNotEmpty
                    ? 'Ngày sinh của bạn là: $birthDateTime -> $calculateAgeTime tuổi'
                    : '',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              codeStudent.isNotEmpty
                  ? 'Mã sinh viên của bạn là: $codeStudent'
                  : '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    int monthDifference = currentDate.month - birthDate.month;

    if (monthDifference < 0 ||
        (monthDifference == 0 && currentDate.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  DateTime tryParseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      // Handle parsing exceptions (e.g., show error message)
      print("Error parsing date: $e");
      return DateTime.now(); // Or return a default value
    }
  }
}
