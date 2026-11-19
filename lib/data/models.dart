
/// Travixo — Data Models (Phase 1)
/// كل النماذج جاهزة للربط بـ Backend حقيقي مستقبلاً ( toJson / fromJson )

enum Availability { available, limited, comingSoon, unavailable }
enum ServiceType { localRide, rentCar, hotel, airport, tour, package }
enum BookingStatus { pending, confirmed, assigned, active, completed, cancelled, refunded }
enum PaymentMethod { wallet, cash, kuraimi, digitalWallet }
enum TxStatus { pending, completed, failed, refunded }
enum Membership { basic, priority, vip }

class AppUser {
  final String id;
  final String firstName, secondName;
  final int age;
  final String? phone, email, photoUrl;
  final String role; // customer | developer
  final Membership membership;
  final bool demo;

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
    this.demo = true,
  });

  String get fullName => '$firstName $secondName';

  Map<String, dynamic> toJson() => {
        'id': id, 'firstName': firstName, 'secondName': secondName, 'age': age,
        'phone': phone, 'email': email, 'photoUrl': photoUrl, 'role': role,
        'membership': membership.name, 'demo': demo,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'], firstName: j['firstName'] ?? '', secondName: j['secondName'] ?? '',
        age: (j['age'] as num?)?.toInt() ?? 0,
        phone: j['phone'], email: j['email'], photoUrl: j['photoUrl'],
        role: j['role'] ?? 'customer',
        membership: Membership.values.firstWhere((m) => m.name == j['membership'],
            orElse: () => Membership.basic),
        demo: j['demo'] ?? true,
      );
}

/// صور توضيحية من مصدر مرخص (Unsplash) — تُستبدل بصور الشركاء عند الإطلاق
const Map<String, String> kProvinceImgs = {
  'sanaa': 'photo-1518684079-3c830dcef090',
  'aden': 'photo-1548510340-358d43a0e8e2',
  'taiz': 'photo-1548013146-72479768bada',
  'hadramout': 'photo-1544735716-392fe2489ffa',
  'hodeidah': 'photo-1544551763-46a013bb70d5',
  'ibb': 'photo-1506905925346-21bda4d32df4',
  'marib': 'photo-1533130061792-64b345e4a833',
  'socotra': 'photo-1540914124281-342587941389',
};

String hotelImg(String provinceId, int index) =>
    'https://images.unsplash.com/${kProvinceImgs[provinceId] ?? kProvinceImgs['sanaa']}?w=600&q=70&sig=$index';

/// صورة حقيقية لكل سيارة (من الويب) — المفتاح: معرّف السيارة
const Map<String, String> kCarImgs = {
  'c1': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/41c1cdf11309.jpg',
  'c2': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/9759e33b8529.jpg',
  'c3': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/c5b816f285c6.jpg',
  'c4': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/2fef5c2a9011.jpg',
  'c5': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/4adf88d56774.jpg',
  'c6': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/23c5704929ab.jpg',
  'c7': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/163b406912b0.jpg',
  'r1': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/8014ec0a0cfb.jpg',
  'r2': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/d882cacd25a7.jpg',
  'r3': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/721ee2daf482.webp',
};

String carImg(String carId) => kCarImgs[carId] ?? kCarImgs['c1']!;

const String kDemoImg =
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600&q=60';

/// صور حقيقية للفنادق الموثّقة (من الويب) — المفتاح: معرّف الفندق
/// تُستبدل بصور الشركاء الرسمية عند الإطلاق
const Map<String, String> kHotelImgs = {
  'rh1': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/e36fde6d8300.jpeg',
  'rh2': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/8f99e8f99990.jpg',
  'rh3': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/83b2b6764707.jpg',
  'rh4': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/71526380f45d.jpeg',
  'rh5': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/de8ccfa752d6.jpg',
  'rh6': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/9079a79256f6.jpg',
  'rh7': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/79536d9dcbb4.jpg',
  'rh8': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/31ff43c9030a.jpg',
  'rh9': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/ac4286fcb014.jpg',
  'rh10': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/7b9b905b4a46.jpg',
  'rh11': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/e84e57d036ac.jpg',
  'rh12': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/b479957e4a15.jpg',
  'rh13': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/022ec68517d4.jpg',
  'rh14': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/3cadd84f11a4.jpg',
  'rh15': 'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/5fca9eb31c07.jpg',
};

/// صور حقيقية لأفضل الأماكن في اليمن — المفتاح: معرّف المكان
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
class Province {
  final String id;
  final Availability status;
  const Province(this.id, this.status);
}

class Hotel {
  final String id, name;
  final String provinceId, cityId;
  final double rating;
  final int reviewsCount;
  final String description;
  final List<String> amenities;
  final List<HotelRoom> rooms;
  final bool verified; // موثّق = بيانات حقيقية، غير موثّق = Demo
  final double lat, lng;

  /// صورة الفندق — حقيقية للفندق نفسه إن وُجدت، وإلا صورة المحافظة
  String img() => kHotelImgs[id] ?? hotelImg(provinceId, id.hashCode.abs());

  const Hotel({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.cityId,
    required this.rating,
    required this.reviewsCount,
    required this.description,
    required this.amenities,
    required this.rooms,
    this.verified = false,
    this.lat = 0,
    this.lng = 0,
  });

  Availability get availability => rooms.any((r) => r.available)
      ? Availability.available
      : Availability.limited;
}

class HotelRoom {
  final String id, name, typeId, bedType;
  final double pricePerNightYer;
  final int capacity;
  final List<String> amenities;
  final bool available;

  const HotelRoom({
    required this.id,
    required this.name,
    required this.typeId,
    required this.bedType,
    required this.pricePerNightYer,
    required this.capacity,
    required this.amenities,
    this.available = true,
  });
}

class Car {
  final String id, name, categoryId;
  final int year, seats;
  final double pricePerDayYer;
  final bool withDriver; // true = نقل مع سائق، false = تأجير
  final String transmission, fuel;
  final Availability status;
  final String? driverName;
  final double driverRating;

  const Car({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.year,
    required this.seats,
    required this.pricePerDayYer,
    required this.withDriver,
    this.transmission = 'Automatic',
    this.fuel = 'Petrol',
    this.status = Availability.available,
    this.driverName,
    this.driverRating = 4.8,
  });
}

class Tour {
  final String id, name, provinceId;
  final int days;
  final double priceYer;
  final List<String> includes, excludes;
  final List<TourDay> plan;
  final int seatsLeft;

  const Tour({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.days,
    required this.priceYer,
    required this.includes,
    required this.excludes,
    required this.plan,
    this.seatsLeft = 8,
  });
}

class TourDay {
  final String day, title, details;
  const TourDay(this.day, this.title, this.details);
}

class Offer {
  final String id, title, subtitle;
  final ServiceType service;
  final String targetId;
  final int discountPercent;

  const Offer({
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
  final String provinceId, cityId;
  final String dateText;
  final double totalYer;
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
    this.status = BookingStatus.confirmed,
    required this.createdAt,
    this.details = const {},
  });

  bool get isUpcoming =>
      status == BookingStatus.confirmed || status == BookingStatus.pending;
  bool get isActive => status == BookingStatus.active;

  Map<String, dynamic> toJson() => {
        'id': id, 'service': service.name, 'title': title,
        'provinceId': provinceId, 'cityId': cityId, 'dateText': dateText,
        'totalYer': totalYer, 'payment': payment.name, 'status': status.name,
        'createdAt': createdAt, 'details': details,
      };

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'],
        service: ServiceType.values.firstWhere((s) => s.name == j['service'],
            orElse: () => ServiceType.localRide),
        title: j['title'] ?? '',
        provinceId: j['provinceId'] ?? '',
        cityId: j['cityId'] ?? '',
        dateText: j['dateText'] ?? '',
        totalYer: (j['totalYer'] as num?)?.toDouble() ?? 0,
        payment: PaymentMethod.values.firstWhere((p) => p.name == j['payment'],
            orElse: () => PaymentMethod.cash),
        status: BookingStatus.values.firstWhere((s) => s.name == j['status'],
            orElse: () => BookingStatus.confirmed),
        createdAt: j['createdAt'] ?? '',
        details: Map<String, dynamic>.from(j['details'] ?? {}),
      );
}

class WalletTx {
  final String id, reason, createdAt;
  final double amountYer;
  final TxStatus status;

  WalletTx({
    required this.id,
    required this.reason,
    required this.amountYer,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id, 'reason': reason, 'amountYer': amountYer,
        'status': status.name, 'createdAt': createdAt,
      };

  factory WalletTx.fromJson(Map<String, dynamic> j) => WalletTx(
        id: j['id'], reason: j['reason'] ?? '',
        amountYer: (j['amountYer'] as num?)?.toDouble() ?? 0,
        status: TxStatus.values.firstWhere((s) => s.name == j['status'],
            orElse: () => TxStatus.completed),
        createdAt: j['createdAt'] ?? '',
      );
}

class Review {
  final String id, targetId, userName, comment;
  final int stars;

  const Review({
    required this.id,
    required this.targetId,
    required this.userName,
    required this.stars,
    this.comment = '',
  });
}
