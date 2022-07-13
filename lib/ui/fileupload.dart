import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;

// Upload(File imageFile) async {
//   var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
//   var length = await imageFile.length();
//
//   var uri = Uri.parse(imageurl);
//
//   var request = new http.MultipartRequest("POST", uri);
//   var multipartFile = new http.MultipartFile('file', stream, length,
//       filename: basename(imageFile.path));
//   //contentType: new MediaType('image', 'png'));
//
//   request.files.add(multipartFile);
//   var response = await request.send();
//   print(response.statusCode);
//   response.stream.transform(utf8.decoder).listen((value) {
//     print(value);
//   });
// }


_asyncFileUpload(String text, File file) async{
  //create multipart request for POST or PATCH method
  var request = http.MultipartRequest("POST", Uri.parse("<url>"));
  //add text fields
  request.fields["text_field"] = text;
  //create multipart using filepath, string or bytes
  var pic = await http.MultipartFile.fromPath("file_field", file.path);
  //add multipart to request
  request.files.add(pic);
  var response = await request.send();

  //Get the response from the server
  var responseData = await response.stream.toBytes();
  var responseString = String.fromCharCodes(responseData);
  print(responseString);
}
