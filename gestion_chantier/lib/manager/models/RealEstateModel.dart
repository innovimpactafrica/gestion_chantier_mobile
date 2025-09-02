import 'package:gestion_chantier/manager/models/PropertyType.dart';
import 'package:gestion_chantier/manager/models/UserModel.dart';

class RealEstateModel {
  final int id;
  final String name;
  final String number;
  final String address;
  final int price;
  final int numberOfRooms;
  final double area;
  final String latitude;
  final String longitude;
  final double reservationFee;
  final String description;
  final int numberOfLots;
  final double discount;
  final double feesFile;
  final int level;
  final bool hasHall;
  final bool hasParking;
  final bool hasElevator;
  final bool hasSwimmingPool;
  final bool hasGym;
  final bool hasPlayground;
  final bool hasSecurityService;
  final bool hasGarden;
  final bool hasSharedTerrace;
  final bool hasBicycleStorage;
  final bool hasLaundryRoom;
  final bool hasStorageRooms;
  final bool hasWasteDisposalArea;
  final PropertyType propertyType;
  final UserModel promoter;
  final dynamic recipient;
  final dynamic notary;
  final dynamic agency;
  final dynamic bank;
  final List<String> pictures;
  final String plan;
  final String legalStatus;
  final dynamic parentProperty;
  final String status;
  final bool coOwner;
  final List<dynamic> owners;
  final bool rental;
  final DateTime? allocateDate;
  final bool mezzanine;
  final DateTime startDate;
  final DateTime endDate;
  final String constructionStatus;
  final double averageProgress;
  final bool available;

  RealEstateModel({
    required this.id,
    required this.name,
    required this.number,
    required this.address,
    required this.price,
    required this.numberOfRooms,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.reservationFee,
    required this.description,
    required this.numberOfLots,
    required this.discount,
    required this.feesFile,
    required this.level,
    required this.hasHall,
    required this.hasParking,
    required this.hasElevator,
    required this.hasSwimmingPool,
    required this.hasGym,
    required this.hasPlayground,
    required this.hasSecurityService,
    required this.hasGarden,
    required this.hasSharedTerrace,
    required this.hasBicycleStorage,
    required this.hasLaundryRoom,
    required this.hasStorageRooms,
    required this.hasWasteDisposalArea,
    required this.propertyType,
    required this.promoter,
    this.recipient,
    this.notary,
    this.agency,
    this.bank,
    required this.pictures,
    required this.plan,
    required this.legalStatus,
    this.parentProperty,
    required this.status,
    required this.coOwner,
    required this.owners,
    required this.rental,
    this.allocateDate,
    required this.mezzanine,
    required this.startDate,
    required this.endDate,
    required this.constructionStatus,
    required this.averageProgress,
    required this.available,
  });

  factory RealEstateModel.fromJson(Map<String, dynamic> json) {
    return RealEstateModel(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      address: json['address'] ?? '',
      price: _toInt(json['price']),
      numberOfRooms: _toInt(json['numberOfRooms']),
      area: _toDouble(json['area']),
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      reservationFee: _toDouble(json['reservationFee']),
      description: json['description'] ?? '',
      numberOfLots: _toInt(json['numberOfLots']),
      discount: _toDouble(json['discount']),
      feesFile: _toDouble(json['feesFile']),
      level: _toInt(json['level']),
      hasHall: json['hasHall'] ?? false,
      hasParking: json['hasParking'] ?? false,
      hasElevator: json['hasElevator'] ?? false,
      hasSwimmingPool: json['hasSwimmingPool'] ?? false,
      hasGym: json['hasGym'] ?? false,
      hasPlayground: json['hasPlayground'] ?? false,
      hasSecurityService: json['hasSecurityService'] ?? false,
      hasGarden: json['hasGarden'] ?? false,
      hasSharedTerrace: json['hasSharedTerrace'] ?? false,
      hasBicycleStorage: json['hasBicycleStorage'] ?? false,
      hasLaundryRoom: json['hasLaundryRoom'] ?? false,
      hasStorageRooms: json['hasStorageRooms'] ?? false,
      hasWasteDisposalArea: json['hasWasteDisposalArea'] ?? false,
      propertyType: PropertyType.fromJson(json['propertyType'] ?? {}),
      promoter: UserModel.fromJson(json['promoter'] ?? {}),
      recipient: json['recipient'],
      notary: json['notary'],
      agency: json['agency'],
      bank: json['bank'],
      pictures:
          json['pictures'] != null ? List<String>.from(json['pictures']) : [],
      plan: json['plan'] ?? '',
      legalStatus: json['legalStatus'] ?? '',
      parentProperty: json['parentProperty'],
      status: json['status'] ?? '',
      coOwner: json['coOwner'] ?? false,
      owners: json['owners'] ?? [],
      rental: json['rental'] ?? false,
      allocateDate:
          json['allocateDate'] != null
              ? _parseDate(json['allocateDate'])
              : null,
      mezzanine: json['mezzanine'] ?? false,
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      constructionStatus: json['constructionStatus'] ?? '',
      averageProgress: _toDouble(json['averageProgress']),
      available: json['available'] ?? true,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDate(dynamic dateValue) {
    // Parsing from list [year, month, day, ...]
    if (dateValue == null) return DateTime.now();
    if (dateValue is List && dateValue.length >= 3) {
      return DateTime(
        dateValue[0] ?? DateTime.now().year,
        dateValue[1] ?? DateTime.now().month,
        dateValue[2] ?? DateTime.now().day,
        dateValue.length > 3 ? dateValue[3] ?? 0 : 0,
        dateValue.length > 4 ? dateValue[4] ?? 0 : 0,
        dateValue.length > 5 ? dateValue[5] ?? 0 : 0,
        dateValue.length > 6 ? (dateValue[6] ?? 0) ~/ 1000000 : 0,
      );
    }
    // Parsing from ISO string
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'address': address,
      'price': price,
      'numberOfRooms': numberOfRooms,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'reservationFee': reservationFee,
      'description': description,
      'numberOfLots': numberOfLots,
      'discount': discount,
      'feesFile': feesFile,
      'level': level,
      'hasHall': hasHall,
      'hasParking': hasParking,
      'hasElevator': hasElevator,
      'hasSwimmingPool': hasSwimmingPool,
      'hasGym': hasGym,
      'hasPlayground': hasPlayground,
      'hasSecurityService': hasSecurityService,
      'hasGarden': hasGarden,
      'hasSharedTerrace': hasSharedTerrace,
      'hasBicycleStorage': hasBicycleStorage,
      'hasLaundryRoom': hasLaundryRoom,
      'hasStorageRooms': hasStorageRooms,
      'hasWasteDisposalArea': hasWasteDisposalArea,
      'propertyType': propertyType.toJson(),
      'promoter': promoter.toJson(),
      'recipient': recipient,
      'notary': notary,
      'agency': agency,
      'bank': bank,
      'pictures': pictures,
      'plan': plan,
      'legalStatus': legalStatus,
      'parentProperty': parentProperty,
      'status': status,
      'coOwner': coOwner,
      'owners': owners,
      'rental': rental,
      'allocateDate': allocateDate?.toIso8601String(),
      'mezzanine': mezzanine,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'constructionStatus': constructionStatus,
      'averageProgress': averageProgress,
      'available': available,
    };
  }

  static List<RealEstateModel> fromJsonList(List<dynamic> list) =>
      list.map((e) => RealEstateModel.fromJson(e)).toList();
}
