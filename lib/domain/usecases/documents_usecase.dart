import 'package:tms_app/data/models/document_model.dart';
import 'package:tms_app/domain/repositories/document_repository.dart';

class FetchDocumentsUseCase {
  final DocumentRepository repository;

  FetchDocumentsUseCase(this.repository);

  Future<List<DocumentModel>> call() async {
    return await repository.getDocuments();
  }
}

class IncrementDocumentViewsUseCase {
  final DocumentRepository repository;

  IncrementDocumentViewsUseCase(this.repository);

  Future<void> call(DocumentModel document) async {
    await repository.incrementViews(document);
  }
}
