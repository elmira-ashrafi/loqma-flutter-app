import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

/// Default delivery address for the logged-in customer (city drives restaurant filtering).
class DeliveryLocationController extends GetxController {
  DeliveryLocationController({AddressService? addressService})
      : _addressService = addressService ?? AddressService();

  final AddressService _addressService;

  final Rxn<AddressModel> deliveryAddress = Rxn<AddressModel>();
  final RxBool isLoading = false.obs;

  int? get deliveryCityId => deliveryAddress.value?.cityId;

  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();
    loadDefaultAddress();
    if (Get.isRegistered<AuthController>()) {
      _authWorker = ever(Get.find<AuthController>().user, (_) => loadDefaultAddress());
    }
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    super.onClose();
  }

  /// Reloads the user's default (or first) address used for city filtering.
  Future<void> loadDefaultAddress() async {
    if (!Get.isRegistered<AuthController>() || !Get.find<AuthController>().isLoggedIn) {
      deliveryAddress.value = null;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      final list = await _addressService.getAddresses();
      AddressModel? pick;
      if (list.isNotEmpty) {
        final defaults = list.where((a) => a.isDefault);
        pick = defaults.isNotEmpty ? defaults.first : list.first;
      }
      deliveryAddress.value = pick;
    } catch (_) {
      deliveryAddress.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
