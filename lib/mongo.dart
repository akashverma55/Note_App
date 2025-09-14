import 'dart:convert';
import 'package:http/http.dart' as http;

class MongoService{

  static const baseURL = "http://10.0.2.2:8000";

  static Future<List<dynamic>> getNotes() async{
    final response = await http.get(Uri.parse("$baseURL/notes"));
    if(response.statusCode==200){
      return json.decode(response.body);
    }
    else{
      throw Exception("Failed to load notes");
    }
  }

  static Future<Map<String,dynamic>> addNote(String title, String description) async{
    final response = await http.post(
      Uri.parse("$baseURL/notes"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"title":title,"description":description})
    );
    if(response.statusCode==200){
      return json.decode(response.body);
    }
    else{
      throw Exception("Failed to add note");
    }
  }


  static Future<Map<String,dynamic>> updateNote(String id, String title, String description) async{
    final response = await http.put(
      Uri.parse("$baseURL/notes/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"title": title,"description": description})
    );
    if(response.statusCode==200){
      return json.decode(response.body);
    }
    else{
      throw Exception("Failed to update note");
    }
  }

  static Future<void> deleteNote(String id) async{
    final response = await http.delete(Uri.parse("$baseURL/notes/$id"));
    if(response.statusCode!=200){
      throw Exception("Failed to delete note");
    }
  }
}