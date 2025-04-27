import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class CertificateScreen extends StatefulWidget {
  final String userName;
  final String courseName;
  final String completionDate;
  final String certificateId;

  const CertificateScreen({
    Key? key,
    required this.userName,
    required this.courseName,
    required this.completionDate,
    required this.certificateId,
  }) : super(key: key);

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final GlobalKey _certificateKey = GlobalKey();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chứng chỉ khóa học",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: _shareCertificate,
            tooltip: 'Chia sẻ chứng chỉ',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCertificatePreview(),
                  const SizedBox(height: 24),
                  _buildVerificationInfo(),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildCertificatePreview() {
    return RepaintBoundary(
      key: _certificateKey,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Mẫu họa tiết nền
            Positioned.fill(
              child: CustomPaint(
                painter: CertificateBackgroundPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school,
                          size: 36,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tiêu đề
                  const Text(
                    "CHỨNG CHỈ HOÀN THÀNH",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 2,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),

                  // Nội dung
                  const Text(
                    "Chứng nhận",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tên người học
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Serif',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Nội dung tiếp
                  const Text(
                    "đã hoàn thành xuất sắc khóa học",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tên khóa học
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.courseName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ngày cấp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Ngày ${widget.completionDate}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 100,
                            height: 1,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Ngày cấp",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/signature.png',
                            height: 50,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback khi không tìm thấy hình ảnh
                              return const Text(
                                "Nguyễn Văn A",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 100,
                            height: 1,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Giám đốc đào tạo",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Mã chứng chỉ
                  Text(
                    "Mã chứng chỉ: ${widget.certificateId}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Watermark
            Positioned(
              bottom: 50,
              right: 30,
              child: Opacity(
                opacity: 0.1,
                child: Transform.rotate(
                  angle: -pi / 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "TMS",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Thông tin xác thực",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow("Người học:", widget.userName),
            _buildInfoRow("Khóa học:", widget.courseName),
            _buildInfoRow("Ngày cấp:", widget.completionDate),
            _buildInfoRow("Mã chứng chỉ:", widget.certificateId),
            const SizedBox(height: 16),
            const Text(
              "Chứng chỉ có thể được xác thực trực tuyến tại website tms.edu.vn/verify",
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _openPdfPreview,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Xem PDF"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _downloadCertificate,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download),
              label: const Text("Tải xuống"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareCertificate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final RenderRepaintBoundary boundary = _certificateKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final directory = await getTemporaryDirectory();
        final fileName = 'certificate_${widget.certificateId}.png';
        final file = File('${directory.path}/$fileName');

        await file.writeAsBytes(byteData.buffer.asUint8List());

        // Chia sẻ file
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Chứng chỉ hoàn thành khóa học "${widget.courseName}" của ${widget.userName}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chia sẻ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadCertificate() async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      setState(() {
        _isSaving = true;
      });

      try {
        final RenderRepaintBoundary boundary = _certificateKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName =
              'TMS_Certificate_${DateFormat('yyyyMMdd').format(DateTime.now())}.png';
          final file = File('${directory.path}/$fileName');

          await file.writeAsBytes(byteData.buffer.asUint8List());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã tải chứng chỉ vào: ${file.path}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Đóng',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cần cấp quyền truy cập bộ nhớ để lưu chứng chỉ'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _openPdfPreview() {
    // Chức năng xem PDF có thể được thêm vào sau này
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng xem PDF đang được phát triển'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class CertificateBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Vẽ các hình trang trí nền
    for (int i = 0; i < 20; i++) {
      final random = Random();
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 5.0 + random.nextDouble() * 15;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Vẽ đường viền trang trí
    final borderPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(15, 15, size.width - 30, size.height - 30);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    canvas.drawRRect(rRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// Lớp để tạo chứng chỉ tự động từ thông tin khóa học và người dùng
class CertificateGenerator {
  static Future<void> generateAndShow(
    BuildContext context, {
    required String userName,
    required String courseName,
    required dynamic completion,
  }) async {
    // Convert completion to double if needed
    final double completionValue =
        completion is int ? completion.toDouble() : completion;

    // Chỉ tạo chứng chỉ nếu hoàn thành 100%
    if (completionValue < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần hoàn thành 100% khóa học để nhận chứng chỉ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Tạo mã chứng chỉ ngẫu nhiên
    final certificateId =
        'TMS-${DateTime.now().year}-${_generateRandomString(6)}';
    final completionDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Hiển thị màn hình chứng chỉ
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CertificateScreen(
          userName: userName,
          courseName: courseName,
          completionDate: completionDate,
          certificateId: certificateId,
        ),
      ),
    );
  }

  // Hàm tạo chuỗi ngẫu nhiên cho mã chứng chỉ
  static String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
