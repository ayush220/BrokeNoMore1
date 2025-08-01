import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;
  String? _firstName;

  String? get firstName => _firstName;

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

      // Create auth user with auto-confirmation
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'full_name': '$firstName $lastName',
          'phone': phoneNumber,
          'email_confirm': true
        },
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
    _firstName = null;
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      print('Attempting to login with username: $username');

      // Get user details from accounts table
      final List<dynamic> records = await _client
          .from('accounts')
          .select('email, first_name')
          .eq('username', username)
          .limit(1);

      print('Found records: ${records.length}');

      if (records.isEmpty) {
        print('No user found with username: $username');
        throw Exception('Username not found');
      }

      final userRecord = records.first;
      final email = userRecord['email'] as String;

      // Sign in with email/password (required by Supabase)
      try {
        final response = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user == null) {
          throw Exception('Invalid credentials');
        }

        // Store the first name
        _firstName = userRecord['first_name'] as String;
        print('Login successful for user: $username');
      } catch (e) {
        print('Auth error: $e');
        // Always show invalid password regardless of the actual error
        throw Exception('Invalid username or password');
      }

    } catch (e) {
      print('Error in login: $e');
      rethrow;
    }
  }
}
