import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';

class EndUserPage extends ConsumerStatefulWidget {
  final String userId;
  const EndUserPage({super.key, required this.userId});

  @override
  ConsumerState<EndUserPage> createState() => _EndUserPageState();
}

class _EndUserPageState extends ConsumerState<EndUserPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(requestsProvider.notifier).fetchRequests("enduser", userId: widget.userId));
    final socket = ref.read(socketServiceProvider);
    socket.connectAsEndUser(
      "http://10.0.2.2:5000",
      widget.userId,
      onCreated: (req) => ref.read(requestsProvider.notifier).upsertRequest(req),
      onUpdated: (req) => ref.read(requestsProvider.notifier).upsertRequest(req),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(requestsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("End User Dashboard")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(requestsProvider.notifier)
                      .createRequest(widget.userId, ["Item A", "Item B"]);
                  print("✅ Request created successfully");
                } catch (e) {
                  print("❌ Error creating request: $e");
                }
              },
              child: const Text("Create Request (Sample Items)"),
            ),

          ),
          Expanded(
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (_, i) {
                final req = requests[i];
                return Card(
                  child: ListTile(
                    title: Text("Request ID: ${req['id']}"),
                    subtitle: Text("Status: ${req['status']}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
