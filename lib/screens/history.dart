import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
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

  factory Durian.fromMap(Map<String, dynamic> map) {
    return Durian(
      imagePath: map['image_path'],
      ripenessLevel: map['ripeness_level'],
      timestamp: map['timestamp'],
    );
  }
}

class FragranceResult {
  final String fragranceDate;
  final String scentRange;
  final double weight;
  final double diameter;
  final double length;
  final String harvestDate;
  final String timestamp;

  FragranceResult({
    required this.fragranceDate,
    required this.scentRange,
    required this.weight,
    required this.diameter,
    required this.length,
    required this.harvestDate,
    required this.timestamp,
  });

  factory FragranceResult.fromMap(Map<String, dynamic> map) {
    return FragranceResult(
      fragranceDate: map['fragrance_date'] ?? '',
      scentRange: map['scent_range'] ?? '',
      timestamp: map['timestamp'] ?? '',
      weight: (map['weight'] != null) ? map['weight'] as double : 0.0,
      diameter: (map['diameter'] != null) ? map['diameter'] as double : 0.0,
      length: (map['length'] != null) ? map['length'] as double : 0.0,
      harvestDate: map['harvestDate'] ?? '',
    );
  }
}

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> with TickerProviderStateMixin {
  late Future<List<Durian>> _durianListFuture;
  late Future<List<FragranceResult>> _fragranceListFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _durianListFuture = _fetchDurianData();
    _fragranceListFuture = _fetchFragranceData();
    _deleteOldRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteOldRecords() async {
    final db = await DatabaseHelper().db;
    try {
      // คำนวณ 3 เดือนที่แล้ว
      final threeMonthsAgo = DateTime.now().subtract(Duration(days: 90));
      final String formattedDate =
          DateFormat('yyyy-MM-dd').format(threeMonthsAgo);

      // ลบข้อมูลในตาราง ripeness_results
      await db.delete('ripeness_results',
          where: 'timestamp < ?', whereArgs: [formattedDate]);

      // ลบข้อมูลในตาราง fragrance_results
      await db.delete('fragrance_results',
          where: 'timestamp < ?', whereArgs: [formattedDate]);

      //print('ลบข้อมูลที่เก่ากว่า 3 เดือนไปแล้ว');
    } catch (e) {
      //print('เกิดข้อผิดพลาดในการลบข้อมูลเก่า: $e');
    }
  }

  Future<List<Durian>> _fetchDurianData() async {
    try {
      final db = await DatabaseHelper().db;
      final List<Map<String, dynamic>> data =
          await db.query('ripeness_results');
      List<Durian> durianList =
          data.map((item) => Durian.fromMap(item)).toList();
      durianList.sort((a, b) {
        DateTime dateA = DateTime.parse(a.timestamp);
        DateTime dateB = DateTime.parse(b.timestamp);
        return dateB.compareTo(dateA);
      });
      return durianList;
    } catch (e) {
      print('Error fetching Durian data: $e');
      return [];
    }
  }

  Future<List<FragranceResult>> _fetchFragranceData() async {
    final db = await DatabaseHelper().db;
    try {
      final List<Map<String, dynamic>> maps =
          await db.query('fragrance_results');

      if (maps.isEmpty) {
        return [];
      }

      return List.generate(maps.length, (i) {
        return FragranceResult.fromMap(maps[i]);
      });
    } catch (e) {
      print("Error fetching fragrance data: $e");
      return [];
    }
  }

  //วันที่เริ่มได้กลิ่น
  String convertToBuddhistYear(String date) {
    try {
      // ใช้ DateFormat ในการแปลงวันที่จากรูปแบบที่กำหนด
      DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(date, true);
      int buddhistYear = parsedDate.year + 543;
      String formattedDate =
          "${parsedDate.day}/${parsedDate.month}/$buddhistYear"; // กำหนดรูปแบบวันที่
      return formattedDate;
    } catch (e) {
      return 'วันที่ไม่ถูกต้อง';
    }
  }

  String convertDateToBuddhistEra(String date) {
    List<String> dateParts = date.split('/');

    if (dateParts.length == 3) {
      String reformattedDate =
          '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

      DateTime parsedDate = DateTime.parse(reformattedDate);

      int buddhistYear = parsedDate.year + 543;

      return '${parsedDate.day}/${parsedDate.month}/$buddhistYear';
    } else {
      return 'Invalid date format';
    }
  }

  String _getDateLabel(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return 'ไม่มีเวลา';
    }

    DateTime? date;
    try {
      date = DateTime.tryParse(timestamp);
      if (date == null) {
        return 'วันที่ไม่ถูกต้อง';
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
      return 'วันที่ไม่ถูกต้อง';
    }

    DateTime now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${DateFormat.Hm().format(date)}';
    } else {
      return convertToBuddhistYear(timestamp);
    }
  }

  // ฟังก์ชันแปลงค.ศ.เป็น พ.ศ.
  String formatFragranceDateToBuddhistEra(String fragranceDate) {
    try {
      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(fragranceDate);
      int buddhistYear = parsedDate.year + 543;
      String displayDate = DateFormat('dd/MM').format(parsedDate);
      return '$displayDate/$buddhistYear';
    } catch (e) {
      return 'วันที่ไม่ถูกต้อง';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('รายการล่าสุด', style: TextStyle(fontSize: 22)),
          backgroundColor: Color.fromARGB(255, 151, 227, 154),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'ระดับความสุก'),
              Tab(text: 'วันที่ได้กลิ่น'),
            ],
            labelColor: Color.fromARGB(255, 26, 161, 31),
            unselectedLabelColor: Colors.black,
            indicatorColor: Color.fromARGB(255, 26, 161, 31),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 18),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 151, 227, 154),
        body: TabBarView(controller: _tabController, children: [
          //Tab 1
          FutureBuilder<List<Durian>>(
            future: _durianListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('ไม่มีข้อมูลในประวัติการบันทึก'));
              } else {
                var durianList = snapshot.data!;

                return ListView.builder(
                  itemCount: durianList.length,
                  itemBuilder: (context, index) {
                    final durian = durianList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(durian.imagePath)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      _getDateLabel(durian.timestamp),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'ระดับความสุก: ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${durian.ripenessLevel}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),

          //Tab 2
          FutureBuilder<List<FragranceResult>>(
              future: _fragranceListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('ไม่มีข้อมูลการคำนวณวันที่ได้กลิ่น'));
                } else {
                  var fragranceList = snapshot.data!;

                  // เรียงข้อมูลตาม timestamp จากใหม่ไปเก่า
                  fragranceList.sort((a, b) {
                    DateTime dateA =
                        DateTime.tryParse(a.timestamp) ?? DateTime.now();
                    DateTime dateB =
                        DateTime.tryParse(b.timestamp) ?? DateTime.now();
                    return dateB.compareTo(dateA); // เรียงจากใหม่ไปเก่า
                  });

                  return ListView.builder(
                    itemCount: fragranceList.length,
                    itemBuilder: (context, index) {
                      final fragrance =
                          fragranceList[index]; // ใช้ fragrance ที่ถูกกำหนดไว้
                      String displayDate = '';
                      try {
                        if (fragrance.timestamp.isNotEmpty) {
                          displayDate = _getDateLabel(fragrance.timestamp);
                        } else {
                          displayDate = 'ไม่มีเวลา';
                        }
                      } catch (e) {
                        displayDate = 'วันที่ไม่ถูกต้อง';
                      }

                      return Container(
                          width: double.infinity,
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icon-durian.png',
                                      width: 60,
                                      height: 60,
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Text(
                                              displayDate,
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'วันที่เริ่มได้กลิ่น: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      formatFragranceDateToBuddhistEra(
                                                          fragrance
                                                              .fragranceDate),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Color.fromARGB(
                                                          255, 26, 161, 31)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'ระยะเวลา: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      '${fragrance.scentRange} จะเริ่มมีกลิ่น',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color.fromARGB(
                                                          255, 26, 161, 31)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // เพิ่มข้อมูลที่ต้องการแสดงเพิ่มเติม
                                          SizedBox(height: 5),
                                          ExpansionTile(
                                            title: Text(
                                              'ข้อมูลเพิ่มเติม',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            children: <Widget>[
                                              ListTile(
                                                title: Text(
                                                  'น้ำหนัก: ${fragrance.weight} กก.',
                                                  style: TextStyle(
                                                    fontSize:
                                                        16, // ขนาดตัวอักษร
                                                    fontWeight: FontWeight
                                                        .normal, // น้ำหนักตัวอักษรปกติ
                                                    color: Colors
                                                        .black, // สีตัวอักษร
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'เส้นผ่าศูนย์กลาง: ${fragrance.diameter} ซม.',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'ความยาวผล: ${fragrance.length} ซม.',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'วันที่เก็บทุเรียน: ${convertDateToBuddhistEra(fragrance.harvestDate)}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ));
                    },
                  );
                }
              })
        ]));
  }
}
