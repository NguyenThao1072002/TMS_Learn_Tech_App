import 'package:tms_app/data/models/document/document_model.dart';

abstract class DocumentRepository {
  Future<List<DocumentModel>> getDocuments();
  Future<void> incrementViews(DocumentModel document);
}
