import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'result.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeState extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

// ฟังก์ชันแปลผลลัพธ์ความสุกจากภาษาอังกฤษเป็นภาษาไทย
String translateRipeness(String ripeness) {
  if (ripeness == 'Ripe') {
    return 'สุก';
  } else if (ripeness == 'Unripe') {
    return 'ยังไม่สุก';
  } else if (ripeness == 'Overripe') {
    return 'สุกเกินไป';
  } else {
    return 'ไม่ทราบ';
  }
}

class _HomeState extends State<HomeState> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // ฟังก์ชันเลือกภาพจากแกลอรี่
  Future<void> _showImageSourceOptions() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชันถ่ายรูปจากกล้อง
  Future<void> _showCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชันแสดง SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ฟังก์ชันอัปโหลดรูปภาพและรันโมเดลบน Cloud
  void _uploadImage() async {
    if (_image == null) {
      _showSnackBar('กรุณาเลือกภาพ');
      return;
    }

    showDialog(
      // แสดง Dialog ข้อความ "กำลังประมวลผล..."
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 26, 161, 31)),
              ),
              // SizedBox(width: 20),
              // Text('กำลังประมวลผล...', style: TextStyle(fontSize: 16)),
            ],
          ),
        );
      },
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://my-demo-710752847814.asia-southeast1.run.app/predicts'),
      );
      // ใช้ 'image' เป็นชื่อฟิลด์
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));

      // ส่ง request และรับ response
      var response = await request.send();
      Navigator.pop(context); // ปิดการโหลด
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final result = json.decode(responseData);

        // แปลผลลัพธ์จากภาษาอังกฤษเป็นภาษาไทย
        String ripenessInThai = translateRipeness(result['prediction']);

        // นำผลลัพธ์ที่แปลแล้วไปแสดงในหน้าผลลัพธ์
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Result(
              ripenessLevel: ripenessInThai,
              image: _image!,
            ),
          ),
        );
      } else {
        _showSnackBar('เกิดข้อผิดพลาดในการส่งรูปภาพ');
      }
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar('เกิดข้อผิดพลาด: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 227, 154),
        title: Text(
          'ระดับความสุกทุเรียน',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      // กรอบเลือกรูปภาพ
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_image == null) ...[
              GestureDetector(
                onTap: _showImageSourceOptions,
                child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo,
                          size: 50, color: Color.fromARGB(255, 26, 161, 31)),
                      SizedBox(height: 10),
                      Text('เลือกรูปภาพ', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // แสดงข้อความ "หรือ"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text('หรือ', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(
                    width: 130,
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // กรอบถ่ายรูปจากกล้อง
              GestureDetector(
                onTap: _showCamera,
                child: Container(
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 26, 161, 31),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 25, color: Colors.grey),
                      SizedBox(width: 10),
                      Text('ถ่ายรูปจากกล้อง', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
            ] else ...[
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _showImageSourceOptions,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          image: DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _image = null;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          child: Icon(Icons.clear, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],

            // ปุ่มส่งข้อมูล
            Center(
              child: ElevatedButton(
                onPressed: _uploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 26, 161, 31),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: Text('ส่งรูปภาพ', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
