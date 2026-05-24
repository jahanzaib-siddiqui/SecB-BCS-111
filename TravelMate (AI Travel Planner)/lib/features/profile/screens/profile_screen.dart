import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/common_widgets.dart';

import '../../../services/supabase_service.dart';
import '../../auth/screens/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _homeCtrl = TextEditingController();
  String _favCurrency = 'PKR';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _homeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await SupabaseService.getUserProfile();
      final user = SupabaseService.currentUser;
      if (mounted) {
        setState(() {
          _nameCtrl.text = profile?['full_name'] ?? user?.userMetadata?['full_name'] ?? '';
          _phoneCtrl.text = profile?['phone'] ?? '';
          _homeCtrl.text = profile?['home_city'] ?? '';
          _favCurrency = profile?['preferred_currency'] ?? 'PKR';
        });
      }
    } catch (_) {}
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await SupabaseService.upsertUserProfile({
        'full_name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'home_city': _homeCtrl.text.trim(),
        'preferred_currency': _favCurrency,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved!'), backgroundColor: AppColors.success));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
    finally { if (mounted) setState(() => _isSaving = false); }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true) {
      await SupabaseService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    final name = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'User';
    final email = user?.email ?? '';
    final initials = name.isNotEmpty ? name.substring(0, name.length > 1 ? 2 : 1).toUpperCase() : 'U';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.bgGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text('Profile', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w800, color: context.textPrimary)),
                    const SizedBox(height: 24),

                    // Avatar
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
                            child: Center(child: Text(initials, style: const TextStyle(fontFamily: 'Poppins', fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white))),
                          ).animate().scale(curve: Curves.elasticOut),
                          const SizedBox(height: 12),
                          Text(name, style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
                          Text(email, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: context.textHint)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Edit Profile
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.glassBorder)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personal Details', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _nameCtrl,
                            style: TextStyle(color: context.textPrimary, fontFamily: 'Poppins'),
                            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline, color: AppColors.textHint)),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: context.textPrimary, fontFamily: 'Poppins'),
                            decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textHint)),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _homeCtrl,
                            style: TextStyle(color: context.textPrimary, fontFamily: 'Poppins'),
                            decoration: const InputDecoration(labelText: 'Home City', prefixIcon: Icon(Icons.home_outlined, color: AppColors.textHint)),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _favCurrency,
                            dropdownColor: Theme.of(context).colorScheme.surface,
                            decoration: const InputDecoration(labelText: 'Preferred Currency', prefixIcon: Icon(Icons.attach_money, color: AppColors.textHint)),
                            style: TextStyle(color: context.textPrimary, fontFamily: 'Poppins', fontSize: 14),
                            items: ['PKR', 'USD', 'EUR', 'GBP', 'AED', 'SAR'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) => setState(() => _favCurrency = v!),
                          ),
                          const SizedBox(height: 16),
                          GradientButton(label: 'Save Profile', isLoading: _isSaving, onPressed: _saveProfile),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Settings & Info
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.glassBorder,
                        ),
                        boxShadow: Theme.of(context).brightness == Brightness.light
                            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))]
                            : [],
                      ),
                      child: Column(
                        children: [
                           _ThemeToggleRow(),
                          Divider(
                            color: context.glassBorder,
                            height: 1,
                            indent: 56,
                          ),
                          _SettingsRow(icon: Icons.info_outline, label: 'About TravelMate', color: AppColors.primary, onTap: () => _showAbout()),
                          Divider(color: context.glassBorder, height: 1, indent: 56),
                          _SettingsRow(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', color: AppColors.accent, onTap: () {}),
                          Divider(color: context.glassBorder, height: 1, indent: 56),
                          _SettingsRow(icon: Icons.star_outline, label: 'Rate TravelMate', color: AppColors.warning, onTap: () {}),
                          Divider(color: context.glassBorder, height: 1, indent: 56),
                          _SettingsRow(icon: Icons.logout, label: 'Sign Out', color: AppColors.error, onTap: _signOut),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Center(child: Text('TravelMate v1.0.0\nMade with ❤️ for Travelers', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.textHint, height: 1.6))),
                    const SizedBox(height: 40),
                  ],
                ),
        ),
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About TravelMate'),
        content: const Text('TravelMate is your AI-powered personal travel companion. Plan trips, track expenses, discover hotels & attractions — all in one place.\n\nVersion 1.0.0\nSemester Project'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SettingsRow({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final hintColor = isDark ? AppColors.textHint : AppColorsLight.textHint;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: textColor))),
            Icon(Icons.arrow_forward_ios, size: 14, color: hintColor),
          ],
        ),
      ),
    );
  }
}

// ─── Theme Toggle Row ──────────────────────────────────────────────────────────
class _ThemeToggleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final isDark = provider.isDark;
    final textColor = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final hintColor = isDark ? AppColors.textHint : AppColorsLight.textHint;

    return GestureDetector(
      onTap: provider.toggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.primaryGradient : AppColors.sunsetGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
                  ),
                  Text(
                    isDark ? 'Switch to light theme' : 'Switch to dark theme',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: hintColor),
                  ),
                ],
              ),
            ),
            // Custom animated toggle
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 48,
              height: 26,
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.primaryGradient : AppColors.sunsetGradient,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.primary : AppColors.accent).withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: isDark ? 24 : 2,
                    top: 2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                        size: 13,
                        color: isDark ? AppColors.primary : AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

