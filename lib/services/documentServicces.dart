import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/general_documents.dart';

class DocumentService {
  static const String apiUrl =
      'http://103.166.143.198:8080/account'; // API doc

  Future<List<GeneralDocuments>> fetchDocuments() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => GeneralDocuments.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load documents');
    }
  }
}
