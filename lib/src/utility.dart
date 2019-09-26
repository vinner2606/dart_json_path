import 'dart:convert';

class Utility {
  Utility._internal();

  static const TAG = "Utility";

  /// check for string whether it is empty or not.
  static bool isEmpty(String value, {bool integerCheck = false}) {
    var isEmpty = (value?.isEmpty ?? true) || value?.toLowerCase() == "null";
    if (!isEmpty && integerCheck) {
      int data = Utility.castData(value) ?? 0;
      return data <= 0;
    }
    return isEmpty;
  }

  static String getEntityType(String path) {
    String result = path.replaceAll(r"$.", "");
    if (result.contains("."))
      return result.substring(0, result.indexOf("."));
    else
      return result;
  }

  static T castData<T>(dynamic value) {
    if (value == null) return value;
    if (value is T) {
      return value;
    } else if (T == int && value is String) {
      return castData(int.tryParse(value) ?? -1);
    } else if (T == double) {
      if (value is String) {
        return castData(double.tryParse(value) ?? -1.0);
      } else if (value is int) {
        return castData(value.toDouble());
      }
    } else if (T == String && (value is int || value is double)) {
      return castData(value?.toString());
    } else if (T == String &&
        (value is List<dynamic> || value is Map<String, dynamic>)) {
      return castData(jsonEncode(value));
    } else if ((T == List || T == Map) && value is String) {
      try {
        return castData(jsonDecode(value));
      } catch (e) {
        print("Invalid data");
        if (T == Map) {
          return castData(Map());
        } else if (T == List) {
          return castData(List());
        }
      }
    } else {
      throw Exception("Invalid type casting exception $value");
    }
    return value;
  }
}
