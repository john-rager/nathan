// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

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

  Workflow({required this.id, required this.name, required this.active, required this.updatedAt});

  factory Workflow.fromJson(Map<String, dynamic> j) => Workflow(
        id: j['id'] ?? j['uuid'] ?? '',
        name: j['name'] ?? '',
        active: j['active'] == true,
        updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
      );
}

class Execution {
  String id;
  String mode;
  String workflowId;
  DateTime startedAt;
  DateTime stoppedAt;
  String status;
  Map<String, dynamic> raw;

  Execution(
      {required this.id,
      required this.mode,
      required this.workflowId,
      required this.startedAt,
      required this.stoppedAt,
      required this.status,
      required this.raw});

  factory Execution.fromJson(Map<String, dynamic> j) => Execution(
        id: j['id']?.toString() ?? '',
        mode: j['mode']?.toString() ?? '',
        workflowId: j['workflowId']?.toString() ?? '',
        startedAt: DateTime.tryParse(j['startedAt']) ?? DateTime.now(),
        stoppedAt: DateTime.tryParse(j['stoppedAt']) ?? DateTime.now(),
        status: j['status'] ?? '',
        raw: j,
      );
}
