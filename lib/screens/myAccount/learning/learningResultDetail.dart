import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tms/models/course.dart';
import 'package:tms/models/testResult.dart';

class LearningResultDetail extends StatefulWidget {
  final Course course;
  const LearningResultDetail({required this.course});

  @override
  _LearningResultDetailState createState() => _LearningResultDetailState();
}

class _LearningResultDetailState extends State<LearningResultDetail> {
  String selectedFilter = "Toàn khóa";
  late _TestResultsDataSource _dataSource;
  int _rowsPerPage = 10;
  final ScrollController _scrollController = ScrollController();
  final dateFormat = DateFormat("dd/MM/yyyy");
  @override
  void initState() {
    super.initState();
    _dataSource = _TestResultsDataSource(widget.course.results);
  }

  @override
  Widget build(BuildContext context) {
    double averageScore =
        widget.course.results.fold(0, (sum, item) => sum + item.score) /
            widget.course.results.length;
    int passedTests =
        widget.course.results.where((result) => result.result == "Pass").length;
    double passRate = (passedTests / widget.course.results.length) * 100;

    return Scaffold(
      appBar: AppBar(title: Text(widget.course.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Tổng quan
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tiến độ học tập",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: widget.course.progress / 100,
                        color: Colors.blue,
                        backgroundColor: Colors.grey[300],
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      SizedBox(height: 10),
                      Text("${widget.course.progress.toInt()}% hoàn thành"),
                      SizedBox(height: 10),
                      Text(
                        "Điểm trung bình: ${averageScore.toStringAsFixed(1)}",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Tỷ lệ bài kiểm tra đạt: ${passRate.toStringAsFixed(1)}%",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("Biểu đồ điểm số",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedFilter,
                items: ["Bài học", "Chương", "Toàn khóa"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedFilter = newValue!;
                  });
                },
              ),
              SizedBox(height: 10),
              Container(
                height: 180,
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(),
                      bottomTitles: AxisTitles(),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: widget.course.results
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                e.key.toDouble(), e.value.score.toDouble()))
                            .toList(),
                        isCurved: true,
                        barWidth: 4,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Tư vấn kết quả học tập"),
                        content: Text(
                            "Dựa trên kết quả của bạn, chúng tôi khuyên bạn nên ôn lại những bài chưa đạt và tham gia thêm các khóa nâng cao để cải thiện kỹ năng."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Đóng"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text("Tư vấn"),
              ),
              SizedBox(height: 20),     
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    // Tiêu đề
                    Text("Danh sách bài kiểm tra",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    // Bảng hiển thị kết quả
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cột cố định (STT & Tên bài kiểm tra)
                        Container(
                          width: 250,
                          color: Colors.white,
                          child: DataTable(
                            headingRowHeight: 50,
                            dataRowHeight: 45,
                            columns: [
                              DataColumn(label: Text("STT")),
                              DataColumn(label: Text("Bài kiểm tra")),
                            ],
                            rows: List.generate(widget.course.results.length,
                                (index) {
                              final result = widget.course.results[index];
                              return DataRow(
                                cells: [
                                  DataCell(Text("${index + 1}")), // STT (Ghim)
                                  DataCell(Text(
                                      result.title)), // Tên bài kiểm tra (Ghim)
                                ],
                              );
                            }),
                          ),
                        ),
                        // Các cột còn lại có thể cuộn ngang
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            child: DataTable(
                              columnSpacing: 20,
                              headingRowHeight: 50,
                              dataRowHeight: 45,
                              columns: [
                                DataColumn(label: Text("Điểm")),
                                DataColumn(label: Text("Trạng thái")),
                                DataColumn(label: Text("Ngày làm")),
                                DataColumn(label: Text("Tỉ lệ đúng")),
                              ],
                              rows: List.generate(widget.course.results.length,
                                  (index) {
                                final result = widget.course.results[index];
                                return DataRow(
                                  cells: [
                                    DataCell(Text(result.score.toString())),
                                    DataCell(Text(
                                        result.result == "Pass" ? "✅" : "❌")),
                                    DataCell(
                                        Text(dateFormat.format(result.date))),
                                    DataCell(Text(
                                        "${result.correctAnswers}/${result.totalQuestions}")),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// DataSource cho bảng phân trang
class _TestResultsDataSource extends DataTableSource {
  final List<TestResult> results;
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy");

  _TestResultsDataSource(this.results);

  @override
  DataRow getRow(int index) {
    if (index >= results.length) return null!;

    final result = results[index];

    return DataRow(cells: [
      DataCell(Text("${index + 1}")), // STT
      DataCell(Text(result.title)), // Bài kiểm tra
      DataCell(Text(result.score.toString())), // Điểm
      DataCell(Text(result.result == "Pass" ? "✅" : "❌")), // Trạng thái
      DataCell(Text(dateFormat.format(result.date))), // Ngày làm
      DataCell(Text(
          "${result.correctAnswers}/${result.totalQuestions}")), // Tỉ lệ đúng
    ]);
  }

  @override
  int get rowCount => results.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
