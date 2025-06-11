import 'package:hive/hive.dart';

class MedicationQuantityHelper {
  static final Box _doseBox = Hive.box('mybox');
  static const String _key = "Medi_Dose";

  // Set quantity for a medication
  static Future<void> setQuantity(String medName, int quantity) async {
    final Map<String, dynamic> quantityMap = Map<String, dynamic>.from(_doseBox.get(_key, defaultValue: {}));

    quantityMap[medName] = quantity;
    await _doseBox.put(_key, quantityMap);
  }

  // Get quantity for a medication
  static int getQuantity(String medName) {
    final Map<String, dynamic> quantityMap =
    Map<String, dynamic>.from(_doseBox.get(_key, defaultValue: {}));

    return quantityMap[medName] ?? 0; // Return 0 if not found
  }
  static Future<int> getQuantityAsync(String name) async {
    final box = await Hive.openBox<Map>('medication_quantity');
    final quantity = box.get('MED_QUANTITY')?[name] ?? 0;
    return quantity;
  }


  // Remove a medication entry
  static Future<void> removeMedication(String medName) async {
    final Map<String, dynamic> quantityMap =
    Map<String, dynamic>.from(_doseBox.get(_key, defaultValue: {}));

    quantityMap.remove(medName);
    await _doseBox.put(_key, quantityMap);
  }

  // Check if medication exists
  static bool containsMedication(String medName) {
    final Map<String, dynamic> quantityMap =
    Map<String, dynamic>.from(_doseBox.get(_key, defaultValue: {}));

    return quantityMap.containsKey(medName);
  }

  // Get all medication quantities (optional utility)
  static Map<String, int> getAllQuantities() {
    final Map<String, dynamic> quantityMap =
    Map<String, dynamic>.from(_doseBox.get(_key, defaultValue: {}));

    return Map<String, int>.from(quantityMap);
  }
}
