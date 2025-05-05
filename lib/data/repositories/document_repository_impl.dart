
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_data.dart';
import '../models/document/document_model.dart';

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
