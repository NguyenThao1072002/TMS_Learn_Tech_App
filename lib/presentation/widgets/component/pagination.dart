import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int? totalElements;
  final int? itemsPerPage;
  final Function(int) onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.totalElements,
    this.itemsPerPage,
  });

  @override
  Widget build(BuildContext context) {
    // Tính toán các trang sẽ hiển thị
    List<int> pagesToShow = _calculatePagesToShow();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // Hiển thị thông tin tổng số mục nếu có
          if (totalElements != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Hiển thị ${_calculateDisplayRange()} trong số $totalElements kết quả',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nút trang đầu tiên
              if (totalPages > 7)
                _buildNavButton(
                  icon: Icons.first_page,
                  onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
                  tooltip: 'Trang đầu',
                ),
              const SizedBox(width: 8),

              // Nút trang trước
              _buildNavButton(
                icon: Icons.chevron_left,
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                tooltip: 'Trang trước',
              ),
              const SizedBox(width: 12),

              // Số trang
              ...pagesToShow.map((pageNumber) {
                // Hiển thị dấu ... thay vì số trang
                if (pageNumber == -1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      '•••',
                      style: TextStyle(
                        color: Colors.lightBlue.shade700,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                final isCurrentPage = pageNumber == currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildPageButton(pageNumber, isCurrentPage),
                );
              }).toList(),
              const SizedBox(width: 12),

              // Nút trang sau
              _buildNavButton(
                icon: Icons.chevron_right,
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                tooltip: 'Trang sau',
              ),
              const SizedBox(width: 8),

              // Nút trang cuối
              if (totalPages > 7)
                _buildNavButton(
                  icon: Icons.last_page,
                  onPressed: currentPage < totalPages
                      ? () => onPageChanged(totalPages)
                      : null,
                  tooltip: 'Trang cuối',
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Phương thức xây dựng nút điều hướng
  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    final isDisabled = onPressed == null;

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDisabled
                    ? Colors.grey.shade300
                    : Colors.lightBlue.shade300,
                width: 1.5,
              ),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.lightBlue.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: isDisabled
                    ? Colors.grey.shade400
                    : Colors.lightBlue.shade700,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Phương thức xây dựng nút số trang
  Widget _buildPageButton(int pageNumber, bool isCurrentPage) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPageChanged(pageNumber),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: isCurrentPage ? Colors.lightBlue.shade600 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrentPage
                  ? Colors.lightBlue.shade700
                  : Colors.lightBlue.shade200,
              width: 1.5,
            ),
            boxShadow: isCurrentPage
                ? [
                    BoxShadow(
                      color: Colors.lightBlue.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$pageNumber',
              style: TextStyle(
                color: isCurrentPage ? Colors.white : Colors.lightBlue.shade800,
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Phương thức tính toán các trang sẽ hiển thị
  List<int> _calculatePagesToShow() {
    List<int> pages = [];

    // Nếu ít hơn 8 trang, hiển thị tất cả
    if (totalPages <= 7) {
      pages = List.generate(totalPages, (index) => index + 1);
      return pages;
    }

    // Luôn hiển thị trang đầu tiên
    pages.add(1);

    // Nếu trang hiện tại gần trang đầu tiên
    if (currentPage <= 4) {
      pages.addAll([2, 3, 4, 5]);
      pages.add(-1); // Dấu ...
      pages.add(totalPages);
    }
    // Nếu trang hiện tại gần trang cuối cùng
    else if (currentPage >= totalPages - 3) {
      pages.add(-1); // Dấu ...
      pages.addAll([
        totalPages - 4,
        totalPages - 3,
        totalPages - 2,
        totalPages - 1,
        totalPages
      ]);
    }
    // Trang hiện tại ở giữa
    else {
      pages.add(-1); // Dấu ...
      pages.addAll([currentPage - 1, currentPage, currentPage + 1]);
      pages.add(-1); // Dấu ...
      pages.add(totalPages);
    }

    return pages;
  }

  // Tính toán phạm vi hiển thị
  String _calculateDisplayRange() {
    if (totalElements == null || itemsPerPage == null) {
      return '';
    }

    int start = (currentPage - 1) * (itemsPerPage ?? 10) + 1;
    int end = currentPage * (itemsPerPage ?? 10);

    // Đảm bảo end không vượt quá tổng số mục
    if (end > (totalElements ?? 0)) {
      end = totalElements ?? 0;
    }

    return '$start-$end';
  }
}
