class ApiConfig {
  // Change this to your computer's IP address when testing on physical device
  // Find your IP: ipconfig (Windows) or ifconfig (Mac/Linux)
  
  // For Android Emulator / physical device - use your computer's LAN IP.
  // This project detected the backend running on 192.168.1.7:5000 when started locally,
  // so use that IP while testing on the physical device on the same Wi-Fi network.
  static const String baseUrl = 'http://192.168.1.7:5000';
  
  // For Android Emulator (alternative, less stable):
  // static const String baseUrl = 'http://10.0.2.2:5000';
  
  // For Physical Device use your computer's IP:
  // static const String baseUrl = 'http://192.168.1.5:5000';
  
  // For iOS Simulator use:
  // static const String baseUrl = 'http://localhost:5000';
  
  static const String apiInfo = '/api/info';
  static const String apiFormats = '/api/formats';
  static const String apiDownload = '/api/download';
  static const String apiFile = '/api/file';
  static const String apiHealth = '/api/health';
}
