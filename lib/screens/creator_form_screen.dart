import 'package:flutter/material.dart';

class CreatorFormScreen extends StatefulWidget {
  const CreatorFormScreen({super.key});

  @override
  State<CreatorFormScreen> createState() => _CreatorFormScreenState();
}

class _CreatorFormScreenState extends State<CreatorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _socialController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _pincodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _upiController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    _phoneController.dispose();
    _socialController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Yahan baad mein WordPress API ka code aayega
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application Submitted Successfully!')),
      );
      Navigator.pop(context); // Wapas profile screen par bhej do
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Become a Creator', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join the Creator Program',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Share your best prompts and start earning. Fill out your creator profile and payment setup to get started.',
                style: TextStyle(color: Colors.grey[400], height: 1.5),
              ),
              const SizedBox(height: 32),

              // --- Personal Details ---
              _buildSectionTitle('Personal Details'),
              const SizedBox(height: 16),
              
              // Profile Image Placeholder
              Center(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image upload coming soon!')),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Color(0xFF00E5FF), size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildTextField(_bioController, 'Bio *', 'Tell us about yourself...', maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Phone Number *', 'Enter your phone number', keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(_socialController, 'Social Link *', 'Link to your portfolio or social media'),

              const SizedBox(height: 32),

              // --- Address Details ---
              _buildSectionTitle('Address Details'),
              const SizedBox(height: 16),
              _buildTextField(_address1Controller, 'Address Line 1 *', 'Street address, P.O. box, company name...'),
              const SizedBox(height: 16),
              _buildTextField(_address2Controller, 'Address Line 2 *', 'Apartment, suite, unit, building, floor...'),
              const SizedBox(height: 16),
              _buildTextField(_pincodeController, 'Pincode *', 'Enter your pincode', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_countryController, 'Location - Country *', 'Enter your country'),
              const SizedBox(height: 16),
              _buildTextField(_stateController, 'Location - State *', 'Enter your state'),
              const SizedBox(height: 16),
              _buildTextField(_cityController, 'Location - City *', 'Enter your city'),

              const SizedBox(height: 32),

              // --- Payout Details ---
              _buildSectionTitle('Payout Details'),
              const SizedBox(height: 16),
              _buildTextField(_upiController, 'UPI ID', 'e.g., yourname@upi'),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00E5FF))),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (label.contains('*') && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}