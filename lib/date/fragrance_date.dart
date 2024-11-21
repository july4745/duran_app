import 'package:flutter/material.dart';
import 'fragrance_result.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class FragranceDate extends StatefulWidget {
  @override
  _FragranceDateState createState() => _FragranceDateState();
}

class _FragranceDateState extends State<FragranceDate> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _harvestDateController = TextEditingController();

  final FocusNode _weightFocusNode = FocusNode();
  final FocusNode _diameterFocusNode = FocusNode();
  final FocusNode _lengthFocusNode = FocusNode();
  final FocusNode _harvestDateFocusNode = FocusNode();

  DateTime? _harvestDate;

  // Define a database variable (assuming you're using SQLite for local storage)
  late Database db;

  @override
  void dispose() {
    _weightController.dispose();
    _diameterController.dispose();
    _lengthController.dispose();
    _harvestDateController.dispose();
    _weightFocusNode.dispose();
    _diameterFocusNode.dispose();
    _lengthFocusNode.dispose();
    _harvestDateFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label, FocusNode focusNode) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color:
            focusNode.hasFocus ? Color.fromARGB(255, 26, 161, 31) : Colors.grey,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 26, 161, 31),
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 227, 154),
        title: Text(
          'วันที่เริ่มได้กลิ่น',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      //Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เริ่มกรอกข้อมูลเพื่อคำนวณ',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),

              //ฟิลด์ที่ 1
              TextField(
                controller: _harvestDateController,
                readOnly: true,
                focusNode: _harvestDateFocusNode,
                decoration: InputDecoration(
                  labelText: 'วันที่เก็บทุเรียน',
                  labelStyle: TextStyle(
                    color: _harvestDateFocusNode.hasFocus
                        ? Color.fromARGB(255, 26, 161, 31)
                        : Colors.grey,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 26, 161, 31),
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2101),
                    locale: const Locale("th", "TH"),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Color.fromARGB(255, 26, 161, 31),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _harvestDate = pickedDate;
                      int buddhistYear = pickedDate.year + 543;
                      _harvestDateController.text =
                          DateFormat('dd/MM/$buddhistYear').format(pickedDate);
                      FocusScope.of(context).unfocus();
                    });
                  }
                },
                style: TextStyle(
                  color: _harvestDateFocusNode.hasFocus
                      ? Color.fromARGB(255, 26, 161, 31)
                      : Colors.black,
                ),
              ),
              SizedBox(height: 30),

              //ฟิลด์ที่ 2
              TextField(
                controller: _weightController,
                focusNode: _weightFocusNode,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration(
                    'น้ำหนักทุเรียน (กิโลกรัม)', _weightFocusNode),
                style: TextStyle(
                  color: _weightFocusNode.hasFocus
                      ? Color.fromARGB(255, 26, 161, 31)
                      : Colors.black,
                ),
              ),
              SizedBox(height: 30),

              //ฟิลด์ที่ 3
              TextField(
                controller: _lengthController,
                focusNode: _lengthFocusNode,
                keyboardType: TextInputType.number,
                decoration:
                    _buildInputDecoration('ความยาวผล (ซม.)', _lengthFocusNode),
                style: TextStyle(
                  color: _lengthFocusNode.hasFocus
                      ? Color.fromARGB(255, 26, 161, 31)
                      : Colors.black,
                ),
              ),
              SizedBox(height: 30),

              //ฟิลด์ที่ 4
              TextField(
                controller: _diameterController,
                focusNode: _diameterFocusNode,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration(
                    'เส้นผ่านศูนย์กลางผล (ซม.)', _diameterFocusNode),
                style: TextStyle(
                  color: _diameterFocusNode.hasFocus
                      ? Color.fromARGB(255, 26, 161, 31)
                      : Colors.black,
                ),
              ),
              SizedBox(height: 30),

              //เช็คว่าเลือกวันที่เก็บทุเรียน
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_harvestDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('กรุณาเลือกวันที่เก็บทุเรียน'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      _calculateFragranceDate();
                    }
                  },

                  //ปุ่มคำนวณ
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 26, 161, 31),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Text('คำนวณ', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateScentDays(
      double weight, double length, double diameter) {
    int score = 0;

    // ให้คะแนนตามน้ำหนัก
    if (weight < 2.5) {
      score += 1;
    } else if (weight >= 2.5 && weight <= 3.2) {
      score += 2;
    } else if (weight > 3.2) {
      score += 3;
    }

    // ความยาว
    if (length < 20) {
      score += 1;
    } else if (length >= 20 && length <= 23) {
      score += 2;
    } else if (length > 23) {
      score += 3;
    }

    // เส้นผ่าศูนย์กลาง
    if (diameter < 15) {
      score += 1;
    } else if (diameter >= 15 && diameter <= 17) {
      score += 2;
    } else if (diameter > 17) {
      score += 3;
    }

    if (score <= 3) {
      return {'days': 7, 'range': '7 วันขึ้นไป'};
    } else if (score <= 5) {
      return {'days': 4, 'range': '4-6 วัน'};
    } else if (score <= 9) {
      return {'days': 1, 'range': '1-3 วัน'};
    } else {
      return {'days': -1, 'range': 'ไม่ตรงตามเงื่อนไข'};
    }
  }

  void _calculateFragranceDate() {
    final String weightText = _weightController.text.trim();
    final String lengthText = _lengthController.text.trim();
    final String diameterText = _diameterController.text.trim();

    // ตรวจสอบว่าข้อมูลถูกกรอกครบทุกช่อง
    if (weightText.isNotEmpty &&
        lengthText.isNotEmpty &&
        diameterText.isNotEmpty &&
        _harvestDate != null) {
      // แปลงค่าจาก String เป็น double
      final double? weight = double.tryParse(weightText);
      final double? length = double.tryParse(lengthText);
      final double? diameter = double.tryParse(diameterText);

      // ตรวจสอบว่าข้อมูลที่แปลงแล้วไม่เป็น null และมากกว่า 0
      if (weight != null &&
          weight > 0 &&
          length != null &&
          length > 0 &&
          diameter != null &&
          diameter > 0) {
        final result = _calculateScentDays(weight, length, diameter);

        // แปลงวันที่เป็น "dd/MM/yyyy"
        String formattedHarvestDate =
            DateFormat('dd/MM/yyyy').format(_harvestDate!);
        String formattedFragranceDate =
            DateFormat('dd/MM/yyyy').format(DateTime.now());

        // แสดงผลในหน้า FragranceResult
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FragranceResult(
              scentRange: result['range'],
              // แปลงเป็น String พร้อมทศนิยม 2 หลัก
              weight: weight.toStringAsFixed(2),
              length: length.toStringAsFixed(2),
              diameter: diameter.toStringAsFixed(2),
              harvestDate: formattedHarvestDate,
              fragranceDate: formattedFragranceDate,
              timestamp: DateTime.now().toIso8601String(),
            ),
          ),
        );
      } else {
        // แสดงข้อความแจ้งเมื่อข้อมูลไม่ถูกต้อง
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('กรุณากรอกข้อมูลให้ถูกต้อง'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // ถ้ายังกรอกไม่ครบทุกช่อง
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
