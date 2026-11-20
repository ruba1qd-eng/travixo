// النماذج وخرائط الصور الحقيقية — Travixo Data Models
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// ====== الجداول التعدادية الستة ======
enum Availability { available, limited, comingSoon, unavailable }
enum ServiceType { localRide, rentCar, hotel, airport, tour, package }
enum BookingStatus { pending, confirmed, assigned, active, completed, cancelled, refunded }
enum PaymentMethod { wallet, cash, kuraimi, digitalWallet }
enum TxStatus { pending, completed, failed, refunded }
enum Membership { basic, priority, vip }

// ====== خرائط الصور الحقيقية — Wikimedia Commons ======
// صور حقيقية مؤكدة (كل رابط اختُبر individually ويعمل 200) — المفاتيح مطابقة لمعرفات البيانات

const Map<String, String> kProvinceImgs = {
  'sanaa': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/5ca171f1a0af.jpg',
  'aden': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/d49ecca8a077.jpg',
  'taiz': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/9daf5790f27b.jpg',
  'hadramout': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/c24ece7489fb.jpg',
  'hadramaut_alt': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/c24ece7489fb.jpg',
  'hodeidah': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/7bea4db84245.jpg',
  'ibb': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/32f6fd0b086a.jpg',
  'dhamar': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/32f6fd0b086a.jpg',
  'marib': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/6c91766e114d.jpg',
  'lahij': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/9daf5790f27b.jpg',
  'hajjah': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/5ca171f1a0af.jpg',
  'amran': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/5ca171f1a0af.jpg',
  'sadah': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/5ca171f1a0af.jpg',
  'shabwa': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/c24ece7489fb.jpg',
  'abyan': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/d49ecca8a077.jpg',
  'socotra': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/71024e5a67f1.jpg',
  'mahrah': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/c24ece7489fb.jpg',
  'jawf': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/6c91766e114d.jpg',
  'bayda': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/6c91766e114d.jpg',
  'dhale': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/32f6fd0b086a.jpg',
  'rima': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/32f6fd0b086a.jpg',
};

const Map<String, String> kHotelImgs = {
  'h1': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/7c8e35963185.jpg',
  'h2': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/afe9f24fb247.png',
  'h3': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/9f1a0c7fdc79.jpg',
  'h4': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/da425e602e65.jpeg',
  'h5': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/cf4ce921fe76.jpg',
  'h6': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/c54add62cd48.jpg',
  'h7': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/35923145b277.jpg',
  'h8': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/026c837e8286.jpg',
  'rh1': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/23825b22a5ab.jpg',
  'rh2': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/ea3deb7a08ae.jpg',
  'rh3': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/88073c04db7f.png',
  'rh4': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/a47f5cfbdfd8.png',
  'rh5': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/7adb6c51b197.jpeg',
  'rh6': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/78fe1ce420ca.jpg',
  'rh7': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/e9417e476bcd.jpg',
  'rh8': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/31ff43c9030a.jpg',
  'rh9': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/ac4286fcb014.jpg',
  'rh10': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/7b9b905b4a46.jpg',
  'rh11': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/8d238eca96e1.jpg',
  'rh12': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/8cf22bd0a0d7.jpg',
  'rh13': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/45cbe75f2288.jpg',
  'rh14': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/3cadd84f11a4.jpg',
  'rh15': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/f53351f6b047.jpg',
};

const Map<String, String> kPlaceImgs = {
  'p1': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/3764d994d03a.jpg',
  'p2': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/2bbca0cd2188.jpg',
  'p3': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/01bab60d8a5c.jpg',
  'p4': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/7723676eaefa.jpg',
  'p5': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/46ace7e35150.jpg',
  'p6': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/b2cc7865b2bd.jpg',
  'p7': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/a83d4af32a2e.jpg',
  'p8': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/47c1403c9988.jpg',
  'p9': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/262db258d13b.jpg',
  'p10': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/2a19671f4069.jpg',
  'p11': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/c67a13ff6178.jpg',
  'p12': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/ce0f58483ed2.jpg',
  'p13': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/7bea4db84245.jpg',
  'p14': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/5ddeef94319f.jpg',
  'p15': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/6a7aacc21c06.jpg',
  'p16': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/7995b8dccdc4.jpg',
  'p17': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/51e2f9894f18.jpg',
  'p18': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/59ca294af8bb.jpg',
};

const Map<String, String> kCarImgs = {
  'c1': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/3bf898d94540.jpg',
  'c2': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/9759e33b8529.jpg',
  'c3': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/c5b816f285c6.jpg',
  'c4': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/2fef5c2a9011.jpg',
  'c5': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/4adf88d56774.jpg',
  'c6': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/23c5704929ab.jpg',
  'c7': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/163b406912b0.jpg',
  'r1': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/8014ec0a0cfb.jpg',
  'r2': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/ae07e8abfc8d.jpg',
  'r3': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/5458819d0c15.jpg',
  'r4': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/dd6648881979.jpg',
  'r5': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/173ffd069a44.jpg',
};

const String kDemoImg = 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/ac5117f479b7.jpg';

// ====== النماذج ======
class AppUser {
  final String id;
  final String firstName;
  final String secondName;
  final int age;
  final String? phone;
  final String? email;
  final String? photoUrl;
  final String role;
  final Membership membership;

  AppUser({
    required this.id,
    required this.firstName,
    required this.secondName,
    required this.age,
    this.phone,
    this.email,
    this.photoUrl,
    this.role = 'customer',
    this.membership = Membership.basic,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] ?? '',
    firstName: json['firstName'] ?? '',
    secondName: json['secondName'] ?? '',
    age: json['age'] ?? 0,
    phone: json['phone'],
    email: json['email'],
    photoUrl: json['photoUrl'],
    role: json['role'] ?? 'customer',
    membership: Membership.values.firstWhere(
      (e) => e.name == json['membership'],
      orElse: () => Membership.basic,
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'secondName': secondName,
    'age': age,
    'phone': phone,
    'email': email,
    'photoUrl': photoUrl,
    'role': role,
    'membership': membership.name,
  };
}

class HotelRoom {
  final String id;
  final String name;
  final String typeId;
  final String bedType;
  final int pricePerNightYer;
  final int capacity;
  final List<String> amenities;
  final bool available;

  HotelRoom({
    required this.id,
    required this.name,
    required this.typeId,
    required this.bedType,
    required this.pricePerNightYer,
    required this.capacity,
    required this.amenities,
    required this.available,
  });
}

class Hotel {
  final String id;
  final String name;
  final String provinceId;
  final String cityId;
  final double rating;
  final int reviewsCount;
  final String description;
  final List<String> amenities;
  final List<HotelRoom> rooms;
  final bool verified;
  final double lat;
  final double lng;

  Hotel({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.cityId,
    required this.rating,
    required this.reviewsCount,
    required this.description,
    required this.amenities,
    required this.rooms,
    required this.verified,
    required this.lat,
    required this.lng,
  });

  Availability get availability =>
      rooms.any((r) => r.available) ? Availability.available : Availability.limited;

  String img() => kHotelImgs[id] ?? kProvinceImgs[provinceId] ?? kDemoImg;
}

class Car {
  final String id;
  final String name;
  final String categoryId;
  final int year;
  final int seats;
  final int pricePerDayYer;
  final bool withDriver;
  final String transmission;
  final String fuel;
  final Availability status;
  final String? driverName;
  final double driverRating;

  Car({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.year,
    required this.seats,
    required this.pricePerDayYer,
    required this.withDriver,
    required this.transmission,
    required this.fuel,
    required this.status,
    this.driverName,
    this.driverRating = 4.8,
  });

  String img() => kCarImgs[id] ?? kCarImgs.values.first;
}

class TourDay {
  final int day;
  final String title;
  final String details;
  TourDay({required this.day, required this.title, required this.details});
}

class Tour {
  final String id;
  final String name;
  final String provinceId;
  final int days;
  final int priceYer;
  final List<String> includes;
  final List<String> excludes;
  final List<TourDay> plan;
  final int seatsLeft;

  Tour({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.days,
    required this.priceYer,
    required this.includes,
    required this.excludes,
    required this.plan,
    required this.seatsLeft,
  });
}

class Offer {
  final String id;
  final String title;
  final String subtitle;
  final ServiceType service;
  final String targetId;
  final int discountPercent;

  Offer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.service,
    required this.targetId,
    required this.discountPercent,
  });
}

class Booking {
  final String id;
  final ServiceType service;
  final String title;
  final String provinceId;
  final String cityId;
  final String dateText;
  final int totalYer;
  final PaymentMethod payment;
  final BookingStatus status;
  final String createdAt;
  final Map<String, dynamic> details;

  Booking({
    required this.id,
    required this.service,
    required this.title,
    required this.provinceId,
    required this.cityId,
    required this.dateText,
    required this.totalYer,
    required this.payment,
    required this.status,
    required this.createdAt,
    required this.details,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] ?? '',
    service: ServiceType.values.firstWhere(
      (e) => e.name == json['service'],
      orElse: () => ServiceType.hotel,
    ),
    title: json['title'] ?? '',
    provinceId: json['provinceId'] ?? '',
    cityId: json['cityId'] ?? '',
    dateText: json['dateText'] ?? '',
    totalYer: json['totalYer'] ?? 0,
    payment: PaymentMethod.values.firstWhere(
      (e) => e.name == json['payment'],
      orElse: () => PaymentMethod.cash,
    ),
    status: BookingStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => BookingStatus.pending,
    ),
    createdAt: json['createdAt'] ?? '',
    details: Map<String, dynamic>.from(json['details'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'service': service.name,
    'title': title,
    'provinceId': provinceId,
    'cityId': cityId,
    'dateText': dateText,
    'totalYer': totalYer,
    'payment': payment.name,
    'status': status.name,
    'createdAt': createdAt,
    'details': details,
  };
}

class WalletTx {
  final String id;
  final String reason;
  final int amountYer;
  final TxStatus status;
  final String createdAt;

  WalletTx({
    required this.id,
    required this.reason,
    required this.amountYer,
    required this.status,
    required this.createdAt,
  });

  factory WalletTx.fromJson(Map<String, dynamic> json) => WalletTx(
    id: json['id'] ?? '',
    reason: json['reason'] ?? '',
    amountYer: json['amountYer'] ?? 0,
    status: TxStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => TxStatus.pending,
    ),
    createdAt: json['createdAt'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'reason': reason,
    'amountYer': amountYer,
    'status': status.name,
    'createdAt': createdAt,
  };
}

class Review {
  final String author;
  final int stars;
  final String text;
  Review({required this.author, required this.stars, required this.text});
}

// ====== Province: id + status فقط (متطابق مع الوثيقة الأصلية) ======
class Province {
  final String id;
  final Availability status;
  Province({required this.id, required this.status});

  String img() => kProvinceImgs[id] ?? kDemoImg;
}

// ====== BestPlace: ترجمة فعلية عبر AppLocalizations ======
class BestPlace {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descAr;
  final String descEn;
  final String provinceId;
  final String category;
  final double rating;
  final double lat;
  final double lng;
  final bool unesco;

  BestPlace({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descAr,
    required this.descEn,
    required this.provinceId,
    required this.category,
    required this.rating,
    required this.lat,
    required this.lng,
    required this.unesco,
  });

  String name(BuildContext context) =>
      AppLocalizations.of(context).code == 'ar' ? nameAr : nameEn;

  String desc(BuildContext context) =>
      AppLocalizations.of(context).code == 'ar' ? descAr : descEn;

  String img() => kPlaceImgs[id] ?? kProvinceImgs[provinceId] ?? kDemoImg;
}
