import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class DocumentsEvent extends Equatable {
  const DocumentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDocuments extends DocumentsEvent {
  final int propertyId;

  const LoadDocuments(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class LoadDocumentTypes extends DocumentsEvent {
  const LoadDocumentTypes();

  @override
  List<Object?> get props => [];
}

class AddDocument extends DocumentsEvent {
  final String title;
  final File file;
  final String description;
  final int realEstatePropertyId;
  final int typeId;
  final String startDate;
  final String endDate;

  const AddDocument({
    required this.title,
    required this.file,
    required this.description,
    required this.realEstatePropertyId,
    required this.typeId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
    title,
    file,
    description,
    realEstatePropertyId,
    typeId,
    startDate,
    endDate,
  ];
}

class ResetDocumentsState extends DocumentsEvent {}
