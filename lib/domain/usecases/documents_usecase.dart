import 'package:tms_app/data/models/document/document_model.dart';
import 'package:tms_app/domain/repositories/document_repository.dart';

class DocumentUseCase {
  final DocumentRepository repository;

  DocumentUseCase(this.repository);

  Future<List<DocumentModel>> getAllDocuments() async {
    return await repository.getAllDocuments();
  }

  Future<List<DocumentModel>> getPopularDocuments() async {
    return await repository.getPopularDocuments();
  }

  Future<List<DocumentModel>> getDocumentsByCategory(int categoryId) async {
    return await repository.getDocumentsByCategory(categoryId);
  }

  Future<List<DocumentModel>> searchDocuments(String keyword) async {
    return await repository.searchDocuments(keyword);
  }

  Future<DocumentModel?> getDocumentDetail(int id) async {
    return await repository.getDocumentDetail(id);
  }

  Future<List<DocumentModel>> getNewDocuments() async {
    return await repository.getNewDocuments();
  }

  Future<bool> incrementDownload(int documentId) async {
    return await repository.incrementDownload(documentId);
  }

  Future<bool> incrementView(int documentId) async {
    return await repository.incrementView(documentId);
  }
}
