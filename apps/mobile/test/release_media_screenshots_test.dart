import 'dart:io';
import 'dart:ui' as ui;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/core/router/onboarding_screen.dart';
import 'package:crab_mobile/features/auth/data/models/auth_models.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:crab_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:crab_mobile/features/food/data/models/cart_model.dart';
import 'package:crab_mobile/features/food/data/models/restaurant_model.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_state.dart';
import 'package:crab_mobile/features/food/presentation/screens/restaurant_list_screen.dart';
import 'package:crab_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:crab_mobile/features/payment/data/models/payment_models.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_state.dart';
import 'package:crab_mobile/features/payment/presentation/screens/wallet_screen.dart';
import 'package:crab_mobile/features/ride/data/models/location_model.dart';
import 'package:crab_mobile/features/ride/presentation/widgets/ride_bottom_sheet.dart';

import 'integration/helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadReleaseScreenshotFont();
    await _loadMaterialIconsFont();
  });

  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.single;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.single;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('capture mobile onboarding release screenshot', (tester) async {
    final app = TestApp()..stubDefaults();
    const key = ValueKey('release-onboarding');

    await tester.pumpWidget(app.buildWidget(const _ReleaseScreenshotTheme(
      child: RepaintBoundary(
        key: key,
        child: OnboardingScreen(),
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Đi rõ giá, đến đúng giờ'), findsOneWidget);

    await _captureReleaseScreenshot(tester, key, 'mobile-01-onboarding.png');
  });

  testWidgets('capture mobile client login release screenshot', (tester) async {
    final app = TestApp()..stubDefaults();
    const key = ValueKey('release-login');

    await tester.pumpWidget(app.buildWidget(const _ReleaseScreenshotTheme(
      child: RepaintBoundary(
        key: key,
        child: LoginScreen(),
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await _captureReleaseScreenshot(tester, key, 'mobile-client-01-login.png');
  });

  testWidgets('capture mobile client home release screenshot', (tester) async {
    final app = TestApp()..stubDefaults();
    const key = ValueKey('release-home');
    final demoUser = UserModel(
      id: 'demo-user-1',
      email: 'linh.demo@crab.vn',
      phone: 'demo-user-phone',
      firstName: 'Linh',
      lastName: 'Crab',
      role: 'customer',
      status: 'active',
      phoneVerified: true,
    );

    when(() => app.authBloc.state).thenReturn(
      AuthState(status: AuthStatus.authenticated, user: demoUser),
    );
    whenListen(
      app.authBloc,
      const Stream<AuthState>.empty(),
      initialState: AuthState(status: AuthStatus.authenticated, user: demoUser),
    );
    when(() => app.paymentBloc.state).thenReturn(
      WalletLoaded(
        wallet: WalletModel(
          id: 'wallet-demo',
          userId: demoUser.id,
          balance: 325000,
          currency: 'VND',
          updatedAt: DateTime(2026, 5, 25),
        ),
      ),
    );

    await tester.pumpWidget(app.buildWidget(const _ReleaseScreenshotTheme(
      child: RepaintBoundary(
        key: key,
        child: HomeScreen(),
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Dịch vụ nổi bật'), findsOneWidget);

    await _captureReleaseScreenshot(tester, key, 'mobile-client-02-home.png');
  });

  testWidgets('capture mobile ride booking release screenshot', (tester) async {
    final app = TestApp()..stubDefaults();
    const key = ValueKey('release-ride-booking');

    await tester.pumpWidget(app.buildWidget(const _ReleaseScreenshotTheme(
      child: RepaintBoundary(
        key: key,
        child: _ReleaseRideBookingScene(),
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Đặt xe rõ giá'), findsOneWidget);

    await _captureReleaseScreenshot(
      tester,
      key,
      'mobile-client-03-ride-booking.png',
    );
  });

  testWidgets('capture mobile food discovery release screenshot',
      (tester) async {
    final app = TestApp()..stubDefaults();
    const key = ValueKey('release-food-discovery');
    const state = RestaurantListLoaded(
      restaurants: _releaseRestaurants,
      cart: CartModel(),
    );

    when(() => app.foodBloc.state).thenReturn(state);
    whenListen(
      app.foodBloc,
      const Stream<FoodState>.empty(),
      initialState: state,
    );

    await tester.pumpWidget(app.buildWidget(const _ReleaseScreenshotTheme(
      child: RepaintBoundary(
        key: key,
        child: RestaurantListScreen(),
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Crab Rice Studio'), findsOneWidget);

    await _captureReleaseScreenshot(
      tester,
      key,
      'mobile-client-04-food.png',
    );
  });

  testWidgets('capture mobile wallet profile release screenshot',
      (tester) async {
    final app = TestApp()..stubDefaults();
    const key = ValueKey('release-wallet-profile');
    final state = WalletLoaded(
      wallet: WalletModel(
        id: 'wallet-release-2026',
        userId: 'demo-user-1',
        balance: 325000,
        currency: 'VND',
        updatedAt: DateTime(2026, 5, 25, 9, 30),
      ),
      transactions: [
        TransactionModel(
          id: 'tx-release-1',
          type: 'topup',
          amount: 500000,
          currency: 'VND',
          status: 'completed',
          description: 'Portfolio demo top up',
          createdAt: DateTime(2026, 5, 25, 9, 10),
        ),
        TransactionModel(
          id: 'tx-release-2',
          type: 'ride_payment',
          amount: 52000,
          currency: 'VND',
          status: 'completed',
          description: 'Airport demo ride',
          createdAt: DateTime(2026, 5, 25, 8, 45),
        ),
        TransactionModel(
          id: 'tx-release-3',
          type: 'food_payment',
          amount: 98000,
          currency: 'VND',
          status: 'completed',
          description: 'Crab Rice Studio order',
          createdAt: DateTime(2026, 5, 24, 19, 20),
        ),
      ],
    );

    when(() => app.paymentBloc.state).thenReturn(state);
    whenListen(
      app.paymentBloc,
      const Stream<PaymentState>.empty(),
      initialState: state,
    );

    await tester.pumpWidget(app.buildWidget(const _ReleaseScreenshotTheme(
      child: RepaintBoundary(
        key: key,
        child: WalletScreen(),
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Protected'), findsOneWidget);

    await _captureReleaseScreenshot(
      tester,
      key,
      'mobile-client-05-wallet-profile.png',
    );
  });
}

class _ReleaseRideBookingScene extends StatefulWidget {
  const _ReleaseRideBookingScene();

  @override
  State<_ReleaseRideBookingScene> createState() =>
      _ReleaseRideBookingSceneState();
}

class _ReleaseRideBookingSceneState extends State<_ReleaseRideBookingScene> {
  late final ScrollController _sheetController;

  static const pickup = LocationModel(
    latitude: 10.7769,
    longitude: 106.7009,
    name: 'Crab Demo Pickup',
    address: 'Demo Zone Alpha',
  );

  static const dropoff = LocationModel(
    latitude: 10.8015,
    longitude: 106.7147,
    name: 'Crab Demo Dropoff',
    address: 'Demo Zone Beta',
  );

  static const fare = FareEstimate(
    minFare: 42000,
    maxFare: 52000,
    distanceKm: 6.4,
    estimatedMinutes: 18,
  );

  @override
  void initState() {
    super.initState();
    _sheetController = ScrollController();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(child: _ReleaseMapBackdrop()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    const _ReleaseCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      label: 'Quay lại',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A0F172A),
                              blurRadius: 22,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B14F)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.route_rounded,
                                color: Color(0xFF00B14F),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Lộ trình rõ giá, tài xế gần bạn',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 844,
              child: RideBottomSheet(
                scrollController: _sheetController,
                pickup: pickup,
                dropoff: dropoff,
                fareEstimate: fare,
                onPickupTap: () {},
                onDropoffTap: () {},
                onBookRide: (_) {},
                onSwap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleaseMapBackdrop extends StatelessWidget {
  const _ReleaseMapBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFEAF4EA)),
      child: Stack(
        children: [
          for (final road in _roads)
            Positioned(
              left: road.left,
              top: road.top,
              child: Transform.rotate(
                angle: road.angle,
                child: Container(
                  width: road.width,
                  height: road.height,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          const Positioned(
            left: 180,
            top: 240,
            child: _ReleaseMapPin(
              icon: Icons.my_location_rounded,
              color: Color(0xFF00B14F),
            ),
          ),
          const Positioned(
            left: 250,
            top: 118,
            child: _ReleaseMapPin(
              icon: Icons.flag_rounded,
              color: Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReleaseRoad {
  const _ReleaseRoad({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.angle,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double angle;
}

const _roads = [
  _ReleaseRoad(left: -32, top: 120, width: 500, height: 18, angle: -0.18),
  _ReleaseRoad(left: -24, top: 230, width: 460, height: 16, angle: 0.2),
  _ReleaseRoad(left: 84, top: 28, width: 18, height: 360, angle: 0.08),
  _ReleaseRoad(left: 246, top: 12, width: 16, height: 330, angle: -0.12),
];

class _ReleaseMapPin extends StatelessWidget {
  const _ReleaseMapPin({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _ReleaseCircleButton extends StatelessWidget {
  const _ReleaseCircleButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF101828)),
      ),
    );
  }
}

const _releaseRestaurants = [
  RestaurantModel(
    id: 'rest-release-1',
    name: 'Crab Rice Studio',
    description: 'Cơm nóng, món nướng demo và canh nhẹ giao nhanh',
    category: 'Việt Nam',
    rating: 4.8,
    totalReviews: 1240,
    deliveryTimeMinutes: 20,
    deliveryFee: 0,
    minOrderAmount: 30000,
    isOpen: true,
    distanceKm: 1.2,
    address: 'Demo Food Court A',
  ),
  RestaurantModel(
    id: 'rest-release-2',
    name: 'Crab Noodle Lab',
    description: 'Bún nướng demo, cuốn giòn và nước chấm ấm vị',
    category: 'Bún chả',
    rating: 4.9,
    totalReviews: 980,
    deliveryTimeMinutes: 15,
    deliveryFee: 0,
    minOrderAmount: 35000,
    isOpen: true,
    distanceKm: 1.8,
    address: 'Demo Food Court B',
  ),
  RestaurantModel(
    id: 'rest-release-3',
    name: 'Crab Pho Kitchen',
    description: 'Phở demo nóng, rau tươi và topping chọn sẵn',
    category: 'Phở',
    rating: 4.7,
    totalReviews: 760,
    deliveryTimeMinutes: 24,
    deliveryFee: 12000,
    minOrderAmount: 40000,
    isOpen: true,
    distanceKm: 2.3,
    address: 'Demo Food Court C',
  ),
];

class _ReleaseScreenshotTheme extends StatelessWidget {
  const _ReleaseScreenshotTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: _releaseFontFamily),
        primaryTextTheme:
            theme.primaryTextTheme.apply(fontFamily: _releaseFontFamily),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontFamily: _releaseFontFamily),
        child: child,
      ),
    );
  }
}

const _releaseFontFamily = 'CrabReleaseSans';

Future<void> _loadReleaseScreenshotFont() async {
  final candidates = <String>[
    r'C:\Windows\Fonts\segoeui.ttf',
    r'C:\Windows\Fonts\arial.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    '/System/Library/Fonts/Supplemental/Arial.ttf',
  ];

  for (final path in candidates) {
    final file = File(path);
    if (!file.existsSync()) continue;

    final bytes = await file.readAsBytes();
    for (final family in <String>[
      _releaseFontFamily,
      'Ahem',
      'Roboto',
      'Arial',
      'Segoe UI',
    ]) {
      await _loadFontBytes(family, bytes);
    }
    return;
  }
}

Future<void> _loadMaterialIconsFont() async {
  final candidates = <String>[
    '${Directory.current.path}/build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
    '${Directory.current.path}/build/flutter_assets/fonts/MaterialIcons-Regular.otf',
    '${Directory.current.path}/build/app/intermediates/flutter/debug/flutter_assets/fonts/MaterialIcons-Regular.otf',
  ];

  for (final path in candidates) {
    final file = File(path);
    if (!file.existsSync()) continue;

    final bytes = await file.readAsBytes();
    await _loadFontBytes('MaterialIcons', bytes);
    return;
  }
}

Future<void> _loadFontBytes(String family, Uint8List bytes) async {
  final loader = FontLoader(family)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();
}

Future<void> _captureReleaseScreenshot(
  WidgetTester tester,
  Key key,
  String fileName,
) async {
  if (Platform.environment['UPDATE_RELEASE_SCREENSHOTS'] != 'true') return;

  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
  final image = await boundary.toImage(pixelRatio: 1);
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final output =
        File('${Directory.current.path}/../../docs/screenshots/$fileName');
    output.parent.createSync(recursive: true);
    output.writeAsBytesSync(bytes!.buffer.asUint8List());
  } finally {
    image.dispose();
  }

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}
