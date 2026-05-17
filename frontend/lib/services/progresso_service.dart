import '../models/progresso.dart';
import 'api_client.dart';

class ProgressoService {
  static Future<List<Progresso>> list(String hobbyId) async {
    final res = await ApiClient.dio.get('/hobbies/$hobbyId/progresso');
    return (res.data as List)
        .map((e) => Progresso.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Progresso> create(
      String hobbyId, Map<String, dynamic> data) async {
    final res =
        await ApiClient.dio.post('/hobbies/$hobbyId/progresso', data: data);
    return Progresso.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<void> delete(String id) async {
    await ApiClient.dio.delete('/progresso/$id');
  }
}
