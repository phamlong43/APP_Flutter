import 'dart:io';
import 'lib/services/api_endpoints.dart';

void main() async {
  print('🔍 NETWORK CONFIGURATION DETECTOR 🔍\n');
  
  await detectNetworkInfo();
  print('\n${'='*50}\n');
  await suggestUrls();
}

Future<void> detectNetworkInfo() async {
  print('📡 Detecting network interfaces...\n');
  
  try {
    final interfaces = await NetworkInterface.list();
    
    for (NetworkInterface interface in interfaces) {
      print('Interface: ${interface.name}');
      
      for (InternetAddress address in interface.addresses) {
        if (address.type == InternetAddressType.IPv4) {
          print('  IPv4: ${address.address}');
        }
      }
      print('');
    }
  } catch (e) {
    print('❌ Error detecting network: $e');
  }
}

Future<void> suggestUrls() async {
  print('💡 SUGGESTED URLS FOR YOUR FLUTTER APP:\n');
  
  try {
    final interfaces = await NetworkInterface.list();
    Set<String> suggestedUrls = {};
    
    // Default URLs
    suggestedUrls.add('http://localhost:8080');
    suggestedUrls.add('http://127.0.0.1:8080');
    suggestedUrls.add(ApiEndpoints.baseUrl); // Configured API URL
    
    // Find local IP addresses
    for (NetworkInterface interface in interfaces) {
      for (InternetAddress address in interface.addresses) {
        if (address.type == InternetAddressType.IPv4 && 
            !address.isLoopback && 
            !address.address.startsWith('169.254')) { // Skip link-local
          suggestedUrls.add('http://${address.address}:8080');
        }
      }
    }
    
    print('Copy these URLs to test in your Flutter app:');
    print('```dart');
    print('static const List<String> backupUrls = [');
    for (String url in suggestedUrls) {
      print('  \'$url\',');
    }
    print('];');
    print('```\n');
    
    print('📝 Instructions:');
    print('1. Make sure your backend server is running on port 8080');
    print('2. Try each URL one by one in your Flutter app');
    print('3. Current configured URL: ${ApiEndpoints.baseUrl}');
    print('4. For iOS Simulator, use: http://localhost:8080');
    print('5. For physical devices, use your computer\'s IP address');
    
  } catch (e) {
    print('❌ Error generating suggestions: $e');
  }
}

// Function để check server có chạy không
Future<void> checkServerStatus() async {
  print('\n🔧 Checking if server is running...\n');
  
  try {
    // Check if port 8080 is listening
    final result = await Process.run('netstat', ['-an']);
    final output = result.stdout.toString();
    
    if (output.contains(':8080')) {
      print('✅ Port 8080 is in use - Server might be running');
    } else {
      print('❌ Port 8080 is not in use - Server is NOT running');
      print('💡 Make sure to start your backend server first!');
    }
  } catch (e) {
    print('⚠️ Could not check port status: $e');
    print('💡 Manually check if your server is running on port 8080');
  }
}
