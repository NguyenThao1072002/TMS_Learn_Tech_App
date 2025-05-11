import 'package:flutter/material.dart';
import 'package:tms_app/data/models/categories/blog_category.dart';

class BlogCategoryFilterDialog extends StatefulWidget {
  final List<BlogCategory> categories;
  final List<String> selectedCategoryIds;
  final Function(List<String>) onApplyFilter;

  const BlogCategoryFilterDialog({
    Key? key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onApplyFilter,
  }) : super(key: key);

  @override
  State<BlogCategoryFilterDialog> createState() =>
      _BlogCategoryFilterDialogState();
}

class _BlogCategoryFilterDialogState extends State<BlogCategoryFilterDialog> {
  late List<String> _selectedCategoryIds;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds = List.from(widget.selectedCategoryIds);
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedCategoryIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lọc theo danh mục',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn danh mục bài viết:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Tất cả'),
                      selected: _selectedCategoryIds.isEmpty,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategoryIds.clear();
                          });
                        }
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: const Color(0xFF3498DB),
                      labelStyle: TextStyle(
                        color: _selectedCategoryIds.isEmpty
                            ? Colors.white
                            : Colors.black,
                        fontWeight: _selectedCategoryIds.isEmpty
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    ...widget.categories.map((category) {
                      final isSelected =
                          _selectedCategoryIds.contains(category.id.toString());
                      return FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          _toggleCategory(category.id.toString());
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: const Color(0xFF3498DB),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _clearSelection,
                  child: const Text('Đặt lại'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilter(_selectedCategoryIds);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                  ),
                  child: const Text('Áp dụng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
