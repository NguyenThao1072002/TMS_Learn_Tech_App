import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/presentation/controller/unified_search_controller.dart';
import 'package:tms_app/presentation/widgets/component/search/unified_search_delegate.dart';

class SearchButton extends StatelessWidget {
  final SearchType searchType;
  final Function(String, SearchType) onSearch;
  final Widget Function(BuildContext, dynamic, SearchType) itemBuilder;

  const SearchButton({
    Key? key,
    required this.searchType,
    required this.onSearch,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get searchController from provider
    final searchController = Provider.of<UnifiedSearchController>(context);

    // Log search button creation
    print('SearchButton created with searchType: $searchType');

    return IconButton(
      icon: const Icon(Icons.search, color: Color(0xFF333333)),
      onPressed: () {
        print('Search button pressed with searchType: $searchType');
        showSearch(
          context: context,
          delegate: UnifiedSearchDelegate(
            searchType: searchType,
            onSearch: onSearch,
            itemBuilder: itemBuilder,
            searchController: searchController,
          ),
        );
      },
    );
  }
}
