import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission_model.dart';

class SupabaseService {
  // Get the Supabase client instance
  static final SupabaseClient _client = Supabase.instance.client;

  // Table name in Supabase
  static const String _tableName = 'submissions';

  // Create (Insert a new submission)
  static Future<SubmissionModel> createSubmission(
    SubmissionModel submission,
  ) async {
    final response = await _client
        .from(_tableName)
        .insert(submission.toJson())
        .select()
        .single();

    return SubmissionModel.fromJson(response);
  }

  // Read (Fetch all submissions)
  static Future<List<SubmissionModel>> getSubmissions() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => SubmissionModel.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  // Update (Modify an existing submission)
  static Future<void> updateSubmission(SubmissionModel submission) async {
    if (submission.id == null) {
      throw ArgumentError('Submission ID cannot be null for updating.');
    }

    await _client
        .from(_tableName)
        .update(submission.toJson())
        .eq('id', submission.id!);
  }

  // Delete (Remove a submission by ID)
  static Future<void> deleteSubmission(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}
