import 'package:equatable/equatable.dart';
import 'package:gestion_chantier/manager/models/documents.dart';
import 'package:gestion_chantier/manager/models/UnitParametre.dart';

abstract class DocumentsState extends Equatable {
  const DocumentsState();

  @override
  List<Object?> get props => [];
}

class DocumentsInitial extends DocumentsState {}

class DocumentsLoading extends DocumentsState {}

class DocumentsLoaded extends DocumentsState {
  final List<DocumentModel> documents;

  const DocumentsLoaded(this.documents);

  @override
  List<Object?> get props => [documents];
}

class DocumentsError extends DocumentsState {
  final String message;

  const DocumentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class DocumentTypesLoading extends DocumentsState {}

class DocumentTypesLoaded extends DocumentsState {
  final List<UnitParametre> documentTypes;

  const DocumentTypesLoaded(this.documentTypes);

  @override
  List<Object?> get props => [documentTypes];
}

class DocumentTypesError extends DocumentsState {
  final String message;

  const DocumentTypesError(this.message);

  @override
  List<Object?> get props => [message];
}

class DocumentAdding extends DocumentsState {}

class DocumentAdded extends DocumentsState {
  final DocumentModel document;

  const DocumentAdded(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentAddError extends DocumentsState {
  final String message;

  const DocumentAddError(this.message);

  @override
  List<Object?> get props => [message];
}
