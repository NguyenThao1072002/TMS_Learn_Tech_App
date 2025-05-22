import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tms_app/data/models/document/document_model.dart';

class DocumentHeader extends StatelessWidget implements PreferredSizeWidget {
  final DocumentModel document;
  final VoidCallback onBackPressed;

  const DocumentHeader({
    Key? key,
    required this.document,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onBackPressed,
      ),
      title: const Text(
        'Chi tiết',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      actions: [
    
        ShareCopyWidget(document: document),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ShareCopyWidget extends StatelessWidget {
  final DocumentModel document;
  
  const ShareCopyWidget({
    Key? key,
    required this.document,
  }) : super(key: key);

  void _handleShare(BuildContext context) async {
    try {
      // Chia sẻ link tài liệu
      final url = 'http://tmslearntech.io.vn/documents/${document.id}';
      await Share.share(
        'Xem tài liệu "${document.title}" tại: $url',
        subject: 'Chia sẻ tài liệu từ TMS Learn Tech',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chia sẻ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleCopy(BuildContext context) async {
    try {
      final url = 'http://tmslearntech.io.vn/documents/${document.id}';
      await Clipboard.setData(ClipboardData(text: url));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép liên kết vào clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi sao chép: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          tooltip: 'Chia sẻ',
          onPressed: () => _handleShare(context),
        ),
        IconButton(
          icon: const Icon(Icons.content_copy, color: Colors.black),
          tooltip: 'Sao chép liên kết',
          onPressed: () => _handleCopy(context),
        ),
      ],
    );
  }
}
