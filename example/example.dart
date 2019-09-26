import 'package:dart_json_path/dart_json_path.dart';

main() {
  writeInJson();
  writeJsonInArray();
  readJson();
}

void writeJsonInArray() {
  var jsonPath = JsonPath.getInsatnce();
  var myJSON = '{ "name" : "vinay", "age":31, "city":"New York"}';
  var path = "\$.address[0].city";
  var nodeValue = "Agra";
  var outPut = jsonPath.write(myJSON, path, nodeValue);
  print(outPut);

  /// Output will be like this.
  ///{"name":"vinay","age":31,"city":"New York","address":[{"city":"Agra"}]}
}

void writeInJson() {
  var jsonPath = JsonPath.getInsatnce();
  var myJSON = '{ "age":31, "city":"New York"}';
  var path = "\$.name.firstName";
  var nodeValue = "Vinay";
  var outPut = jsonPath.write(myJSON, path, nodeValue);
  print(outPut);

  /// Output will be like this.
  /// {"age":31,"city":"New York","name":{"firstName":"Vinay"}}
}

void readJson() {
  var jsonPath = JsonPath.getInsatnce();
  var myJSON =
      '{"name":"vinay","age":31,"city":"New York","address":[{"city":"Agra"}]}';
  var path = "\$.address[0].city";
  var outPut = jsonPath.read(myJSON, path);
  print(outPut);

  ///output will be like this
  ///Agra
}
