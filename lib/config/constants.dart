class AppConstants {
  // Tumhari WordPress Website ka Base URL
  static const String baseUrl = "https://prompt.mahantababu.com";
  
  // WordPress REST API Endpoint (Posts fetch karne ke liye)
  static const String promptsEndpoint = "$baseUrl/wp-json/wp/v2/posts";
  
  // Media Endpoint (Images ke liye)
  static const String mediaEndpoint = "$baseUrl/wp-json/wp/v2/media";

  // App Details
  static const String appName = "Prompt MB";
  static const String appVersion = "1.0.0";
  
  // Contact Info
  static const String supportEmail = "support@appbees.in";
}
