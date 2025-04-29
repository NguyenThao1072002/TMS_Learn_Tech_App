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
      backgroundColor: Colors.white,
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        constraints: const BoxConstraints(
          maxHeight: 450,
          maxWidth: 320,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: LuxuryCertificateBackgroundPainter(),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Logo and header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school,
                          size: 22,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TMS LEARN TECH",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade600,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                  color: Colors.blue.shade200.withOpacity(0.5),
                                  offset: const Offset(0, 1),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade300,
                                  Colors.purple.shade200,
                                  Colors.blue.shade300,
                                ],
                              ),
                            ),
                          ),
                          Text(
                            "ACADEMY",
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: Colors.blue.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Certificate title
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.blue.shade500,
                        Colors.blue.shade700,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "CHỨNG CHỈ HOÀN THÀNH",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "CERTIFICATE OF COMPLETION",
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: Colors.blue.shade400,
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 80,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.amber.shade200,
                          Colors.amber.shade400,
                          Colors.amber.shade200,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Certification text
                  Text(
                    "CHỨNG NHẬN",
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Student name with embossed effect
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Shadow text for embossed effect
                        Text(
                          widget.userName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.06),
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // Main text
                        Positioned(
                          left: 0,
                          right: 0,
                          top: -1,
                          child: Text(
                            widget.userName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Completion text
                  const Text(
                    "ĐÃ HOÀN THÀNH XUẤT SẮC KHÓA HỌC",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Course name
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade50,
                          Colors.blue.shade100.withOpacity(0.3),
                          Colors.blue.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.courseName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(),

                  // Bottom section - 2 columns
                  Row(
                    children: [
                      // Left column - Signature and date
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "GS. Nguyễn Văn A",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 3, bottom: 3),
                              width: 80,
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade400,
                                    Colors.grey.shade600,
                                    Colors.grey.shade400,
                                  ],
                                ),
                              ),
                            ),
                            const Text(
                              "GIÁM ĐỐC ĐÀO TẠO",
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Date moved here
                            Text(
                              widget.completionDate,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Right column - QR code only
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // QR code
                            Center(
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: QRCodePainter(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Certificate ID
                  Text(
                    "ID: ${widget.certificateId}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
      shadowColor: Colors.blue.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.greenAccent.shade100, Colors.green],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.verified, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "THÔNG TIN ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextSpan(
                        text: "XÁC THỰC",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow("Người học:", widget.userName, Icons.person),
                  _buildInfoRow("Khóa học:", widget.courseName, Icons.school),
                  _buildInfoRow(
                      "Ngày cấp:", widget.completionDate, Icons.calendar_today),
                  _buildInfoRow(
                      "Mã chứng chỉ:", widget.certificateId, Icons.qr_code),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.security,
                    size: 18,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Chứng chỉ có thể được xác thực trực tuyến tại website tms.edu.vn/verify",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 14,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
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
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _openPdfPreview,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Xem PDF"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue.shade700,
                elevation: 2,
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
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 2,
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

class LuxuryCertificateBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ nền trắng cơ bản trước
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Thêm màu loang nhẹ nhàng
    _drawGentleColorBlend(canvas, size);

    // Thêm vân nhẹ
    _drawSubtleTexture(canvas, size);

    // Elegant border with golden gradient effect
    final borderGradient = LinearGradient(
      colors: [
        Colors.amber.shade100,
        Colors.amber.shade200,
        Colors.amber.shade300,
        Colors.amber.shade200,
        Colors.amber.shade100,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final borderPaint = Paint()
      ..shader = borderGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final borderRect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    final borderRRect =
        RRect.fromRectAndRadius(borderRect, const Radius.circular(16));
    canvas.drawRRect(borderRRect, borderPaint);

    // Draw inner border
    final innerBorderRect =
        Rect.fromLTWH(15, 15, size.width - 30, size.height - 30);
    final innerBorderRRect =
        RRect.fromRectAndRadius(innerBorderRect, const Radius.circular(14));

    final innerBorderPaint = Paint()
      ..color = Colors.amber.shade50
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawRRect(innerBorderRRect, innerBorderPaint);
  }

  // Hàm tạo màu loang nhẹ nhàng
  void _drawGentleColorBlend(Canvas canvas, Size size) {
    final random = Random(15); // Seed cố định để kết quả nhất quán

    // Tạo màu loang ở các góc
    void drawColorSpot(
        double centerX, double centerY, Color baseColor, double radius) {
      final gradient = RadialGradient(
        colors: [
          baseColor,
          baseColor.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: radius,
      ));

      final paint = Paint()
        ..shader = gradient
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    }

    // Vẽ các vùng màu loang ở các vị trí khác nhau
    // Góc trên bên trái - màu xanh nhạt
    drawColorSpot(
        0, 0, Colors.blue.shade100.withOpacity(0.15), size.width * 0.4);

    // Góc dưới bên phải - màu vàng nhạt
    drawColorSpot(size.width, size.height,
        Colors.amber.shade100.withOpacity(0.1), size.width * 0.5);

    // Góc trên bên phải - màu tím nhạt
    drawColorSpot(size.width, 0, Colors.purple.shade50.withOpacity(0.08),
        size.width * 0.3);

    // Thêm một số điểm màu ngẫu nhiên
    for (int i = 0; i < 3; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Chọn màu nhẹ ngẫu nhiên
      Color color;
      final colorChoice = random.nextInt(3);

      if (colorChoice == 0) {
        color = Colors.blue.shade50.withOpacity(0.08);
      } else if (colorChoice == 1) {
        color = Colors.amber.shade50.withOpacity(0.07);
      } else {
        color = Colors.purple.shade50.withOpacity(0.06);
      }

      drawColorSpot(x, y, color, 40 + random.nextDouble() * 80);
    }
  }

  // Hàm tạo vân nhẹ
  void _drawSubtleTexture(Canvas canvas, Size size) {
    final random = Random(20); // Seed cố định

    // Vẽ các đường vân nhẹ
    final texturePaint = Paint()
      ..color = Colors.grey.shade200.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);

    // Vẽ các đường ngang mờ
    for (int i = 0; i < 20; i++) {
      final y = random.nextDouble() * size.height;
      final path = Path();
      path.moveTo(0, y);

      // Tạo đường cong nhẹ
      double x = 0;
      while (x < size.width) {
        final controlX1 = x + random.nextDouble() * 30 + 10;
        final controlY1 = y + (random.nextDouble() * 4 - 2);
        final controlX2 = controlX1 + random.nextDouble() * 30 + 10;
        final controlY2 = y + (random.nextDouble() * 4 - 2);
        final endX = controlX2 + random.nextDouble() * 30 + 10;
        final endY = y + (random.nextDouble() * 2 - 1);

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
        x = endX;
      }

      canvas.drawPath(path, texturePaint);
    }

    // Vẽ một số đường dọc mờ
    for (int i = 0; i < 10; i++) {
      final x = random.nextDouble() * size.width;
      final path = Path();
      path.moveTo(x, 0);

      // Tạo đường cong nhẹ
      double y = 0;
      while (y < size.height) {
        final controlX1 = x + (random.nextDouble() * 4 - 2);
        final controlY1 = y + random.nextDouble() * 40 + 20;
        final controlX2 = x + (random.nextDouble() * 4 - 2);
        final controlY2 = controlY1 + random.nextDouble() * 40 + 20;
        final endX = x + (random.nextDouble() * 2 - 1);
        final endY = controlY2 + random.nextDouble() * 40 + 20;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
        y = endY;
      }

      canvas.drawPath(path, texturePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final double cellSize = size.width / 16;

    // Vẽ mẫu QR code giả
    List<List<int>> pattern = [
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0],
      [0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1],
      [1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0],
      [1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0],
    ];

    // Vẽ các ô vuông dựa trên mẫu
    for (int y = 0; y < pattern.length; y++) {
      for (int x = 0; x < pattern[y].length; x++) {
        if (pattern[y][x] == 1) {
          final rect = Rect.fromLTWH(
            x * cellSize * 0.8,
            y * cellSize * 0.8,
            cellSize * 0.8,
            cellSize * 0.8,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }

    // Vẽ 3 khối định vị góc QR
    const positions = [
      [0, 0], // Góc trên bên trái
      [0, 12], // Góc dưới bên trái
      [12, 0], // Góc trên bên phải
    ];

    for (final pos in positions) {
      final x = pos[0] * cellSize;
      final y = pos[1] * cellSize;

      // Vẽ hình vuông ngoài
      canvas.drawRect(
        Rect.fromLTWH(x, y, cellSize * 4, cellSize * 4),
        paint,
      );

      // Vẽ hình vuông trong (màu trắng)
      final whitePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 2, cellSize * 2),
        whitePaint,
      );

      // Vẽ hình vuông giữa (màu đen)
      canvas.drawRect(
        Rect.fromLTWH(
            x + cellSize * 1.5, y + cellSize * 1.5, cellSize, cellSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

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
