import 'package:flutter/material.dart';
import 'package:tms_app/presentation/screens/notification/notification_view.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/presentation/controller/unified_search_controller.dart';
import 'package:tms_app/presentation/widgets/component/search/unified_search_delegate.dart';

class HomeAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final int unreadNotifications;

  const HomeAppBarWidget({
    super.key,
    required this.unreadNotifications,
  });

  @override
  Widget build(BuildContext context) {
    // Detect dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Define colors based on theme
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF3498DB);
    final iconColor = const Color(0xFF3498DB); // Keep accent color for brand identity
    
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'TMS Learn Tech',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: iconColor,
            size: 26,
          ),
          onPressed: () {
            final searchController =
                Provider.of<UnifiedSearchController>(context, listen: false);
            showSearch(
              context: context,
              delegate: UnifiedSearchDelegate(
                searchType: SearchType.all,
                onSearch: (query, type) {
                  searchController.search(query, type);
                },
                itemBuilder: (context, item, type) {
                  return ListTile(
                    title: Text(item.toString()),
                    onTap: () {
                      // Xử lý khi người dùng nhấp vào một kết quả
                    },
                  );
                },
                searchController: searchController,
              ),
            );
          },
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none_outlined,
                color: iconColor,
                size: 26,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            if (unreadNotifications > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$unreadNotifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HomeSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Tìm kiếm khóa học, tài liệu...';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(fontSize: 16);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Define colors based on theme
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final inputFillColor = isDarkMode ? const Color(0xFF2A2D3E) : Colors.grey.shade100;
    final hintColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500;
    
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3498DB)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        hintStyle: TextStyle(color: hintColor),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Define colors based on theme
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final shadowColor = isDarkMode 
        ? Colors.black.withOpacity(0.3) 
        : Colors.black.withOpacity(0.05);
    
    final suggestions = query.isEmpty
        ? [
            'Flutter',
            'React Native',
            'Android Development',
            'iOS Development',
            'Web Development',
            'Backend Development',
          ]
        : [
            'Flutter Basics',
            'Flutter Advanced',
            'Flutter State Management',
            'Flutter Widgets',
            'Flutter Animations',
          ]
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Container(
      color: backgroundColor,
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(
                Icons.search,
                color: Color(0xFF3498DB),
              ),
              title: Text(
                suggestion,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                query = suggestion;
                showResults(context);
              },
            ),
          );
        },
      ),
    );
  }
}
