import 'dart:convert';
import 'dart:collection';

import 'package:dart_json_path/src/JsonPathUtility.dart';

class JsonPathReader with JsonPathUtility {
  static final JsonPathReader _instance = new JsonPathReader._internal();

  JsonPathReader._internal();

  factory JsonPathReader() {
    return _instance;
  }

  static JsonPathReader getInsatnce() {
    return _instance;
  }

  Object read(String json, String path, {String fallback}) {
    /*if (null == json || json.isEmpty) {
      throw NullThrownError();
    }*/
    if (null == path || path.isEmpty) {
      return fallback;
    }

    Map<String, Object> decodedJson;
    try {
      decodedJson = jsonDecode(json);
    } catch (e) {
      decodedJson = new Map();
      //throw InvalidJsonException();
    }

    List<String> splitPath = path.replaceAll("\$.", "").split(".");

    if (decodedJson is LinkedHashMap<String, dynamic>) {
      var key = splitPath.elementAt(0);
      splitPath.removeAt(0);
      return _getSearchKeyFromMap(decodedJson, key, splitPath);
    } else {
      return null;
    }
  }

  Object _getSearchKeyFromMap(LinkedHashMap<String, dynamic> map,
      String nodeName, List<String> splitPath) {
    Set<String> keys = map.keys.toSet();
    int pos = 0;
    while (pos < keys.length && keys.isNotEmpty) {
      String keyName = keys.elementAt(pos);
      if (keyName == nodeName || keyName == nodeName.split("[")[0]) {
        keys.clear();
        dynamic keyValue = map[keyName];
        if (splitPath.isEmpty) {
          if (keyValue is List<dynamic>) {
            int pos = getPositionOfArray(nodeName);
            if (pos > -1) {
              return keyValue.elementAt(pos);
            }
          }
          return keyValue;
        } else {
          if (keyValue == null) {
            return null;
          }
          if (keyValue is String) {
            try {
              keyValue = jsonDecode(keyValue);
            } catch (e) {
              print("String is not valid json $keyValue");
            }
          }
          if (keyValue is LinkedHashMap<dynamic, dynamic>) {
            var key = splitPath.elementAt(0);
            splitPath.removeAt(0);
            return _getSearchKeyFromMap(keyValue, key, splitPath);
          } else if (keyValue is List<dynamic>) {
            int nodePos = getPositionOfArray(nodeName);
            return _getSearchKeyFromList(nodePos, keyValue, keyName, splitPath,
                actualNode: nodeName);
          } else {
            return null;
          }
        }
      }
      pos++;
    }
    return null;
  }

  Object _getSearchKeyFromList(
      int nodePos, List<dynamic> list, String nodeName, List<String> splitPath,
      {String actualNode}) {
    Object data;
    if (list.length == null || list.length == 0) {
      return null;
    }
    if (nodePos > list.length) {
      throw RangeError(nodePos);
    }

    if (nodePos > -1) {
      data = list.elementAt(nodePos);
    } else {
      data = list;
    }
    if (splitPath.isEmpty) {
      if (nodeName.isNotEmpty) {
        if (data is LinkedHashMap<dynamic, dynamic>) {
          return data[nodeName];
        }
      }
      return data;
    } else {
      if (data is LinkedHashMap<dynamic, dynamic>) {
        var key = splitPath.elementAt(0);
        splitPath.removeAt(0);
        return _getSearchKeyFromMap(data, key, splitPath);
      } else if (data is List<dynamic>) {
        var key = splitPath.elementAt(0);
        splitPath.removeAt(0);
        if (actualNode != null &&
            itIsStarOrEmpty(actualNode) &&
            splitPath.isEmpty) {
          return _starOperation(data as List, key);
        } else {
          return _getSearchKeyFromList(-1, data, key, splitPath);
        }
      }
    }
  }

  Object _starOperation(List data, String key) {
    List<Object> response = new List();
    for (Map<String, Object> map in data) {
      if (map.containsKey(key)) {
        response.add(map[key]);
      }
    }
    return response;
  }
}

class JsonPathReader2 with JsonPathUtility {
  static final JsonPathReader2 _instance2 = new JsonPathReader2._internal();

  RegExp regCheckForArray = new RegExp(r"\[.*?\]");

  JsonPathReader2._internal();

  factory JsonPathReader2() {
    return _instance2;
  }

  static JsonPathReader2 getInsatnce() {
    return _instance2;
  }

  Object read(String json, String path, {String fallback}) {
    /*if (null == json || json.isEmpty) {
      throw NullThrownError();
    }*/
    if (null == path || path.isEmpty) {
      return fallback;
    }

    Map<String, Object> decodedJson;
    try {
      decodedJson = jsonDecode(json);
    } catch (e) {
      decodedJson = new Map();
      //throw InvalidJsonException();
    }

    List<String> splitPath = path.replaceAll("\$.", "").split(".");

    if (decodedJson is LinkedHashMap<String, dynamic>) {
      var key = splitPath.elementAt(0);
      splitPath.removeAt(0);
      return _getSearchKeyFromMap(decodedJson, key, splitPath);
    } else {
      return null;
    }
  }

  Object _getSearchKeyFromMap(LinkedHashMap<String, dynamic> map,
      String nodeName, List<String> splitPath) {
    var key = nodeName;
    if (nodeName.contains(regCheckForArray)) {
      key = nodeName.split(regCheckForArray)[0];
    }
    if (map.containsKey(key)) {
      var keyValue = map[key];
      if (keyValue == null) {
        return null;
      }
      if (splitPath.isEmpty) {
        if (keyValue is List<dynamic>) {
          int pos = getPositionOfArray(nodeName);
          if (pos > -1) {
            return keyValue.elementAt(pos);
          }
        }
        return keyValue;
      } else {
        if (keyValue is String) {
          try {
            keyValue = jsonDecode(keyValue);
          } catch (e) {
            print("String is not valid json $keyValue");
          }
        }
        if (keyValue is LinkedHashMap<dynamic, dynamic>) {
          var key = splitPath.elementAt(0);
          splitPath.removeAt(0);
          return _getSearchKeyFromMap(keyValue, key, splitPath);
        } else if (keyValue is List<dynamic>) {
          int nodePos = getPositionOfArray(nodeName);
          return _getSearchKeyFromList(nodePos, keyValue, key, splitPath,
              actualNode: nodeName);
        } else {
          return null;
        }
      }
    }
    return null;
  }

  Object _getSearchKeyFromList(
      int nodePos, List<dynamic> list, String nodeName, List<String> splitPath,
      {String actualNode}) {
    Object data;
    if (list.length == null || list.length == 0) {
      return null;
    }
    if (nodePos > list.length) {
      throw RangeError(nodePos);
    }

    if (nodePos > -1) {
      data = list.elementAt(nodePos);
    } else {
      data = list;
    }
    if (splitPath.isEmpty) {
      if (nodeName.isNotEmpty) {
        if (data is LinkedHashMap<dynamic, dynamic>) {
          return data[nodeName];
        }
      }
      return data;
    } else {
      if (data is LinkedHashMap<dynamic, dynamic>) {
        var key = splitPath.elementAt(0);
        splitPath.removeAt(0);
        return _getSearchKeyFromMap(data, key, splitPath);
      } else if (data is List<dynamic>) {
        var key = splitPath.elementAt(0);
        splitPath.removeAt(0);
        if (actualNode != null &&
            itIsStarOrEmpty(actualNode) &&
            splitPath.isEmpty) {
          return _starOperation(data as List, key);
        } else {
          return _getSearchKeyFromList(-1, data, key, splitPath);
        }
      }
    }
  }

  Object _starOperation(List data, String key) {
    List<Object> response = new List();
    for (Map<String, Object> map in data) {
      if (map.containsKey(key)) {
        response.add(map[key]);
      }
    }
    return response;
  }
}
