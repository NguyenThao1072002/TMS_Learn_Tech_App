import 'package:tms_app/data/datasources/document_data.dart';
import 'package:tms_app/data/models/document_model.dart';
import 'package:tms_app/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDatasource datasource;

  DocumentRepositoryImpl(this.datasource);

  @override
  Future<List<DocumentModel>> getDocuments() async {
    return await datasource.getDocuments();
  }

  @override
  Future<void> incrementViews(DocumentModel document) async {
    await datasource.incrementViews(document);
  }
}
