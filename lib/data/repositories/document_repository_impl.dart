import '../../domain/repositories/document_repository.dart';
import '../models/document/document_model.dart';
import '../services/document/document_service.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentService documentService;

  DocumentRepositoryImpl({required this.documentService});

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    return await documentService.getAllDocuments();
  }

  @override
  Future<List<DocumentModel>> getPopularDocuments() async {
    return await documentService.getPopularDocuments();
  }

  @override
  Future<List<DocumentModel>> getDocumentsByCategory(int categoryId) async {
    return await documentService.getDocumentsByCategory(categoryId);
  }

  @override
  Future<List<DocumentModel>> getRelatedDocuments(int categoryId) async {
    return await documentService.getRelatedDocuments(categoryId);
  }

  @override
  Future<List<DocumentModel>> searchDocuments(String keyword) async {
    return await documentService.searchDocuments(keyword);
  }

  @override
  Future<DocumentModel?> getDocumentDetail(int id) async {
    return await documentService.getDocumentDetail(id);
  }

  @override
  Future<List<DocumentModel>> getNewDocuments() async {
    return await documentService.getNewDocuments();
  }

  @override
  Future<bool> incrementDownload(int documentId) async {
    return await documentService.incrementDownload(documentId);
  }

  @override
  Future<bool> incrementView(int documentId) async {
    return await documentService.incrementView(documentId);
  }
}
