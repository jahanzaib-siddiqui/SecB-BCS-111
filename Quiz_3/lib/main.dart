import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/submission_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Define Supabase credentials (using the verified ones)
  const String supabaseUrl = 'https://xaehfolfkeclfjdmpyew.supabase.co';
  const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhZWhmb2xma2VjbGZqZG1weWV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NDMxNzksImV4cCI6MjA5NDQxOTE3OX0.aGiDvuyfhC4LtpSd5ANVSsdRykBLL9mhtTNzVG8fwc0';

  // Initialize Supabase client
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Set system overlay styling for transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const Quiz3App());
}

class Quiz3App extends StatelessWidget {
  const Quiz3App({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate a cohesive premium color scheme
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1), // Premium Indigo accent
      primary: const Color(0xFF6366F1),
      secondary: const Color(0xFF8B5CF6), // Purple accent
      tertiary: const Color(0xFF14B8A6), // Teal accent
      surface: const Color(0xFFF9FAFB),
      error: const Color(0xFFEF4444),
      brightness: Brightness.light,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      primary: const Color(0xFF8B5CF6),
      secondary: const Color(0xFF6366F1),
      tertiary: const Color(0xFF14B8A6),
      surface: const Color(0xFF0F172A), // Premium Slate/Navy dark background
      error: const Color(0xFFF87171),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Quiz 3 - Submission Form',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Auto adapt to user's system preferences
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        scaffoldBackgroundColor: lightColorScheme.surface,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          labelStyle: GoogleFonts.outfit(color: Colors.grey.shade600),
          floatingLabelStyle: GoogleFonts.outfit(
            color: const Color(0xFF6366F1),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: darkColorScheme.surface,
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155), width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
          ),
          labelStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
          floatingLabelStyle: GoogleFonts.outfit(
            color: const Color(0xFF8B5CF6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const SubmissionListScreen(),
    );
  }
}
