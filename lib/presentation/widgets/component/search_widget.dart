import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: TextField(
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            border: InputBorder.none,
            hintText: "Tìm khóa học...",
            hintStyle: const TextStyle(
              textBaseline: TextBaseline.alphabetic,
            ),
            suffixIcon: const Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}
