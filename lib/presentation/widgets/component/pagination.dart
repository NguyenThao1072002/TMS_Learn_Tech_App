import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nút trang trước
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.blue),
              onPressed:
                  currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            ),
          ),
          const SizedBox(width: 8),

          // Số trang
          ...List.generate(
            totalPages,
            (index) {
              final pageNumber = index + 1;
              final isCurrentPage = pageNumber == currentPage;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrentPage ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        !isCurrentPage ? Border.all(color: Colors.blue) : null,
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
            },
          ),
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
            ),
          ),
        ],
      ),
    );
  }
}
