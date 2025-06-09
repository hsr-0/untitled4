import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:untitled4/data/models/models.dart';
import '../models/chief_model.dart';

class ApiService {
  static const String baseUrl = 'https://myselfe.beytei.com/wp-json/maktabat/v1';
  static const int timeoutSeconds = 15;

  final http.Client client;

  ApiService({required this.client});

  // التحويل الآمن
  static String safeString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static int safeInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static List<T> safeList<T>(dynamic list, T Function(dynamic) mapper, [List<T> defaultValue = const []]) {
    if (list is! List) return defaultValue;
    try {
      return list.map(mapper).whereType<T>().toList();
    } catch (e) {
      return defaultValue;
    }
  }

  Future<Map<String, dynamic>> _fetchData(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final response = await client.get(uri).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw HttpException('Request failed with status: ${response.statusCode}', uri: uri);
      }
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت');
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال بالخادم');
    } on FormatException {
      throw Exception('خطأ في تنسيق البيانات المستلمة');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  Future<List<Office>> getOffices() async {
    try {
      final data = await _fetchData('offices');
      if (data['success'] != true) throw Exception(data['message'] ?? 'فشل في تحميل المكاتب');
      return safeList<Office>(data['data']['offices'], (json) => Office.fromJson(json));
    } catch (e) {
      throw Exception('خطأ في تحويل بيانات المكاتب: ${e.toString()}');
    }
  }

  Future<List<Representation>> getRepresentations() async {
    try {
      final data = await _fetchData('representations');
      if (data['success'] != true) throw Exception(data['message'] ?? 'فشل في تحميل الممثليات');
      return safeList<Representation>(data['data'], (json) => Representation.fromJson(json));
    } catch (e) {
      throw Exception('خطأ في تحويل بيانات الممثليات: ${e.toString()}');
    }
  }

  Future<Representation> getRepresentationDetails(String id) async {
    try {
      final data = await _fetchData('representation/$id');
      if (data['success'] != true) throw Exception(data['message'] ?? 'فشل في تحميل التفاصيل');
      return Representation.fromJson(data['data']);
    } catch (e) {
      throw Exception('خطأ في تحويل تفاصيل الممثلية: ${e.toString()}');
    }
  }

  Future<List<Region>> searchRegions(String query) async {
    try {
      final data = await _fetchData('search?s=${Uri.encodeQueryComponent(query)}');
      if (data['success'] != true) throw Exception(data['message'] ?? 'فشل في البحث');
      return safeList<Region>(data['data']['regions'], (json) => Region.fromJson(json));
    } catch (e) {
      throw Exception('خطأ في تحويل نتائج البحث: ${e.toString()}');
    }
  }

  Future<List<Chief>> getChiefs({required int page}) async {
    try {
      final data = await _fetchData('chiefs');
      if (data['success'] != true) throw Exception(data['message'] ?? 'فشل في تحميل الرؤساء');
      return safeList<Chief>(data['data']['chiefs'], (json) => Chief.fromJson(json));
    } catch (e) {
      throw Exception('خطأ في تحويل بيانات الرؤساء: ${e.toString()}');
    }
  }



  /// ✅ دالة جلب جميع الزعماء مع ناخبيهم
  Future<Chief> getChiefDetails(int id) async {
    try {
      final data = await _fetchData('chiefs/$id'); // تأكد من أن المسار صحيح
      if (data['success'] != true) throw Exception(data['message'] ?? 'فشل في تحميل التفاصيل');

      final chief = Chief.fromJson(data['data']);
      chief.voters = safeList<Voter>(data['data']['voters'], (json) => Voter.fromJson(json)); // تحميل الناخبين
      return chief;
    } catch (e) {
      throw Exception('خطأ في تحميل تفاصيل الرئيس: ${e.toString()}');
    }
  }
}


