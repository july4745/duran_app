import 'package:app/database/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FragranceResult extends StatefulWidget {
  final String fragranceDate;
  final String scentRange;
  final String weight;
  final String diameter;
  final String length;
  final String harvestDate;
  final String timestamp;

  const FragranceResult({
    required this.fragranceDate,
    required this.scentRange,
    required this.timestamp,
    required this.weight,
    required this.diameter,
    required this.length,
    required this.harvestDate,
  });

  // ฟังก์ชันแปลงเป็น พ.ศ.
  String formatFragranceDateToBuddhistEra(String fragranceDate) {
    try {
      // ตัวอย่างการแปลงจากวันที่ในรูปแบบ dd/MM/yyyy
      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(fragranceDate);

      // แปลงปี ค.ศ. เป็น พ.ศ. โดยการเพิ่ม 543 ปี
      int buddhistYear = parsedDate.year + 543;

      // กำหนดรูปแบบของวันที่ที่จะแสดง
      String displayDate = DateFormat('dd/MM').format(parsedDate);

      return '$displayDate/$buddhistYear';
    } catch (e) {
      return 'วันที่ไม่ถูกต้อง'; // กรณีที่แปลงไม่ได้
    }
  }

  // ฟังก์ชันคำนวณวันที่ทุเรียนจะเริ่มมีกลิ่นจากวันที่เก็บเกี่ยวและระยะเวลา scentRange
  String calculateFragranceDate() {
    try {
      // แปลงวันที่เก็บเกี่ยวจาก String เป็น DateTime
      DateTime harvestDateParsed = DateFormat('dd/MM/yyyy').parse(harvestDate);

      if (scentRange.contains('-')) {
        List<String> range = scentRange.split('-');
        int scentDaysMin =
            int.tryParse(range[0].replaceAll(RegExp(r'\D'), '')) ?? 0;
        int scentDaysMax =
            int.tryParse(range[1].replaceAll(RegExp(r'\D'), '')) ?? 0;

        int scentDays;
        if (scentDaysMin >= 1 && scentDaysMin <= 3) {
          scentDays = 1;
        } else if (scentDaysMin >= 4 && scentDaysMin <= 6) {
          scentDays = 4;
        } else {
          scentDays = (scentDaysMin + scentDaysMax) ~/ 2;
        }

        DateTime fragranceDate =
            harvestDateParsed.add(Duration(days: scentDays));
        return DateFormat('dd/MM/yyyy').format(fragranceDate);
      } else {
        int scentDays =
            int.tryParse(scentRange.replaceAll(RegExp(r'\D'), '')) ?? 0;
        DateTime fragranceDate =
            harvestDateParsed.add(Duration(days: scentDays));
        return DateFormat('dd/MM/yyyy').format(fragranceDate);
      }
    } catch (e) {
      return 'วันที่ไม่ถูกต้อง';
    }
  }

  // แปลงข้อมูลจากฐานข้อมูลเป็น FragranceResult
  factory FragranceResult.fromMap(Map<String, dynamic> map) {
    return FragranceResult(
      fragranceDate: map['fragrance_date'],
      scentRange: map['scent_range'],
      timestamp: map['timestamp'],
      weight: map['weight'],
      diameter: map['diameter'],
      length: map['length'],
      harvestDate: map['harvestDate'],
    );
  }

  // แปลง FragranceResult กลับเป็นข้อมูลที่สามารถบันทึกในฐานข้อมูล
  Map<String, dynamic> toMap() {
    return {
      'fragrance_date': fragranceDate,
      'scent_range': scentRange,
      'timestamp': timestamp,
      'weight': weight,
      'diameter': diameter,
      'length': length,
      'harvestDate': harvestDate,
    };
  }

  @override
  _FragranceResultState createState() => _FragranceResultState();
}

class _FragranceResultState extends State<FragranceResult> {
  // ฟังก์ชันบันทึกการคำนวณลงในฐานข้อมูล
  Future<void> saveFragranceResult() async {
    final db = await DatabaseHelper().db;

    // คำนวณ fragranceDate
    String fragranceDate = widget.calculateFragranceDate();

    // กำหนด timestamp
    String timestampValue = widget.timestamp.isEmpty
        ? DateTime.now().toIso8601String()
        : widget.timestamp;

    try {
      // ใช้ fragranceDate ที่คำนวณแล้วในการบันทึกลงฐานข้อมูล
      await db.insert('fragrance_results', {
        'fragrance_date': fragranceDate,
        'scent_range': widget.scentRange,
        'timestamp': timestampValue,
        'weight': widget.weight,
        'diameter': widget.diameter,
        'length': widget.length,
        'harvestDate': widget.harvestDate,
      });
    } catch (e) {
      print("เกิดข้อผิดพลาด: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String calculatedFragranceDate = widget.calculateFragranceDate();
    return Scaffold(
      appBar: AppBar(
        title: Text('ผลลัพธ์การคำนวณ'),
        backgroundColor: const Color.fromARGB(255, 151, 227, 154),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 0), // ช่องว่างด้านล่างรูป
              child: Image.asset(
                'assets/durian.png',
                width: 150,
                height: 150,
              ),
            ),

            // ใช้ตัวแปร fragranceDate และ scentRange ที่ได้รับจากคอนสตรัคเตอร์
            //ฟิลด์ที่ 1
            Text(
              'วันที่ทุเรียนจะเริ่มมีกลิ่น: ${widget.formatFragranceDateToBuddhistEra(calculatedFragranceDate)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            //ฟิลด์ที่ 2
            Text(
              '(ระยะเวลา ${widget.scentRange} จะเริ่มมีกลิ่น)',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // ช่องว่างระหว่างข้อความและปุ่ม
            ElevatedButton(
              onPressed: () async {
                try {
                  await saveFragranceResult();
                  // print("ข้อมูลบันทึกสำเร็จ");

                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                  // print("หน้าเปลี่ยนเรียบร้อยแล้ว");
                } catch (e) {
                  // print("เกิดข้อผิดพลาด: $e");
                }
              },

              //ปุ่ม
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 26, 161, 31),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Text('ตกลง', style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
