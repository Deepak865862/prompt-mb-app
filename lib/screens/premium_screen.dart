import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'Monthly'; // Default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.diamond, color: Color(0xFF00E5FF), size: 60),
            const SizedBox(height: 16),
            const Text(
              'Unlock Premium',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Get unlimited access to all AI prompts without ads!',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Plans Row - Ab Clickable Hain
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlan = 'Weekly';
                      });
                    },
                    child: _buildPlanCard(
                      title: 'Weekly',
                      price: '₹9',
                      duration: '7 Days',
                      isSelected: _selectedPlan == 'Weekly',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlan = 'Monthly';
                      });
                    },
                    child: _buildPlanCard(
                      title: 'Monthly',
                      price: '₹19',
                      duration: '30 Days',
                      isSelected: _selectedPlan == 'Monthly',
                      isPopular: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            _buildFeatureRow(Icons.block, 'No Ads Experience'),
            _buildFeatureRow(Icons.lock_open, 'Unlimited Prompt Unlocks'),
            _buildFeatureRow(Icons.download, 'HD Image Downloads'),
            _buildFeatureRow(Icons.support_agent, 'Priority Support'),
            
            const SizedBox(height: 40),

            // Subscribe Button - Plan Ke Hisaab Se Price Change Hoga
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String price = _selectedPlan == 'Weekly' ? '9' : '₹19';
                  String duration = _selectedPlan == 'Weekly' ? '7 days' : '30 days';
                  
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      title: const Text('Payment', style: TextStyle(color: Colors.white)),
                      content: Text(
                        'You selected $_selectedPlan plan for $price ($duration).\n\nPayment gateway coming soon!',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK', style: TextStyle(color: Color(0xFF00E5FF))),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  _selectedPlan == 'Weekly' 
                      ? 'Subscribe Now - ₹9/week' 
                      : 'Subscribe Now - ₹19/month',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Cancel anytime. Terms apply.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title, 
    required String price, 
    required String duration, 
    required bool isSelected,
    bool isPopular = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent, 
          width: 2
        ),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF), 
                borderRadius: BorderRadius.circular(12)
              ),
              child: const Text(
                'BEST VALUE', 
                style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)
              ),
            ),
          if (isPopular) const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(duration, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          
          // Selection Indicator
          const SizedBox(height: 12),
          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected ? const Color(0xFF00E5FF) : Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00E5FF), size: 24),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}