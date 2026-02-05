import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

// Set to true to use CORS proxy for development (temporary fix)
// Set to false for production (requires Cloudflare Worker or proper CORS config)
const bool useCorsProxy = false;
const String corsProxyUrl = 'https://thingproxy.freeboard.io/fetch';

class ApiService {
  final InstanceConfig instance;

  ApiService(this.instance);

  Map<String, String> get _headers =>
      {'X-N8N-API-KEY': instance.apiKey, 'Accept': 'application/json'};

  Uri _uri(String path, [Map<String, String>? query]) {
    final baseUrl = instance.url.replaceAll(RegExp(r'\/+$'), '');
    final fullUrl = '$baseUrl/api/v1/$path';
    
    if (useCorsProxy) {
      // Route through CORS proxy for development
      return Uri.parse('$corsProxyUrl/$fullUrl')
          .replace(queryParameters: query);
    } else {
      // Direct request (production with Cloudflare Worker)
      return Uri.parse(fullUrl).replace(queryParameters: query);
    }
  }

  Future<List<Workflow>> fetchWorkflows() async {
    final res = await http.get(_uri('workflows'), headers: _headers);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final list = (data is List) ? data : (data['data'] ?? []);
      return List<Workflow>.from(list.map((e) => Workflow.fromJson(e)));
    }
    print('Workflows API Error: ${res.statusCode} - ${res.body}');
    print('Headers sent: $_headers');
    throw Exception(
        'Failed to fetch workflows: ${res.statusCode} - ${res.reasonPhrase}');
  }

  Future<List<Execution>> fetchExecutions({String? workflowId}) async {
    final query = <String, String>{};
    if (workflowId != null && workflowId.isNotEmpty)
      query['workflowId'] = workflowId;
    final res = await http.get(_uri('executions', query), headers: _headers);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final list = (data is List) ? data : (data['data'] ?? []);
      final parsed =
          List<Execution>.from(list.map((e) => Execution.fromJson(e)));
      parsed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return parsed;
    }
    print('Executions API Error: ${res.statusCode} - ${res.body}');
    print('Headers sent: $_headers');
    throw Exception(
        'Failed to fetch executions: ${res.statusCode} - ${res.reasonPhrase}');
  }
}
