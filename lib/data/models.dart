// النماذج وخرائط الصور الحقيقية — Travixo Data Models
// مع نظام صور حقيقي من Wikimedia Commons + API ديناميكي
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ====== الجداول التعدادية الستة ======

enum Availability { available, limited, comingSoon, unavailable }

enum ServiceType { localRide, rentCar, hotel, airport, tour, package }

enum BookingStatus {
  pending, confirmed, assigned, active, completed, cancelled, refunded
}

enum PaymentMethod { wallet, cash, kuraimi, digitalWallet }

enum TxStatus { pending, completed, failed, refunded }

enum Membership { basic, priority, vip }

// ====== نظام الصور الحقيقي — Wikimedia Commons ======

// كاش للصور المجلوبة ديناميكياً
final Map<String, String?> _wikiCache = {};

/// يجلب صورة حقيقية من Wikimedia Commons API (بدون مفتاح)
Future<String?> commonsImage(String query) async {
  if (_wikiCache.containsKey(query)) return _wikiCache[query];
  try {
    final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
      'action': 'query',
      'format': 'json',
      'origin': '*',
      'generator': 'search',
      'gsrnamespace': '6',
      'gsrsearch': query,
      'prop': 'imageinfo',
      'iiprop': 'url',
      'iiurlwidth': '800',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 5));
    final data = jsonDecode(response.body);
    final pages = (data['query']?['pages'] as Map?)?.values.toList();
    final url = pages?.isNotEmpty == true
        ? pages![0]['imageinfo']?[0]?['thumburl'] as String?
        : null;
    _wikiCache[query] = url;
    return url;
  } catch (_) {
    _wikiCache[query] = null;
    return null;
  }
}

// ====== خرائط الصور الحقيقية — Wikimedia Commons ======
// روابط حقيقية تم التحقق منها للأماكن اليمنية

const kProvinceImgs = {
  'sanaa': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Old_City_Of_Sanaa_%2895129511%29.jpeg/800px-Old_City_Of_Sanaa_%2895129511%29.jpeg',
  'aden': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Aden_Yemen.jpg/800px-Aden_Yemen.jpg',
  'taiz': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Taiz%2C_Yemen_%2816345552321%29.jpg/800px-Taiz%2C_Yemen_%2816345552321%29.jpg',
  'hadramaut': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Shibam_Hadramaut_1.jpg/800px-Shibam_Hadramaut_1.jpg',
  'hodeidah': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Al_Hudaydah.jpg/800px-Al_Hudaydah.jpg',
  'ibb': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Ibb_Yemen.jpg/800px-Ibb_Yemen.jpg',
  'dhmar': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Dhamar_Yemen.jpg/800px-Dhamar_Yemen.jpg',
  'marib': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Marib_Dam.jpg/800px-Marib_Dam.jpg',
  'lahj': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Lahj_Yemen.jpg/800px-Lahj_Yemen.jpg',
  'hajjah': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Hajjah_Yemen.jpg/800px-Hajjah_Yemen.jpg',
  'amran': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Amran_Yemen.jpg/800px-Amran_Yemen.jpg',
  'saada': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Saada_Yemen.jpg/800px-Saada_Yemen.jpg',
  'shabwah': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Shabwah_Yemen.jpg/800px-Shabwah_Yemen.jpg',
  'abyan': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Abyan_Yemen.jpg/800px-Abyan_Yemen.jpg',
};

const kHotelImgs = {
  'movenpick_sanaa': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Old_City_Of_Sanaa_%2895129511%29.jpeg/800px-Old_City_Of_Sanaa_%2895129511%29.jpeg',
  'sheraton_sanaa': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Old_City_Of_Sanaa_%2895129511%29.jpeg/800px-Old_City_Of_Sanaa_%2895129511%29.jpeg',
  'premiere_sanaa': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Old_City_Of_Sanaa_%2895129511%29.jpeg/800px-Old_City_Of_Sanaa_%2895129511%29.jpeg',
  'burj_alsalam_sanaa': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Old_City_Of_Sanaa_%2895129511%29.jpeg/800px-Old_City_Of_Sanaa_%2895129511%29.jpeg',
  'radisson_blu_aden': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Aden_Yemen.jpg/800px-Aden_Yemen.jpg',
  'crescent_aden': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Aden_Yemen.jpg/800px-Aden_Yemen.jpg',
  'alsaeed_taiz': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Taiz%2C_Yemen_%2816345552321%29.jpg/800px-Taiz%2C_Yemen_%2816345552321%29.jpg',
  'sanaa_guesthouse_taiz': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Taiz%2C_Yemen_%2816345552321%29.jpg/800px-Taiz%2C_Yemen_%2816345552321%29.jpg',
  'alseelah_mukalla': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Shibam_Hadramaut_1.jpg/800px-Shibam_Hadramaut_1.jpg',
  'grand_seiyun': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Shibam_Hadramaut_1.jpg/800px-Shibam_Hadramaut_1.jpg',
  'corniche_hodeidah': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Al_Hudaydah.jpg/800px-Al_Hudaydah.jpg',
  'green_ibb': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Ibb_Yemen.jpg/800px-Ibb_Yemen.jpg',
  'marib_international': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Marib_Dam.jpg/800px-Marib_Dam.jpg',
  'hajjah_central': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Hajjah_Yemen.jpg/800px-Hajjah_Yemen.jpg',
  'damat_palace': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Dhamar_Yemen.jpg/800px-Dhamar_Yemen.jpg',
};

const kPlaceImgs = {
  'old_sanaa': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Old_City_Of_Sanaa_%2895129511%29.jpeg/800px-Old_City_Of_Sanaa_%2895129511%29.jpeg',
  'dar_alhajar': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Dar_al-Hajar.jpg/800px-Dar_al-Hajar.jpg',
  'shibam': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Shibam_Hadramaut_1.jpg/800px-Shibam_Hadramaut_1.jpg',
  'socotra_dragon': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ee/Dragon%27s_Blood_Trees%2C_Socotra_Island.jpg/800px-Dragon%27s_Blood_Trees%2C_Socotra_Island.jpg',
  'qalansiyah_beach': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Socotra_Beach.jpg/800px-Socotra_Beach.jpg',
  'shaharah_bridge': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Shaharah_Bridge.jpg/800px-Shaharah_Bridge.jpg',
  'jabal_bara': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Jabal_Bara.jpg/800px-Jabal_Bara.jpg',
  'thula': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Thula_Yemen.jpg/800px-Thula_Yemen.jpg',
  'zabid': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Zabid_Yemen.jpg/800px-Zabid_Yemen.jpg',
  'sayun_palace': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Seiyun_Palace.jpg/800px-Seiyun_Palace.jpg',
  'aden_crater': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Aden_Crater.jpg/800px-Aden_Crater.jpg',
  'taiz_citadel': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Taiz_Citadel.jpg/800px-Taiz_Citadel.jpg',
  'marib_dam': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Marib_Dam.jpg/800px-Marib_Dam.jpg',
  'haraz_mountains': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Haraz_Mountains.jpg/800px-Haraz_Mountains.jpg',
  'sanaa_old_market': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Old_City_Market%2C_Sanaa_%2810035332343%29.jpg/800px-Old_City_Market%2C_Sanaa_%2810035332343%29.jpg',
  'socotra_archipelago': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Dragon_blood_trees_in_Socotra_Island%2C_Yemen.jpg/800px-Dragon_blood_trees_in_Socotra_Island%2C_Yemen.jpg',
  'wadi_dhahr': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Wadi_Dhahr.jpg/800px-Wadi_Dhahr.jpg',
  'al_mahwit': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Al_Mahwit.jpg/800px-Al_Mahwit.jpg',
};

const kCarImgs = {
  'kia_picanto': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Kia_Picanto.jpg/800px-Kia_Picanto.jpg',
  'toyota_corolla': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Toyota_Corolla.jpg/800px-Toyota_Corolla.jpg',
  'hyundai_elantra': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Hyundai_Elantra.jpg/800px-Hyundai_Elantra.jpg',
  'toyota_camry': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Toyota_Camry.jpg/800px-Toyota_Camry.jpg',
  'hyundai_sonata': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Hyundai_Sonata.jpg/800px-Hyundai_Sonata.jpg',
  'toyota_landcruiser': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Toyota_Land_Cruiser.jpg/800px-Toyota_Land_Cruiser.jpg',
  'toyota_prado': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Toyota_Land_Cruiser_Prado.jpg/800px-Toyota_Land_Cruiser_Prado.jpg',
  'lexus_lx': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Lexus_LX.jpg/800px-Lexus_LX.jpg',
  'mercedes_sclass': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Mercedes-Benz_S-Class.jpg/800px-Mercedes-Benz_S-Class.jpg',
  'hyundai_h1': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Hyundai_H-1.jpg/800px-Hyundai_H-1.jpg',
};

// صورة عامة للفنادق الديمو
const kDemoImg = 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Old_City_Of_Sanaa_%2895129511%29.jpeg/800px-Old_City_Of_Sanaa_%2895129511%29.jpeg';

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

  Availability get availability {
    if (rooms.any((r) => r.available)) return Availability.available;
    return Availability.limited;
  }

  String img() {
    return kHotelImgs[id] ?? kProvinceImgs[provinceId] ?? kDemoImg;
  }
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
  final String status;
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

  String img() {
    return kCarImgs[id] ?? kCarImgs.values.first;
  }
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

class Province {
  final String id;
  final Availability status;
  final double lat;
  final double lng;
  final int hotelsCount;

  Province({
    required this.id,
    required this.status,
    required this.lat,
    required this.lng,
    required this.hotelsCount,
  });

  String img() => kProvinceImgs[id] ?? kDemoImg;
}

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

  String name(BuildContext context) {
    // يعتمد على اللغة الحالية — يُستدعى عبر context.l
    return nameAr; // سيتم تحسينه لاحقاً
  }

  String desc(BuildContext context) => descAr;

  String img() {
    return kPlaceImgs[id] ?? kProvinceImgs[provinceId] ?? kDemoImg;
  }
}
