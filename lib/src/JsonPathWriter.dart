import 'dart:collection';

import 'dart:convert';

import 'package:dart_json_path/src/utility.dart';

import 'package:dart_json_path/src/JsonPathUtility.dart';

class JsonPathWriter with JsonPathUtility {
  static final JsonPathWriter _instance = new JsonPathWriter._internal();
  static bool update = false;

  JsonPathWriter._internal();

  factory JsonPathWriter() {
    return _instance;
  }

  static JsonPathWriter getInsatnce() {
    return _instance;
  }

  Object write(String json, String path, Object nodeValue, {bool update}) {
    if (null == path) {
      throw NullThrownError();
    }
    /* if (null == json) {
      throw NullThrownError();
    }*/
    if (null == update) {
      update = true;
    }
    Map<String, Object> mainNode;
    try {
      mainNode = jsonDecode(json);
    } catch (e) {
      mainNode = new Map();
      //throw InvalidJsonException();
    }

    JsonPathWriter.update = update;

    List<String> splitPath = path.replaceAll("\$.", "").split(".");
    String node = splitPath.first;
    splitPath.removeAt(0);

    if (_ifPathIsArray(splitPath.last)) {
      return jsonEncode(_addValueIntoMap(mainNode, node, nodeValue, splitPath));
    } else {
      Map<String, Object> updatedNodeValue = new Map();
      if (nodeValue != null &&
          nodeValue is String &&
          nodeValue.startsWith(RegExp(r"\{|\["))) {
        try {
          nodeValue = jsonDecode(nodeValue);
        } catch (e) {
          print(" error on decoding writing data using json path ");
        }
      }
      updatedNodeValue[splitPath.last] = nodeValue;
      splitPath.removeLast();
      return jsonEncode(
          _addValueIntoMap(mainNode, node, updatedNodeValue, splitPath));
    }
  }

  Map<String, Object> _addValueIntoMap(
      map1, String nodeName, Object nodeData, List<String> splitPath) {
    Map<String, Object> dataMap = new Map();
    if (map1 == null || map1 == "") {
      map1 = new Map();
    }
    Map castMap = Utility.castData(map1);
    Map<String, Object> map = castMap
        .map((key, value) => MapEntry<String, Object>(key.toString(), value));
    var insertNodeName = nodeName.split("[")[0];

    if (map.containsKey(nodeName) || _isArrayPathExist(map, nodeName)) {
      dataMap.addAll(map);
      var data = map[insertNodeName];
      dataMap.remove(insertNodeName);

      if (splitPath.isEmpty) {
        if (data is String) {
          try {
            if (Utility.isEmpty(data)) {
              data = null;
            } else {
              data = jsonDecode(data);
            }
          } catch (e) {
            print("String is not valid json -$data");
          }
        }
        if (_ifPathIsArray(nodeName)) {
          if (null != data) {
            dataMap[insertNodeName] =
                _addValueInList(data, nodeName, nodeData, splitPath);
          } else {
            dataMap[insertNodeName] = _toList(data);
          }
        } else {
          Map<String, Object> temp = _toMap(data);
          temp.addAll(nodeData);
          dataMap[insertNodeName] = temp;
        }
      } else {
        if (_ifPathIsArray(nodeName)) {
          dataMap[insertNodeName] =
              _addValueInList(data, nodeName, nodeData, splitPath);
        } else {
          String nextNodeName = splitPath.elementAt(0);
          splitPath.removeAt(0);
          dataMap[insertNodeName] =
              _addValueIntoMap(data, nextNodeName, nodeData, splitPath);
        }
      }
    } else {
      dataMap.addAll(map);

      if (splitPath.isNotEmpty) {
        if (_ifPathIsArray(nodeName)) {
          dataMap[insertNodeName] =
              _addValueInList(new List(), nodeName, nodeData, splitPath);
        } else {
          String nextNodeName = splitPath.elementAt(0);
          splitPath.removeAt(0);
          dataMap[insertNodeName] =
              _addValueIntoMap(null, nextNodeName, nodeData, splitPath);
        }
      } else {
        try {
          if (_ifPathIsArray(nodeName)) {
            dataMap[insertNodeName] =
                _addValueInList(null, nodeName, nodeData, splitPath);
          } else {
            if (nodeData is String) {
              dataMap[insertNodeName] = nodeData;
            } else {
              dataMap[insertNodeName] = _toMap(nodeData);
            }
          }
        } catch (e) {}
      }
    }
    return dataMap;
  }

  bool _isArrayPathExist(LinkedHashMap<String, Object> map, String nodeName) {
    String key = nodeName.split("[")[0];
    if (map.containsKey(key) && map[key] is List) {
      return true;
    }
    return false;
  }

  List _addValueInList(
      data1, String nodeName, Object nodeData, List<String> splitPath) {
    if (data1 == null || data1 == "") {
      data1 = new List();
    }
    List<dynamic> data = Utility.castData(data1);
    List tempListData = new List();
    int pos = getPositionOfArray(nodeName);
    if (data == null || data.length == 0) {
      pos = -1;
    }

    if (pos > -1) {
      tempListData.addAll(data);
      var objectType;
      try {
        objectType = data.elementAt(pos);
        tempListData.removeAt(pos);
      } catch (e) {}
      tempListData.insert(pos, _addIntoList(objectType, nodeData, splitPath));
    } else {
      tempListData = data;
      tempListData.add(_addIntoList(null, nodeData, splitPath));
    }
    return tempListData;
  }

  Object _addIntoList(Object data, Object nodeData, List<String> splitPath) {
    if (splitPath.isEmpty) {
      if (data is Map) {
        return _toMap(nodeData as Map<String, Object>, lastObject: data);
      } else if (nodeData is List) {
        return _toList(nodeData);
      } else {
        return nodeData;
      }
    } else {
      if (nodeData is String) {
        return nodeData;
      } else if (nodeData is List) {
        String nodeName = splitPath.elementAt(0);
        splitPath.removeAt(0);
        return _addValueInList(data, nodeName, nodeData, splitPath);
      } else {
        String nodeName = splitPath.elementAt(0);
        splitPath.removeAt(0);
        if (data == null) {
          Map<String, Object> data1 = new Map();
          return _addValueIntoMap(data1, nodeName, nodeData, splitPath);
        } else {
          return _addValueIntoMap(data, nodeName, nodeData, splitPath);
        }
      }
    }
  }

  bool _ifPathIsArray(String str) {
    RegExp exp = new RegExp(".*\[[0-9]*\]");
    if (exp.hasMatch(str)) {
      return true;
    }
    return false;
  }

  Map<String, Object> _toMap(LinkedHashMap<String, Object> object,
      {Object lastObject}) {
    if (object == null) return Map<String, Object>();
    Map<String, Object> map = new Map();
    Iterator<String> keysItr;
    if (lastObject != null && lastObject is Map) {
      map = _getAlreadyStoreValue(lastObject as Map<String, Object>);
    }

    keysItr = object.keys.iterator;
    while (keysItr.moveNext()) {
      String key = keysItr.current;
      Object value = object[key];
      map[key] = _nullValueHandel(value);
      if (value is List) {
        value = _toList(value);
      } else if (value is LinkedHashMap) {
        value = _toMap(value);
      }
      map[key] = value;
    }
    return map;
  }

  Map<String, Object> _getAlreadyStoreValue(Map<String, Object> lastObject) {
    Map<String, Object> map = new Map();
    Iterator<String> keysItr;
    keysItr = lastObject.keys.iterator;
    while (keysItr.moveNext()) {
      String key = keysItr.current;
      Object value = lastObject[key];
      map[key] = _nullValueHandel(value);
      if (value is List) {
        value = _toList(value);
      } else if (value is LinkedHashMap) {
        value = _toMap(value);
      }
      map[key] = value;
    }
    return map;
  }

  Object _nullValueHandel(Object value) {
    if (value == null) {
      return "";
    }
    if (value.toString().toLowerCase().contains("null")) {
      return "";
    }
    return value;
  }

  List<Object> _toList(List array) {
    List<Object> list = new List();
    for (int i = 0; i < array.length; i++) {
      Object value = array.elementAt(i);
      if (value is List) {
        value = _toList(value);
      } else if (value is LinkedHashMap) {
        value = _toMap(value);
      }
      list.add(value);
    }
    return list;
  }
}
