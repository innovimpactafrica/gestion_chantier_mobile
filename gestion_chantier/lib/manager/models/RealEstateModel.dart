import 'package:gestion_chantier/manager/models/PropertyType.dart';
import 'package:gestion_chantier/manager/models/UserModel.dart';

class RealEstateModel {
  final int id;
  final String name;
  final String qrcode;
  final String number;
  final String address;
  final int? price;
  final int? numberOfRooms;
  final double? area;
  final String? latitude;
  final String? longitude;
  final double? reservationFee;
  final String? description;
  final int? numberOfLots;
  final double? discount;
  final double? feesFile;
  final int? level;
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
  final PropertyType? propertyType;
  final UserModel? promoter;
  final dynamic recipient;
  final dynamic notary;
  final dynamic agency;
  final dynamic bank;
  final List<String> pictures;
  final String? plan;
  final String? legalStatus;
  final dynamic parentProperty;
  final String? status;
  final bool coOwner;
  final List<dynamic> owners;
  final bool rental;
  final DateTime? allocateDate;
  final bool mezzanine;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? constructionStatus;
  final double? averageProgress;
  final bool available;
  final bool blocked;

  RealEstateModel({
    required this.id,
    required this.name,
    required this.qrcode,
    this.number = '',
    this.address = '',
    this.price,
    this.numberOfRooms,
    this.area,
    this.latitude,
    this.longitude,
    this.reservationFee,
    this.description,
    this.numberOfLots,
    this.discount,
    this.feesFile,
    this.level,
    this.hasHall = false,
    this.hasParking = false,
    this.hasElevator = false,
    this.hasSwimmingPool = false,
    this.hasGym = false,
    this.hasPlayground = false,
    this.hasSecurityService = false,
    this.hasGarden = false,
    this.hasSharedTerrace = false,
    this.hasBicycleStorage = false,
    this.hasLaundryRoom = false,
    this.hasStorageRooms = false,
    this.hasWasteDisposalArea = false,
    this.propertyType,
    this.promoter,
    this.recipient,
    this.notary,
    this.agency,
    this.bank,
    this.pictures = const [],
    this.plan,
    this.legalStatus,
    this.parentProperty,
    this.status,
    this.coOwner = false,
    this.owners = const [],
    this.rental = false,
    this.allocateDate,
    this.mezzanine = false,
    this.startDate,
    this.endDate,
    this.constructionStatus,
    this.averageProgress,
    this.available = true,
    required this.blocked,
  });

  factory RealEstateModel.fromJson(Map<String, dynamic> json) {
    return RealEstateModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      qrcode: json['qrcode']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      price: _toIntNullable(json['price']),
      numberOfRooms: _toIntNullable(json['numberOfRooms']),
      area: _toDoubleNullable(json['area']),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      reservationFee: _toDoubleNullable(json['reservationFee']),
      description: json['description']?.toString(),
      numberOfLots: _toIntNullable(json['numberOfLots']),
      discount: _toDoubleNullable(json['discount']),
      feesFile: _toDoubleNullable(json['feesFile']),
      level: _toIntNullable(json['level']),
      hasHall: _toBool(json['hasHall']),
      hasParking: _toBool(json['hasParking']),
      hasElevator: _toBool(json['hasElevator']),
      hasSwimmingPool: _toBool(json['hasSwimmingPool']),
      hasGym: _toBool(json['hasGym']),
      hasPlayground: _toBool(json['hasPlayground']),
      hasSecurityService: _toBool(json['hasSecurityService']),
      hasGarden: _toBool(json['hasGarden']),
      hasSharedTerrace: _toBool(json['hasSharedTerrace']),
      hasBicycleStorage: _toBool(json['hasBicycleStorage']),
      hasLaundryRoom: _toBool(json['hasLaundryRoom']),
      hasStorageRooms: _toBool(json['hasStorageRooms']),
      hasWasteDisposalArea: _toBool(json['hasWasteDisposalArea']),
      propertyType:
          json['propertyType'] != null
              ? PropertyType.fromJson(json['propertyType'])
              : null,
      promoter:
          json['promoter'] != null
              ? UserModel.fromJson(json['promoter'])
              : null,
      recipient: json['recipient'],
      notary: json['notary'],
      agency: json['agency'],
      bank: json['bank'],
      pictures:
          json['pictures'] != null
              ? List<String>.from(
                json['pictures'].map((x) => x?.toString() ?? ''),
              )
              : [],
      plan: json['plan']?.toString(),
      legalStatus: json['legalStatus']?.toString(),
      parentProperty: json['parentProperty'],
      status: json['status']?.toString(),
      coOwner: _toBool(json['coOwner']),
      owners: json['owners'] ?? [],
      rental: _toBool(json['rental']),
      blocked: _toBool(json['blocked']),
      allocateDate: _parseDateNullable(json['allocateDate']),
      mezzanine: _toBool(json['mezzanine']),
      startDate: _parseDateNullable(json['startDate']),
      endDate: _parseDateNullable(json['endDate']),
      constructionStatus: json['constructionStatus']?.toString(),
      averageProgress: _toDoubleNullable(json['averageProgress']),
      available: _toBool(json['available']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      if (value.isEmpty) return 0;
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static int? _toIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      if (value.isEmpty) return null;
      return int.tryParse(value);
    }
    return null;
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return null;
      return double.tryParse(value);
    }
    return null;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  static DateTime? _parseDateNullable(dynamic dateValue) {
    if (dateValue == null) return null;

    try {
      // Parsing from list [year, month, day, ...]
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
        return DateTime.parse(dateValue);
      }
      // Parsing from milliseconds timestamp
      if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'qrcode': qrcode,
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
      'propertyType': propertyType?.toJson(),
      'promoter': promoter?.toJson(),
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
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'constructionStatus': constructionStatus,
      'averageProgress': averageProgress,
      'available': available,
      'blocked': blocked,
    };
  }

  static List<RealEstateModel> fromJsonList(List<dynamic> list) {
    return list.map<RealEstateModel>((e) {
      try {
        return RealEstateModel.fromJson(e);
      } catch (error) {
        print('Error parsing RealEstateModel: $error');
        // Retourner un modèle minimal pour éviter de casser toute la liste
        return RealEstateModel(
          id: e['id'] ?? 0,
          name: e['name']?.toString() ?? 'Erreur de parsing',
          qrcode: e['qrcode']?.toString() ?? "",
          blocked: e['blocked'] ?? true,
        );
      }
    }).toList();
  }
}
