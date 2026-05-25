import 'package:crab_mobile/features/auth/data/models/auth_models.dart';
import 'package:crab_mobile/features/ride/data/models/location_model.dart';
import 'package:crab_mobile/features/ride/data/models/ride_model.dart';
import 'package:crab_mobile/features/ride/data/models/driver_model.dart';
import 'package:crab_mobile/features/food/data/models/restaurant_model.dart';
import 'package:crab_mobile/features/food/data/models/menu_item_model.dart';
import 'package:crab_mobile/features/food/data/models/cart_model.dart';
import 'package:crab_mobile/features/food/data/models/order_model.dart';
import 'package:crab_mobile/features/payment/data/models/payment_models.dart';
import 'package:crab_mobile/features/chat/data/models/conversation_model.dart';
import 'package:crab_mobile/features/notifications/data/models/notification_model.dart';
import 'package:crab_mobile/features/profile/data/models/user_profile_model.dart';
import 'package:crab_mobile/features/rating/data/models/rating_model.dart';

// ═══════════════════════════════════════════════════════════════
// AUTH FIXTURES
// ═══════════════════════════════════════════════════════════════

const tAccessToken = 'test_access_token_abc123';
const tRefreshToken = 'test_refresh_token_xyz789';
const tUserId = 'user-uuid-001';
const tUserRole = 'customer';
const tEmail = 'test@crab.vn';
const tPhone = '+84901234567';
const tPassword = 'Test@1234';
const tFirstName = 'Nguyen';
const tLastName = 'Van A';
const tOtpCode = '123456';

final tAuthTokens = AuthTokens(
  accessToken: tAccessToken,
  refreshToken: tRefreshToken,
);

final tUserModel = UserModel(
  id: tUserId,
  email: tEmail,
  phone: tPhone,
  firstName: tFirstName,
  lastName: tLastName,
  role: tUserRole,
  status: 'active',
  phoneVerified: true,
);

final tAuthResponse = AuthResponse(
  user: tUserModel,
  tokens: tAuthTokens,
);

Map<String, dynamic> get tAuthResponseJson => {
      'user': {
        'id': tUserId,
        'email': tEmail,
        'phone': tPhone,
        'firstName': tFirstName,
        'lastName': tLastName,
        'role': tUserRole,
        'status': 'active',
        'phoneVerified': true,
      },
      'tokens': {
        'access_token': tAccessToken,
        'refresh_token': tRefreshToken,
      },
    };

// ═══════════════════════════════════════════════════════════════
// LOCATION FIXTURES
// ═══════════════════════════════════════════════════════════════

const tPickupLocation = LocationModel(
  latitude: 10.7769,
  longitude: 106.7009,
  address: '1 Nguyen Hue, Dist 1, HCMC',
  name: 'Nguyen Hue Walking Street',
);

const tDropoffLocation = LocationModel(
  latitude: 10.8015,
  longitude: 106.7147,
  address: '720A Dien Bien Phu, Dist 3, HCMC',
  name: 'Tan Son Nhat Airport',
);

Map<String, dynamic> get tLocationJson => {
      'latitude': 10.7769,
      'longitude': 106.7009,
      'address': '1 Nguyen Hue, Dist 1, HCMC',
      'name': 'Nguyen Hue Walking Street',
    };

// ═══════════════════════════════════════════════════════════════
// FARE ESTIMATE FIXTURES
// ═══════════════════════════════════════════════════════════════

const tFareEstimate = FareEstimate(
  minFare: 35000,
  maxFare: 50000,
  distanceKm: 5.2,
  estimatedMinutes: 15,
  currency: 'VND',
);

Map<String, dynamic> get tFareEstimateJson => {
      'minFare': 35000,
      'maxFare': 50000,
      'distanceKm': 5.2,
      'estimatedMinutes': 15,
      'currency': 'VND',
    };

// ═══════════════════════════════════════════════════════════════
// RIDE FIXTURES
// ═══════════════════════════════════════════════════════════════

final tRideModel = RideModel(
  id: 'ride-uuid-001',
  pickup: tPickupLocation,
  dropoff: tDropoffLocation,
  status: RideStatus.pending,
  fare: 42000,
  currency: 'VND',
  etaMinutes: 5,
  createdAt: DateTime(2026, 5, 20, 10, 0, 0),
);

final tRideSummary = RideSummary(
  rideId: 'ride-uuid-001',
  fare: 42000,
  currency: 'VND',
  distanceKm: 5.2,
  durationMinutes: 15,
  completedAt: DateTime(2026, 5, 20, 10, 15, 0),
);

// ═══════════════════════════════════════════════════════════════
// DRIVER FIXTURES
// ═══════════════════════════════════════════════════════════════

const tVehicleModel = VehicleModel(
  plate: '59A-12345',
  model: 'Honda Wave Alpha',
  color: 'Blue',
  type: 'motorbike',
);

const tDriverModel = DriverModel(
  id: 'driver-uuid-001',
  name: 'Tran Van B',
  phone: '+84909876543',
  rating: 4.8,
  totalRides: 1250,
  vehicle: tVehicleModel,
);

// ═══════════════════════════════════════════════════════════════
// FOOD FIXTURES
// ═══════════════════════════════════════════════════════════════

const tRestaurant = RestaurantModel(
  id: 'rest-uuid-001',
  name: 'Phở 24',
  imageUrl: 'https://example.com/pho24.jpg',
  description: 'Best Pho in town',
  category: 'Vietnamese',
  rating: 4.5,
  totalReviews: 320,
  deliveryTimeMinutes: 25,
  deliveryFee: 15000,
  minOrderAmount: 30000,
  isOpen: true,
  distanceKm: 1.2,
  address: '123 Le Loi, Dist 1',
);

const tRestaurant2 = RestaurantModel(
  id: 'rest-uuid-002',
  name: 'Bún Bò Huế Lý Tự Trọng',
  category: 'Vietnamese',
  rating: 4.3,
  totalReviews: 180,
  deliveryTimeMinutes: 30,
  deliveryFee: 12000,
  minOrderAmount: 25000,
  isOpen: true,
);

const tMenuItem = MenuItemModel(
  id: 'menu-uuid-001',
  restaurantId: 'rest-uuid-001',
  name: 'Phở Bò Tái',
  description: 'Vietnamese beef pho with rare beef slices',
  imageUrl: 'https://example.com/pho-bo.jpg',
  price: 55000,
  currency: 'VND',
  category: 'Main Course',
  isAvailable: true,
  isFeatured: true,
);

const tMenuItem2 = MenuItemModel(
  id: 'menu-uuid-002',
  restaurantId: 'rest-uuid-001',
  name: 'Gỏi Cuốn',
  description: 'Fresh spring rolls with shrimp',
  price: 35000,
  currency: 'VND',
  category: 'Appetizer',
  isAvailable: true,
  isFeatured: false,
);

const tCartItem = CartItemModel(
  item: tMenuItem,
  quantity: 2,
);

const tCartItem2 = CartItemModel(
  item: tMenuItem2,
  quantity: 1,
);

const tCartModel = CartModel(
  restaurantId: 'rest-uuid-001',
  restaurantName: 'Phở 24',
  items: [tCartItem, tCartItem2],
);

const tEmptyCart = CartModel();

const tOrderItem = OrderItemModel(
  menuItemId: 'menu-uuid-001',
  name: 'Phở Bò Tái',
  price: 55000,
  quantity: 2,
);

final tOrderModel = OrderModel(
  id: 'order-uuid-001',
  restaurantId: 'rest-uuid-001',
  restaurantName: 'Phở 24',
  items: [tOrderItem],
  status: OrderStatus.confirmed,
  subtotal: 110000,
  deliveryFee: 15000,
  total: 125000,
  currency: 'VND',
  deliveryAddress: '1 Nguyen Hue, Dist 1, HCMC',
  createdAt: DateTime(2026, 5, 20, 12, 0, 0),
  estimatedMinutes: 30,
);

final tOrderModelDelivered = OrderModel(
  id: 'order-uuid-002',
  restaurantId: 'rest-uuid-001',
  restaurantName: 'Phở 24',
  items: [tOrderItem],
  status: OrderStatus.delivered,
  subtotal: 110000,
  deliveryFee: 15000,
  total: 125000,
  deliveryAddress: '1 Nguyen Hue, Dist 1',
  createdAt: DateTime(2026, 5, 20, 11, 0, 0),
);

Map<String, dynamic> get tOrderJson => {
      'id': 'order-uuid-001',
      'restaurantId': 'rest-uuid-001',
      'restaurantName': 'Phở 24',
      'items': [
        {
          'menuItemId': 'menu-uuid-001',
          'name': 'Phở Bò Tái',
          'price': 55000,
          'quantity': 2,
        },
      ],
      'status': 'confirmed',
      'subtotal': 110000,
      'deliveryFee': 15000,
      'total': 125000,
      'currency': 'VND',
      'deliveryAddress': '1 Nguyen Hue, Dist 1, HCMC',
      'createdAt': '2026-05-20T12:00:00.000',
      'estimatedMinutes': 30,
    };

// ═══════════════════════════════════════════════════════════════
// PAYMENT FIXTURES
// ═══════════════════════════════════════════════════════════════

final tWallet = WalletModel(
  id: 'wallet-uuid-001',
  userId: tUserId,
  balance: 500000,
  currency: 'VND',
  updatedAt: DateTime(2026, 5, 20),
);

final tTransaction = TransactionModel(
  id: 'txn-uuid-001',
  type: 'top_up',
  amount: 200000,
  currency: 'VND',
  status: 'completed',
  description: 'Nạp tiền qua MoMo',
  createdAt: DateTime(2026, 5, 20, 9, 0, 0),
);

final tTransaction2 = TransactionModel(
  id: 'txn-uuid-002',
  type: 'payment',
  amount: -42000,
  currency: 'VND',
  status: 'completed',
  description: 'Thanh toán chuyến đi',
  referenceType: 'ride',
  referenceId: 'ride-uuid-001',
  createdAt: DateTime(2026, 5, 20, 10, 30, 0),
);

final tPromo = PromoModel(
  id: 'promo-uuid-001',
  code: 'GRAB50K',
  description: 'Giảm 50k cho chuyến đi đầu tiên',
  discountType: 'fixed',
  discountValue: 50000,
  maxDiscount: 50000,
  minOrderAmount: 100000,
  expiresAt: DateTime(2026, 12, 31),
);

Map<String, dynamic> get tWalletJson => {
      'id': 'wallet-uuid-001',
      'userId': tUserId,
      'balance': 500000,
      'currency': 'VND',
      'updatedAt': '2026-05-20T00:00:00.000',
    };

// ═══════════════════════════════════════════════════════════════
// CHAT FIXTURES
// ═══════════════════════════════════════════════════════════════

const tParticipant1 = ParticipantModel(
  userId: tUserId,
  name: 'Nguyen Van A',
  role: 'customer',
);

const tParticipant2 = ParticipantModel(
  userId: 'driver-uuid-001',
  name: 'Tran Van B',
  role: 'driver',
);

final tMessage = MessageModel(
  id: 'msg-uuid-001',
  conversationId: 'conv-uuid-001',
  senderId: 'driver-uuid-001',
  content: 'Tôi đang đến',
  type: 'text',
  isRead: false,
  createdAt: DateTime(2026, 5, 20, 10, 5, 0),
);

final tMessage2 = MessageModel(
  id: 'msg-uuid-002',
  conversationId: 'conv-uuid-001',
  senderId: tUserId,
  content: 'Ok, tôi đợi ở cổng chính',
  type: 'text',
  isRead: true,
  createdAt: DateTime(2026, 5, 20, 10, 6, 0),
);

final tConversation = ConversationModel(
  id: 'conv-uuid-001',
  type: 'ride',
  rideId: 'ride-uuid-001',
  participants: [tParticipant1, tParticipant2],
  lastMessage: tMessage,
  unreadCount: 1,
  createdAt: DateTime(2026, 5, 20, 10, 0, 0),
  updatedAt: DateTime(2026, 5, 20, 10, 5, 0),
);

Map<String, dynamic> get tConversationJson => {
      'id': 'conv-uuid-001',
      'type': 'ride',
      'rideId': 'ride-uuid-001',
      'participants': [
        {'userId': tUserId, 'name': 'Nguyen Van A', 'role': 'customer'},
        {'userId': 'driver-uuid-001', 'name': 'Tran Van B', 'role': 'driver'},
      ],
      'lastMessage': {
        'id': 'msg-uuid-001',
        'conversationId': 'conv-uuid-001',
        'senderId': 'driver-uuid-001',
        'content': 'Tôi đang đến',
        'type': 'text',
        'isRead': false,
        'createdAt': '2026-05-20T10:05:00.000',
      },
      'unreadCount': 1,
      'createdAt': '2026-05-20T10:00:00.000',
      'updatedAt': '2026-05-20T10:05:00.000',
    };

Map<String, dynamic> get tMessageJson => {
      'id': 'msg-uuid-001',
      'conversationId': 'conv-uuid-001',
      'senderId': 'driver-uuid-001',
      'content': 'Tôi đang đến',
      'type': 'text',
      'isRead': false,
      'createdAt': '2026-05-20T10:05:00.000',
    };

// ═══════════════════════════════════════════════════════════════
// NOTIFICATION FIXTURES
// ═══════════════════════════════════════════════════════════════

final tNotification = NotificationModel(
  id: 'notif-uuid-001',
  type: 'ride',
  title: 'Chuyến đi hoàn thành',
  body: 'Chuyến đi của bạn đã kết thúc. Hãy đánh giá tài xế!',
  isRead: false,
  createdAt: DateTime(2026, 5, 20, 10, 15, 0),
);

final tNotification2 = NotificationModel(
  id: 'notif-uuid-002',
  type: 'food',
  title: 'Đơn hàng đang chuẩn bị',
  body: 'Phở 24 đang chuẩn bị đơn hàng của bạn.',
  isRead: true,
  createdAt: DateTime(2026, 5, 20, 12, 5, 0),
);

final tNotification3 = NotificationModel(
  id: 'notif-uuid-003',
  type: 'promo',
  title: 'Ưu đãi cuối tuần',
  body: 'Giảm 30% cho chuyến đi từ 18h đến 22h.',
  isRead: false,
  createdAt: DateTime(2026, 5, 19, 9, 0, 0),
);

Map<String, dynamic> get tNotificationJson => {
      'id': 'notif-uuid-001',
      'type': 'ride',
      'title': 'Chuyến đi hoàn thành',
      'body': 'Chuyến đi của bạn đã kết thúc. Hãy đánh giá tài xế!',
      'isRead': false,
      'createdAt': '2026-05-20T10:15:00.000',
    };

// ═══════════════════════════════════════════════════════════════
// PROFILE FIXTURES
// ═══════════════════════════════════════════════════════════════

final tUserProfile = UserProfileModel(
  id: tUserId,
  email: tEmail,
  fullName: 'Nguyen Van A',
  phone: tPhone,
  role: tUserRole,
  isVerified: true,
  createdAt: DateTime(2026, 1, 1),
);

Map<String, dynamic> get tUserProfileJson => {
      'id': tUserId,
      'email': tEmail,
      'fullName': 'Nguyen Van A',
      'phone': tPhone,
      'role': tUserRole,
      'isVerified': true,
      'createdAt': '2026-01-01T00:00:00.000',
    };

// ═══════════════════════════════════════════════════════════════
// RATING FIXTURES
// ═══════════════════════════════════════════════════════════════

final tRating = RatingModel(
  id: 'rating-uuid-001',
  targetType: 'ride',
  targetId: 'ride-uuid-001',
  score: 5,
  comment: 'Tài xế rất tốt',
  tags: ['polite', 'safe_driving'],
  imageUrls: [],
  userId: tUserId,
  userName: 'Nguyen Van A',
  createdAt: DateTime(2026, 5, 20, 10, 20, 0),
);

const tRatingStats = RatingStatsModel(
  average: 4.7,
  count: 1250,
  distribution: {5: 800, 4: 300, 3: 100, 2: 30, 1: 20},
);

Map<String, dynamic> get tRatingJson => {
      'id': 'rating-uuid-001',
      'targetType': 'ride',
      'targetId': 'ride-uuid-001',
      'score': 5,
      'comment': 'Tài xế rất tốt',
      'tags': ['polite', 'safe_driving'],
      'imageUrls': [],
      'userId': tUserId,
      'userName': 'Nguyen Van A',
      'createdAt': '2026-05-20T10:20:00.000',
    };

// ═══════════════════════════════════════════════════════════════
// RESTAURANT JSON FIXTURES
// ═══════════════════════════════════════════════════════════════

Map<String, dynamic> get tRestaurantJson => {
      'id': 'rest-uuid-001',
      'name': 'Phở 24',
      'imageUrl': 'https://example.com/pho24.jpg',
      'description': 'Best Pho in town',
      'category': 'Vietnamese',
      'rating': 4.5,
      'totalReviews': 320,
      'deliveryTimeMinutes': 25,
      'deliveryFee': 15000,
      'minOrderAmount': 30000,
      'isOpen': true,
      'distanceKm': 1.2,
      'address': '123 Le Loi, Dist 1',
    };

Map<String, dynamic> get tMenuItemJson => {
      'id': 'menu-uuid-001',
      'restaurantId': 'rest-uuid-001',
      'name': 'Phở Bò Tái',
      'description': 'Vietnamese beef pho with rare beef slices',
      'imageUrl': 'https://example.com/pho-bo.jpg',
      'price': 55000,
      'currency': 'VND',
      'category': 'Main Course',
      'isAvailable': true,
      'isFeatured': true,
    };
