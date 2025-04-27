import 'package:flutter/material.dart';
import 'package:tms_app/data/models/document_model.dart';

class DocumentItem extends StatefulWidget {
  final DocumentModel document;

  const DocumentItem({Key? key, required this.document}) : super(key: key);

  @override
  State<DocumentItem> createState() => _DocumentItemState();
}

class _DocumentItemState extends State<DocumentItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool isNetworkImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  _buildImage(),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _buildTypeWidget(),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildViewsWidget(),
                  ),
                  if (widget.document.category != null)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: _buildCategoryWidget(),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.document.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: _getDocumentIcon(),
      ),
    );
  }

  Widget _getDocumentIcon() {
    String type = widget.document.type.toLowerCase();
    IconData iconData;
    Color iconColor;

    if (type == 'pdf') {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red.shade400;
    } else if (type == 'excel' || type == 'xls' || type == 'xlsx') {
      iconData = Icons.table_chart;
      iconColor = Colors.green.shade400;
    } else if (type == 'word' || type == 'doc' || type == 'docx') {
      iconData = Icons.article;
      iconColor = Colors.blue.shade400;
    } else if (type == 'ppt' || type == 'pptx') {
      iconData = Icons.slideshow;
      iconColor = Colors.orange.shade400;
    } else {
      iconData = Icons.article;
      iconColor = Colors.grey.shade400;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
        ),
        Icon(
          iconData,
          size: 60,
          color: iconColor,
        ),
      ],
    );
  }

  Widget _buildTypeWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getTypeColor(),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        widget.document.type.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _getCategoryIcon(),
            size: 14,
            color: Colors.grey[800],
          ),
          const SizedBox(width: 4),
          Text(
            widget.document.category!,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    if (widget.document.category == null) return Icons.folder;

    switch (widget.document.category!.toLowerCase()) {
      case 'giáo dục':
        return Icons.school;
      case 'công nghệ':
        return Icons.computer;
      case 'kinh tế':
        return Icons.attach_money;
      case 'y tế':
        return Icons.local_hospital;
      case 'kỹ thuật':
        return Icons.engineering;
      case 'khoa học':
        return Icons.science;
      default:
        return Icons.folder;
    }
  }

  Color _getTypeColor() {
    String type = widget.document.type.toLowerCase();
    if (type == 'pdf') {
      return Colors.red;
    } else if (type == 'excel' || type == 'xls' || type == 'xlsx') {
      return Colors.green;
    } else if (type == 'word' || type == 'doc' || type == 'docx') {
      return Colors.blue;
    } else if (type == 'ppt' || type == 'pptx') {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  Widget _buildViewsWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            '${widget.document.views}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.description, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              '${widget.document.pageCount} trang',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.download, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              '${widget.document.downloads}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
