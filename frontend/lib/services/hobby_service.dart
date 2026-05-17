import '../models/hobby.dart';
import 'api_client.dart';

class HobbyService {
  static Future<List<Hobby>> list() async {
    final res = await ApiClient.dio.get('/hobbies');
    return (res.data as List)
        .map((e) => Hobby.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Hobby> create(Map<String, dynamic> data) async {
    final res = await ApiClient.dio.post('/hobbies', data: data);
    return Hobby.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<Hobby> update(String id, Map<String, dynamic> data) async {
    final res = await ApiClient.dio.put('/hobbies/$id', data: data);
    return Hobby.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<void> delete(String id) async {
    await ApiClient.dio.delete('/hobbies/$id');
  }
}
