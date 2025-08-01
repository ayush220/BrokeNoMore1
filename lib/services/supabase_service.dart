import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  Future<void> initialize(String url, String anonKey) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }

  Future<bool> isUsernameAvailable(String username) async {
    final response = await _client
        .from('accounts')
        .select()
        .eq('username', username)
        .maybeSingle();
    return response == null;
  }

  Future<void> createAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String username,
    required String password,
  }) async {
    try {
      // Validate email format
      if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
          .hasMatch(email)) {
        throw Exception('Invalid email format');
      }

      // Validate username format
      if (!RegExp(r'^[A-Za-z0-9_]{3,20}$').hasMatch(username)) {
        throw Exception(
            'Username must be 3-20 characters long and contain only letters, numbers, and underscores');
      }

      // Check if username is available
      final isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        throw Exception('Username is already taken');
      }

      // Create auth user
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      final userId = authResponse.user!.id;
      print('User created with ID: $userId');

      // Create account record
      await _client.from('accounts').insert({
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'username': username,
      }).select();

      print('Account created successfully for user: $userId');
    } catch (e) {
      print('Error in createAccount: $e');
      throw Exception('Failed to create account: $e');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
