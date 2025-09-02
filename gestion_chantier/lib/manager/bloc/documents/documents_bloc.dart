import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/repository/auth_repository.dart';
import 'documents_event.dart';
import 'documents_state.dart';

class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  final DocumentRepository _documentRepository;

  DocumentsBloc({required DocumentRepository documentRepository})
    : _documentRepository = documentRepository,
      super(DocumentsInitial()) {
    on<LoadDocuments>(_onLoadDocuments);
    on<LoadDocumentTypes>(_onLoadDocumentTypes);
    on<AddDocument>(_onAddDocument);
    on<ResetDocumentsState>(_onResetDocumentsState);
  }

  Future<void> _onLoadDocuments(
    LoadDocuments event,
    Emitter<DocumentsState> emit,
  ) async {
    try {
      emit(DocumentsLoading());
      print(
        '🔍 DocumentsBloc: Chargement des documents pour la propriété ${event.propertyId}',
      );

      final documents = await _documentRepository.getDocumentsByProperty(
        event.propertyId,
      );

      print(
        '✅ DocumentsBloc: ${documents.length} documents chargés avec succès',
      );
      emit(DocumentsLoaded(documents));
    } catch (e) {
      print('❌ DocumentsBloc: Erreur lors du chargement des documents: $e');
      emit(DocumentsError(e.toString()));
    }
  }

  Future<void> _onLoadDocumentTypes(
    LoadDocumentTypes event,
    Emitter<DocumentsState> emit,
  ) async {
    try {
      emit(DocumentTypesLoading());
      print('🔍 DocumentsBloc: Chargement des types de documents');

      final documentTypes = await _documentRepository.getDocumentTypes();

      print(
        '🔍 DocumentsBloc: ${documentTypes.length} types de documents chargés avec succès',
      );
      emit(DocumentTypesLoaded(documentTypes));
    } catch (e) {
      print(
        '❌ DocumentsBloc: Erreur lors du chargement des types de documents: $e',
      );
      emit(DocumentTypesError(e.toString()));
    }
  }

  Future<void> _onAddDocument(
    AddDocument event,
    Emitter<DocumentsState> emit,
  ) async {
    try {
      emit(DocumentAdding());
      print('🔍 DocumentsBloc: Ajout d\'un nouveau document');
      print('🔍 DocumentsBloc: Titre: ${event.title}');
      print('🔍 DocumentsBloc: Propriété ID: ${event.realEstatePropertyId}');

      final document = await _documentRepository.addDocument(
        title: event.title,
        file: event.file,
        description: event.description,
        realEstatePropertyId: event.realEstatePropertyId,
        typeId: event.typeId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      print('🔍 DocumentsBloc: Document ajouté avec succès: ${document.title}');
      emit(DocumentAdded(document));

      // Recharger automatiquement la liste des documents
      print('🔍 DocumentsBloc: Rechargement automatique des documents');
      final documents = await _documentRepository.getDocumentsByProperty(
        event.realEstatePropertyId,
      );
      print('🔍 DocumentsBloc: ${documents.length} documents rechargés');
      emit(DocumentsLoaded(documents));
    } catch (e) {
      print('❌ DocumentsBloc: Erreur lors de l\'ajout du document: $e');
      emit(DocumentAddError(e.toString()));
    }
  }

  void _onResetDocumentsState(
    ResetDocumentsState event,
    Emitter<DocumentsState> emit,
  ) {
    emit(DocumentsInitial());
  }
}
