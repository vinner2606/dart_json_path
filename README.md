# dart_json_path

A new Flutter package.

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.


var jsonPath = JsonPath.getInsatnce();
  var myJSON = '{ "age":31, "city":"New York"}';
  var path = "\$.name.firstName";
  var nodeValue = "Vinay";
  var outPut = jsonPath.write(myJSON, path, nodeValue);
  print(outPut);

  /// Output will be like this.
  /// {"age":31,"city":"New York","name":{"firstName":"Vinay"}}

   var jsonPath = JsonPath.getInsatnce();
  var myJSON = '{ "name" : "vinay", "age":31, "city":"New York"}';
  var path = "\$.address[0].city";
  var nodeValue = "Agra";
  var outPut = jsonPath.write(myJSON, path, nodeValue);
  print(outPut);

  /// Output will be like this.
  ///{"name":"vinay","age":31,"city":"New York","address":[{"city":"Agra"}]}


  var jsonPath = JsonPath.getInsatnce();
  var myJSON =
      '{"name":"vinay","age":31,"city":"New York","address":[{"city":"Agra"}]}';
  var path = "\$.address[0].city";
  var outPut = jsonPath.read(myJSON, path);
  print(outPut);
  ///output will be like this
  ///Agra
