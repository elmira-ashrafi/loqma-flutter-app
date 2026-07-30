import '../constants/api_constants.dart';
import 'api_client.dart';

Future<void> setActiveApiOrigin(String origin) async {
  await ApiConstants.setActiveOrigin(origin);
  ApiClient.applyActiveOrigin();
}
