import 'package:flutter/material.dart';
import '../config/theme.dart';

class CreatorScreen extends StatelessWidget {
  const CreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Become a Creator', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join the Creator Program',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Share your best prompts and start earning Diamonds. Fill out your creator profile and payment setup.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // --- Form Fields ---
            const Text('Personal Details', style: TextStyle(color: AppTheme.neonPurple, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTextField('Profile Image URL *', Icons.image),
            const SizedBox(height: 12),
            _buildTextField('Bio *', Icons.description, maxLines: 3),
            const SizedBox(height: 12),
            _buildTextField('Phone Number *', Icons.phone, isNumber: true),
            const SizedBox(height: 12),
            _buildTextField('Social Link *', Icons.link),
            
            const SizedBox(height: 24),
            const Text('Address Details', style: TextStyle(color: AppTheme.neonPurple, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTextField('Address Line 1 *', Icons.home),
            const SizedBox(height: 12),
            _buildTextField('Address Line 2 *', Icons.home_work),
            const SizedBox(height: 12),
            _buildTextField('Pincode *', Icons.pin_drop, isNumber: true),
            const SizedBox(height: 12),
            
            // Location Row
            Row(
              children: [
                Expanded(child: _buildTextField('Country', Icons.public)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField('State', Icons.location_city)),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField('City', Icons.map),

            const SizedBox(height: 24),
            const Text('Payout Details', style: TextStyle(color: AppTheme.neonPurple, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTextField('UPI ID (e.g., yourname@upi) *', Icons.payment),

            const SizedBox(height: 30),
            
            // --- Submit Button ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application Submitted Successfully!'), backgroundColor: AppTheme.neonPurple),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Application', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Text Fields
  Widget _buildTextField(String hint, IconData icon, {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: AppTheme.cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.neonPurple)),
      ),
    );
  }
}
