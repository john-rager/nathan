class InstanceConfig {
  String name;
  String url;
  String apiKey;

  InstanceConfig({required this.name, required this.url, required this.apiKey});

  factory InstanceConfig.fromJson(Map<String, dynamic> j) => InstanceConfig(
        name: j['name'] ?? '',
        url: j['url'] ?? '',
        apiKey: j['apiKey'] ?? '',
      );

  Map<String, dynamic> toJson() => {'name': name, 'url': url, 'apiKey': apiKey};
}

class Workflow {
  String id;
  String name;
  bool active;
  DateTime updatedAt;

  Workflow(
      {required this.id,
      required this.name,
      required this.active,
      required this.updatedAt});

  factory Workflow.fromJson(Map<String, dynamic> j) => Workflow(
        id: j['id'] ?? j['uuid'] ?? '',
        name: j['name'] ?? '',
        active: j['active'] == true,
        updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
      );
}

class Execution {
  String id;
  String workflowId;
  DateTime createdAt;
  String status;
  Map<String, dynamic> raw;

  Execution(
      {required this.id,
      required this.workflowId,
      required this.createdAt,
      required this.status,
      required this.raw});

  factory Execution.fromJson(Map<String, dynamic> j) => Execution(
        id: j['id']?.toString() ?? '',
        workflowId: j['workflowId']?.toString() ??
            (j['workflow']?['id']?.toString() ?? ''),
        createdAt: DateTime.tryParse(j['createdAt'] ?? j['finishedAt'] ?? '') ??
            DateTime.now(),
        status: j['status'] ?? '',
        raw: j,
      );
}
