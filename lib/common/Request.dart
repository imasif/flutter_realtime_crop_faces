
import 'package:http/http.dart' as http;
import 'dart:convert';
class Request {
    final String url;
    final dynamic body;
    Map<String, String> headers = {"Content-type": "application/json"};
   
    Request({this.url, this.body});
  
    _responseData(response){
      final int statusCode = response.statusCode;
      String data = response.body;
      if (statusCode < 200 || statusCode > 400 || data == null) {
        throw new Exception("Error while fetching data");
      }
  
      return json.decode(data);
    }
   
    get get async {
  
      // make request;
      dynamic response = await http.get(url,headers:headers);
      return _responseData(response);
      
    }
  
    post() async {
  
      // make request;
      dynamic response = await http.post(url, headers: headers,  body: json.encode(body));
      return _responseData(response);
      
    }

    formPost() async {
      
      // make request;
      var uri = Uri.parse(url);
      var request = new http.MultipartRequest("POST", uri);
      request.fields['data'] = json.encode(body);
      dynamic response = await request.send();
      String bytedata = await response.stream.bytesToString();

      var res = new http.Response(bytedata,response.statusCode);
      return _responseData(res);      
    }
    
}
