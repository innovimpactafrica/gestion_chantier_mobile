import 'package:gestion_chantier/bet/models/StudyModel.dart';

abstract class BetStudiesState {}

class BetStudiesInitial extends BetStudiesState {}

class BetStudiesLoading extends BetStudiesState {}

class BetStudiesLoaded extends BetStudiesState {
  final List<BetStudyModel> studies;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final bool hasMore;

  BetStudiesLoaded({
    required this.studies,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.hasMore,
  });

  BetStudiesLoaded copyWith({
    List<BetStudyModel>? studies,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    bool? hasMore,
  }) {
    return BetStudiesLoaded(
      studies: studies ?? this.studies,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class BetStudiesError extends BetStudiesState {
  final String message;

  BetStudiesError({required this.message});
}

class BetStudiesLoadingMore extends BetStudiesState {
  final List<BetStudyModel> studies;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final bool hasMore;

  BetStudiesLoadingMore({
    required this.studies,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.hasMore,
  });
}


