import 'package:flutter/material.dart';
import '../config/theme.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Go Premium', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Premium Icon/Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.neonPurple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.diamond, color: AppTheme.neonPurple, size: 50),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Unlock Premium Features',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Remove ads and get access to exclusive premium prompts!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // Plan 1: Weekly
            _buildPlanCard(
              context,
              title: 'Weekly Plan',
              price: '₹9',
              duration: '/ week',
              features: ['Ad-free experience for 1 week', 'Access to all basic prompts'],
              isPopular: false,
            ),
            const SizedBox(height: 16),

            // Plan 2: Monthly (Popular)
            _buildPlanCard(
              context,
              title: 'Monthly Plan',
              price: '₹19',
              duration: '/ month',
              features: ['Ad-free experience for 1 month', 'Access to premium prompts', 'Priority Support'],
              isPopular: true,
            ),
            const SizedBox(height: 30),

            // Subscribe Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Baad mein Razorpay/In-App Purchase integrate karenge
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Redirecting to Payment...'), backgroundColor: AppTheme.neonPurple),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Subscribe Now', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Secure payment via Razorpay',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Plan Cards
  Widget _buildPlanCard(BuildContext context, {required String title, required String price, required String duration, required List<String> features, required bool isPopular}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPopular ? AppTheme.neonPurple : Colors.transparent, width: 2),
        boxShadow: isPopular ? [BoxShadow(color: AppTheme.neonPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (isPopular) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.neonPurple, borderRadius: BorderRadius.circular(8)),
                child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(color: AppTheme.neonBlue, fontSize: 32, fontWeight: FontWeight.bold)),
              Text(duration, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 15),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.neonBlue, size: 18),
                const SizedBox(width: 10),
                Text(feature, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
