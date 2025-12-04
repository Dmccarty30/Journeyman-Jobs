import 'package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart';
import 'package:journeyman_jobs/services/local_model_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_ai_model_provider.g.dart';

@Riverpod(keepAlive: true)
LocalModelService localModelService(Ref ref) {
  // This will be a singleton instance available throughout the app.
  return LocalModelService();
}

@riverpod
Future<void> modelInitializer(Ref ref) async {
  // This provider handles the asynchronous initialization of the model.
  // UI can watch this provider to show a loading indicator while the model loads.
  final modelService = ref.watch(localModelServicePodProvider);
  await modelService.loadModel();
}
