import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/prompt_model.dart';

class WordPressService {
  // Posts fetch karne ka function
  Future<List<PromptModel>> fetchPrompts({int page = 1, int perPage = 20}) async {
    try {
      // WordPress API URL with pagination
      final url = Uri.parse('${AppConstants.promptsEndpoint}?page=$page&per_page=$perPage&_embed');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<PromptModel> prompts = [];

        for (var item in data) {
          // Image URL nikalna (_embed ki madad se, jo WordPress ka standard tareeka hai)
          String imageUrl = 'https://via.placeholder.com/400x600?text=No+Image'; // Default fallback
          
          if (item['_embedded'] != null && item['_embedded']['wp:featuredmedia'] != null) {
            imageUrl = item['_embedded']['wp:featuredmedia'][0]['source_url'];
          }

          prompts.add(PromptModel.fromJson(item, imageUrl));
        }
        return prompts;
      } else {
        throw Exception('Failed to load prompts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching prompts: $e');
      throw Exception('Network error. Please check your internet connection.');
    }
  }
}
