import 'dart:convert';

import 'package:dart_json_path/src/JsonPathUtility.dart';

class JsonPathDeleter with JsonPathUtility {
  static final JsonPathDeleter _instance = new JsonPathDeleter._internal();

  JsonPathDeleter._internal();

  factory JsonPathDeleter() {
    return _instance;
  }

  static JsonPathDeleter getInsatnce() {
    return _instance;
  }

  Object delete(String json, String path) {
    if (path == null) {
      throw NullThrownError();
    }
    /*if (null == json) {
      throw NullThrownError();
    }*/

    Map<String, Object> mainNode;
    try {
      mainNode = jsonDecode(json);
    } catch (e) {
      mainNode = new Map();
      //throw InvalidJsonException();
    }

    List<String> splitPath = path.replaceAll("\$.", "").split(".");
    String node = splitPath.first;
    splitPath.removeAt(0);
    return jsonEncode(_deleteFromMap(mainNode, node, splitPath));
  }

  Map<String, Object> _deleteFromMap(
      Map<String, Object> map, String nodeKey, List<String> splitPath) {
    Iterator<MapEntry<String, Object>> iterator = map.entries.iterator;
    while (iterator.moveNext()) {
      var tempKey = nodeKey.split("[")[0];
      if (iterator.current.key == tempKey) {
        if (splitPath.isEmpty) {
          if (iterator.current.value is List) {
            _deleteFromList(iterator.current.value, nodeKey, splitPath);
          } else {
            map.remove(tempKey);
          }
          break;
        } else {
          if (iterator.current.value is Map) {
            String nodeKey = splitPath.first;
            splitPath.removeAt(0);
            _deleteFromMap(iterator.current.value, nodeKey, splitPath);
          } else {
            _deleteFromList(iterator.current.value as List, nodeKey, splitPath);
          }
        }
      }
    }
    return map;
  }

  void _deleteFromList(List list, String nodeKey, List<String> splitPath) {
    int position = getPositionOfArray(nodeKey);
    if (position == -1 && splitPath.isEmpty) {
      return;
    }

    Object object;
    if (position == -1) {
      object = list;
    } else {
      object = list.elementAt(position);
    }
    if (splitPath.isEmpty) {
      list.removeAt(position);
      return;
    }

    if (object is Map) {
      nodeKey = splitPath.first;
      splitPath.removeAt(0);
      _deleteFromMap(object as Map<String, Object>, nodeKey, splitPath);
      return;
    } else {
      _deleteFromList(object as List, nodeKey, splitPath);
      return;
    }
  }
}
