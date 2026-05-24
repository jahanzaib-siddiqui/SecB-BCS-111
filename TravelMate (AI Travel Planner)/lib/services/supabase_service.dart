import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  static SupabaseClient get client => _client;

  // ─── Current User ─────────────────────────────────────────────────────────────
  static User? get currentUser => _client.auth.currentUser;
  static String? get currentUserId => _client.auth.currentUser?.id;
  static bool get isLoggedIn => currentUser != null;

  // ─── Auth ─────────────────────────────────────────────────────────────────────
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: '${AppConstants.supabaseUrl}/auth/callback',
    );
  }

  // ─── User Profile ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    final data = await _client
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();
    return data;
  }

  static Future<void> upsertUserProfile(Map<String, dynamic> data) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _client
        .from('user_profiles')
        .upsert({'id': userId, ...data, 'updated_at': DateTime.now().toIso8601String()});
  }

  // ─── Trips ────────────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getTrips() async {
    final userId = currentUserId;
    if (userId == null) return [];
    return await _client
        .from('trips')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  static Future<Map<String, dynamic>> createTrip(
      Map<String, dynamic> tripData) async {
    final userId = currentUserId;
    final data = await _client
        .from('trips')
        .insert({
          'user_id': userId,
          ...tripData,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    return data;
  }

  static Future<void> updateTrip(
      String tripId, Map<String, dynamic> data) async {
    await _client
        .from('trips')
        .update({...data, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', tripId);
  }

  static Future<void> deleteTrip(String tripId) async {
    await _client.from('trips').delete().eq('id', tripId);
  }

  static Future<Map<String, dynamic>?> getTripById(String tripId) async {
    return await _client
        .from('trips')
        .select()
        .eq('id', tripId)
        .single();
  }

  // ─── Itineraries ──────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getItinerary(String tripId) async {
    return await _client
        .from('itinerary_days')
        .select('*, itinerary_activities(*)')
        .eq('trip_id', tripId)
        .order('day_number');
  }

  static Future<void> saveItinerary(
      String tripId, List<Map<String, dynamic>> days) async {
    await _client.from('itinerary_days').delete().eq('trip_id', tripId);
    for (final day in days) {
      final dayData = await _client
          .from('itinerary_days')
          .insert({
            'trip_id': tripId,
            'day_number': day['day_number'],
            'date': day['date'],
            'title': day['title'],
          })
          .select()
          .single();

      if (day['activities'] != null) {
        for (final activity in (day['activities'] as List)) {
          await _client.from('itinerary_activities').insert({
            'day_id': dayData['id'],
            ...activity,
          });
        }
      }
    }
  }

  // ─── Expenses ─────────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getExpenses(String tripId) async {
    return await _client
        .from('expenses')
        .select()
        .eq('trip_id', tripId)
        .order('date', ascending: false);
  }

  static Future<Map<String, dynamic>> addExpense(
      Map<String, dynamic> expense) async {
    return await _client
        .from('expenses')
        .insert({
          ...expense,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
  }

  static Future<void> updateExpense(
      String expenseId, Map<String, dynamic> data) async {
    await _client.from('expenses').update(data).eq('id', expenseId);
  }

  static Future<void> deleteExpense(String expenseId) async {
    await _client.from('expenses').delete().eq('id', expenseId);
  }

  // ─── Saved Hotels ──────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getSavedHotels(
      String tripId) async {
    return await _client
        .from('saved_hotels')
        .select()
        .eq('trip_id', tripId);
  }

  static Future<void> saveHotel(Map<String, dynamic> hotel) async {
    await _client.from('saved_hotels').upsert(hotel);
  }

  static Future<void> removeSavedHotel(String hotelId) async {
    await _client.from('saved_hotels').delete().eq('id', hotelId);
  }

  // ─── Saved Attractions ────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getSavedAttractions(
      String tripId) async {
    return await _client
        .from('saved_attractions')
        .select()
        .eq('trip_id', tripId);
  }

  static Future<void> saveAttraction(Map<String, dynamic> attraction) async {
    await _client.from('saved_attractions').upsert(attraction);
  }
}
