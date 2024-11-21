import 'package:flutter/material.dart';
import 'dart:io';
import '/database/database.dart';

class Durian {
  final String imagePath;
  final String ripenessLevel;
  final String timestamp;
  Durian({
    required this.imagePath,
    required this.ripenessLevel,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'image_path': imagePath,
      'ripeness_level': ripenessLevel,
      'timestamp': timestamp,
    };
  }

  factory Durian.fromMap(Map<String, dynamic> map) {
    return Durian(
      imagePath: map['image_path'],
      ripenessLevel: map['ripeness_level'],
      timestamp: map['timestamp'],
    );
  }
}

class Result extends StatefulWidget {
  final String ripenessLevel;
  final File? image;

  const Result({
    required this.ripenessLevel,
    required this.image,
  });

  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  bool _isSaving = false; // สถานะการบันทึกข้อมูล

  Future<void> _handleButtonPress() async {
    if (widget.image == null) {
      Navigator.of(context).pop(); // ถ้าไม่มีรูปภาพ ย้อนกลับหน้าหลัก
      return;
    }
    await _saveToDatabase();

    Navigator.of(context).pushReplacementNamed('/');
  }

  // ฟังก์ชันบันทึกข้อมูลลงในฐานข้อมูล
  Future<void> _saveToDatabase() async {
    if (_isSaving) return; // ป้องกันการบันทึกหลายครั้ง
    setState(() {
      _isSaving = true;
    });

    try {
      await DatabaseHelper().savePrediction(
        widget.image?.path ?? '',
        widget.ripenessLevel,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกข้อมูลสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ผลลัพธ์ระดับความสุก', style: TextStyle(fontSize: 24)),
        backgroundColor: const Color.fromARGB(255, 151, 227, 154),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      //รูปภาพที่อัปโหลดไปทำนาย
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.image != null)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.0),
                  image: DecorationImage(
                    image: FileImage(widget.image!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 20),

            //ระดับความสุก
            Text(
              'ระดับความสุกทุเรียน: ${widget.ripenessLevel}',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            //ปุ่มตกลง
            ElevatedButton(
              onPressed: _isSaving ? null : () => _handleButtonPress(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 26, 161, 31),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: _isSaving
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('ตกลง', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
