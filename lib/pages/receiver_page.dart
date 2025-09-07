import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';

class ReceiverPage extends ConsumerStatefulWidget {
  const ReceiverPage({super.key});

  @override
  ConsumerState<ReceiverPage> createState() => _ReceiverPageState();
}

class _ReceiverPageState extends ConsumerState<ReceiverPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(requestsProvider.notifier).fetchRequests("receiver"));
    final socket = ref.read(socketServiceProvider);
    socket.connectAsReceiver(
      "http://10.0.2.2:5000",
      onCreated: (req) => ref.read(requestsProvider.notifier).upsertRequest(req),
      onUpdated: (req) => ref.read(requestsProvider.notifier).upsertRequest(req),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(requestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Receiver Dashboard")),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return ExpansionTile(
            title: Text("Request: ${req['id']}"),
            subtitle: Text("Status: ${req['status']}"),
            children: [
              ...(req['items'] as List<dynamic>).map((item) {
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text("Status: ${item['status']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          ref.read(requestsProvider.notifier)
                              .confirmItem(req['id'], item['id'], true);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          ref.read(requestsProvider.notifier)
                              .confirmItem(req['id'], item['id'], false);
                        },
                      ),
                    ],
                  ),
                );
              }).toList()
            ],
          );
        },
      ),
    );
  }
}
