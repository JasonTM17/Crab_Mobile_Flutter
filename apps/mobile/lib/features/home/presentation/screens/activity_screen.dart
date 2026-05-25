import 'package:flutter/material.dart';

import '../../../food/presentation/screens/order_history_screen.dart';
import '../../../ride/presentation/screens/ride_history_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          tabs: [
            Tab(text: 'Rides', icon: Icon(Icons.local_taxi_rounded)),
            Tab(text: 'Food', icon: Icon(Icons.restaurant_rounded)),
          ],
        ),
        body: TabBarView(
          children: [
            RideHistoryScreen(),
            OrderHistoryScreen(),
          ],
        ),
      ),
    );
  }
}
