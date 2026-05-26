import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/submission_model.dart';
import '../services/supabase_service.dart';
import 'submission_form_screen.dart';

class SubmissionListScreen extends StatefulWidget {
  const SubmissionListScreen({super.key});

  @override
  State<SubmissionListScreen> createState() => _SubmissionListScreenState();
}

class _SubmissionListScreenState extends State<SubmissionListScreen> {
  List<SubmissionModel> _submissions = [];
  List<SubmissionModel> _filteredSubmissions = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Fetch submissions from Supabase
  Future<void> _fetchSubmissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await SupabaseService.getSubmissions();
      setState(() {
        _submissions = data;
        _filterList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Handle Search Input Changes
  void _onSearchChanged() {
    _filterList();
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredSubmissions = List.from(_submissions);
      } else {
        _filteredSubmissions = _submissions.where((sub) {
          return sub.fullName.toLowerCase().contains(query) ||
              sub.email.toLowerCase().contains(query) ||
              sub.phoneNumber.toLowerCase().contains(query) ||
              sub.address.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // Delete Submission Dialog and Action
  Future<void> _confirmDelete(SubmissionModel submission) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Delete',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete the submission for "${submission.fullName}"? This action cannot be undone.',
            style: GoogleFonts.outfit(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await SupabaseService.deleteSubmission(submission.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Submission deleted successfully',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchSubmissions(); // Refresh the list
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete submission: $e'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Gender Badge Styles
  Widget _buildGenderBadge(String gender) {
    Color badgeColor;
    Color textColor;

    switch (gender.toLowerCase()) {
      case 'male':
        badgeColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        break;
      case 'female':
        badgeColor = const Color(0xFFFDF2F8);
        textColor = const Color(0xFFDB2777);
        break;
      default:
        badgeColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF16A34A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        gender,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Header with App Title & Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Submissions',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'Supabase Database Records',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      // Refresh Action
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 26),
                        onPressed: _fetchSubmissions,
                        tooltip: 'Refresh Records',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or phone...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? _buildErrorState()
                  : _filteredSubmissions.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchSubmissions,
                      color: theme.colorScheme.primary,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0,
                        ),
                        itemCount: _filteredSubmissions.length,
                        itemBuilder: (context, index) {
                          final submission = _filteredSubmissions[index];
                          return _buildSubmissionCard(submission);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubmissionFormScreen(),
            ),
          );
          if (result == true) {
            _fetchSubmissions(); // Refresh the list after new entry is added
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Entry',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  // Error State View
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Database Connection Error',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchSubmissions,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Retry Connection',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Empty State View
  Widget _buildEmptyState() {
    final query = _searchController.text;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                query.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.folder_open_rounded,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              query.isNotEmpty ? 'No Matches Found' : 'No Submissions Yet',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              query.isNotEmpty
                  ? 'No database records match your search criteria. Try a different query.'
                  : 'The submissions table is empty. Tap the button below to submit the first record.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Submission Card Widget
  Widget _buildSubmissionCard(SubmissionModel submission) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: theme.cardTheme.shape is RoundedRectangleBorder
            ? Border.fromBorderSide((theme.cardTheme.shape as RoundedRectangleBorder).side)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header of Card (Name + Gender Badge)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      submission.fullName,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildGenderBadge(submission.gender),
                ],
              ),
              const SizedBox(height: 12),

              // Email Detail
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      submission.email,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Phone Detail
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    submission.phoneNumber,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Address Detail
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Icon(
                      Icons.home_outlined,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      submission.address,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
              ),
              const SizedBox(height: 8),

              // Card Actions (Edit, Delete)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SubmissionFormScreen(submission: submission),
                        ),
                      );
                      if (result == true) {
                        _fetchSubmissions(); // Refresh the list
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      'Edit',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(submission),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    label: Text(
                      'Delete',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
