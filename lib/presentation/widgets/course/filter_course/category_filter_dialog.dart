import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/data/models/categories/course_category.dart';

class CategoryFilterDialog extends StatefulWidget {
  final List<CourseCategory> categories;
  final List<int> selectedCategoryIds;
  final Function(List<int>) onApplyFilter;

  const CategoryFilterDialog({
    Key? key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onApplyFilter,
  }) : super(key: key);

  @override
  State<CategoryFilterDialog> createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<CategoryFilterDialog> {
  late List<int> _selectedCategoryIds;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds = List.from(widget.selectedCategoryIds);
  }

  void _toggleCategory(int categoryId) {
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
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      ),
      backgroundColor: AppStyles.dialogBgColor,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(
          maxWidth: AppDimensions.dialogMaxWidth + 50,
          maxHeight: AppDimensions.dialogMaxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              height: AppDimensions.dialogHeaderHeight,
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.standardPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Lọc theo danh mục ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Divider
            Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.dialogContentPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSelectionSummary(),
                    SizedBox(height: AppDimensions.standardPadding),
                    _buildCategoryGrid(),
                  ],
                ),
              ),
            ),

            // Footer with action buttons
            Container(
              height: AppDimensions.dialogFooterHeight,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.standardPadding,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: AppStyles.dialogBgColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: _clearSelection,
                    style: AppStyles.clearFilterButtonStyle,
                    child: Text("Xóa lọc"),
                  ),
                  SizedBox(width: AppDimensions.standardPadding),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilter(_selectedCategoryIds);
                      Navigator.of(context).pop();
                    },
                    style: AppStyles.filterActionButtonStyle,
                    child: Text("Áp dụng"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSummary() {
    if (_selectedCategoryIds.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Text(
          "Chọn các danh mục bạn muốn lọc:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Đã chọn ${_selectedCategoryIds.length} danh mục:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedCategoryIds.map((id) {
            final category = widget.categories.firstWhere(
              (cat) => cat.id == id,
              orElse: () => CourseCategory(
                id: id,
                name: "Unknown",
                level: 0,
                type: "COURSE",
                itemCount: 0,
                status: "active",
                createdAt: "",
                updatedAt: "",
              ),
            );

            return Chip(
              label: Text(
                category.name,
                style: AppStyles.categoryChipSelectedTextStyle,
              ),
              backgroundColor: AppStyles.categoryChipSelectedBgColor,
              deleteIconColor: Colors.white,
              onDeleted: () => _toggleCategory(id),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 8),
        Text(
          "Tất cả danh mục:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        childAspectRatio: 2.0,
        crossAxisSpacing: AppDimensions.categoryGridSpacing,
        mainAxisSpacing: AppDimensions.categoryGridSpacing,
      ),
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        final isSelected = _selectedCategoryIds.contains(category.id);

        return GestureDetector(
          onTap: () => _toggleCategory(category.id),
          child: Container(
            decoration: isSelected
                ? AppStyles.categoryChipSelectedDecoration
                : AppStyles.categoryFilterChipDecoration,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.categoryChipHorizontalPadding,
              vertical: AppDimensions.categoryChipVerticalPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    category.name,
                    style: isSelected
                        ? AppStyles.categoryChipSelectedTextStyle
                        : AppStyles.categoryChipTextStyle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
