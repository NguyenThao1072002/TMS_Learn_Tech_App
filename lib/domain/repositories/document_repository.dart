import '../../data/models/document/document_model.dart';

abstract class DocumentRepository {
  Future<List<DocumentModel>> getAllDocuments();

  Future<List<DocumentModel>> getPopularDocuments();

  Future<List<DocumentModel>> getDocumentsByCategory(int categoryId);

  Future<List<DocumentModel>> getRelatedDocuments(int categoryId);

  Future<List<DocumentModel>> searchDocuments(String keyword);

  Future<DocumentModel?> getDocumentDetail(int id);

  Future<List<DocumentModel>> getNewDocuments();

  Future<bool> incrementDownload(int documentId);

  Future<bool> incrementView(int documentId);
}
