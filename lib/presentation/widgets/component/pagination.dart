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
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          // Hiển thị thông tin tổng số mục nếu có
          if (totalElements != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Hiển thị ${_calculateDisplayRange()} trong số $totalElements kết quả',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nút trang đầu tiên
              if (totalPages > 7)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.first_page, color: Colors.blue),
                    onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
                    tooltip: 'Trang đầu',
                  ),
                ),
              const SizedBox(width: 4),

              // Nút trang trước
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.blue),
                  onPressed: currentPage > 1
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                  tooltip: 'Trang trước',
                ),
              ),
              const SizedBox(width: 8),

              // Số trang
              ...pagesToShow.map((pageNumber) {
                // Hiển thị dấu ... thay vì số trang
                if (pageNumber == -1) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '...',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                final isCurrentPage = pageNumber == currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrentPage ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: !isCurrentPage
                          ? Border.all(color: Colors.blue)
                          : null,
                    ),
                    child: InkWell(
                      onTap: () => onPageChanged(pageNumber),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          '$pageNumber',
                          style: TextStyle(
                            color:
                                isCurrentPage ? Colors.white : Colors.blue[900],
                            fontWeight: isCurrentPage
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(width: 8),

              // Nút trang sau
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.blue),
                  onPressed: currentPage < totalPages
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                  tooltip: 'Trang sau',
                ),
              ),
              const SizedBox(width: 4),

              // Nút trang cuối
              if (totalPages > 7)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.last_page, color: Colors.blue),
                    onPressed: currentPage < totalPages
                        ? () => onPageChanged(totalPages)
                        : null,
                    tooltip: 'Trang cuối',
                  ),
                ),
            ],
          ),
        ],
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
