import 'package:dart_json_path/src/JsonPathImpl.dart';

abstract class JsonPath {
  read(String json, String path);

  write(String json, String path, dynamic nodeValue, {bool update});

  delete(String json, String path);

  static JsonPath getInsatnce() {
    return JsonPathImpl.getInsatnce();
  }
}
