import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

const baseUrl = "http://10.0.2.2:5000";

final socketServiceProvider = Provider<SocketService>((ref) {
  final svc = SocketService();
  ref.onDispose(svc.dispose);
  return svc;
});

final requestsProvider = StateNotifierProvider<RequestNotifier, List<dynamic>>((ref) {
  return RequestNotifier(ref);
});

class RequestNotifier extends StateNotifier<List<dynamic>> {
  final Ref ref;
  RequestNotifier(this.ref) : super([]);

  Future<void> fetchRequests(String role, {String? userId}) async {
    final result = await ApiService.fetchRequests(role, userId: userId);
    state = result;
  }

  Future<void> createRequest(String userId, List<String> items) async {
    await ApiService.createRequest(userId, items);
    // ✅ Even if socket fails, refresh from backend
    await fetchRequests("enduser", userId: userId);
  }

  Future<void> confirmItem(String requestId, String itemId, bool available) async {
    final request = await ApiService.confirmItem(requestId, itemId, available);
    // ✅ Even if socket fails, refresh receiver’s list
    await fetchRequests("receiver");
  }

  void upsertRequest(Map<String, dynamic> req) {
    final idx = state.indexWhere((r) => r['id'] == req['id']);
    if (idx == -1) {
      state = [...state, req];
    } else {
      final copy = [...state];
      copy[idx] = req;
      state = copy;
    }
  }
}
