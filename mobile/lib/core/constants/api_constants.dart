class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator
  static const String baseUrl = 'http://10.0.2.2:5001/api'; 
  // static const String baseUrl = 'http://localhost:5001/api'; // For iOS Simulator
  
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String googleLoginEndpoint = '/auth/google';
  static const String meEndpoint = '/auth/me';
}
