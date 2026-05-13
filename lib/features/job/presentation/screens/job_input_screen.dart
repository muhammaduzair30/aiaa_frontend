import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/job_cubit.dart';

class JobInputScreen extends StatefulWidget {
  const JobInputScreen({super.key});

  @override
  State<JobInputScreen> createState() => _JobInputScreenState();
}

class _JobInputScreenState extends State<JobInputScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _rawTextController = TextEditingController();
  final _urlController = TextEditingController();
  final _sourceUrlController = TextEditingController();
  int _activeTab = 0;
  bool _titleFocused = false;
  bool _textFocused = false;
  bool _urlFocused = false;
  bool _sourceUrlFocused = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() => _activeTab = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _rawTextController.dispose();
    _urlController.dispose();
    _sourceUrlController.dispose();
    super.dispose();
  }

  void _onScrapePressed() {
    if (_urlController.text.isNotEmpty) {
      context.read<JobCubit>().scrapeJob(_urlController.text);
    }
  }

  void _onSaveJobPressed() {
    if (_rawTextController.text.isNotEmpty) {
      final sourceUrl =
          _activeTab == 0 ? _sourceUrlController.text : _urlController.text;
      context.read<JobCubit>().createJob(
            _titleController.text.isNotEmpty ? _titleController.text : null,
            _rawTextController.text,
            sourceUrl.isNotEmpty ? sourceUrl : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      body: BlocConsumer<JobCubit, JobState>(
        listener: (context, state) {
          if (state is JobError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(color: Color(0xFFEEEDFE)),
                ),
                backgroundColor: const Color(0xFF1A1730),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is JobScraped) {
            _rawTextController.text = state.text;
            _sourceUrlController.text = _urlController.text;
            _tabController.animateTo(0);
            setState(() => _activeTab = 0);
          } else if (state is JobCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF1D9E75),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Job saved successfully!',
                      style: TextStyle(color: Color(0xFFEEEDFE)),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF1A1730),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            context.pop(state.job);
          }
        },
        builder: (context, state) {
          final isLoading = state is JobLoading;

          return SafeArea(
            child: isWeb
                ? _buildWebLayout(isLoading)
                : _buildMobileLayout(isLoading),
          );
        },
      ),
    );
  }

  // ─── Web Layout ─────────────────────────────────────────────────────────────

  Widget _buildWebLayout(bool isLoading) {
    return Row(
      children: [
        // Left: form
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildHeader(isWeb: true),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: _buildFormContent(isLoading: isLoading, isWeb: true),
                  ),
                ),
              ),
              _buildSaveBar(isLoading: isLoading, isWeb: true),
            ],
          ),
        ),
        // Right: tips panel
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.white.withOpacity(0.06),
                width: 0.5,
              ),
            ),
          ),
          child: const _TipsPanel(),
        ),
      ],
    );
  }

  // ─── Mobile Layout ───────────────────────────────────────────────────────────

  Widget _buildMobileLayout(bool isLoading) {
    return Column(
      children: [
        _buildHeader(isWeb: false),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _buildFormContent(isLoading: isLoading, isWeb: false),
          ),
        ),
        _buildSaveBar(isLoading: isLoading, isWeb: false),
      ],
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader({required bool isWeb}) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 32 : 20,
        isWeb ? 28 : 16,
        isWeb ? 32 : 20,
        isWeb ? 20 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1E),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 0.5,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF8B82D4),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Job',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEEDFE),
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Paste a description or import from URL',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7089)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Form Content ────────────────────────────────────────────────────────────

  Widget _buildFormContent({required bool isLoading, required bool isWeb}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title field
        _buildFieldLabel('Job title'),
        const SizedBox(height: 8),
        _buildAnimatedField(
          controller: _titleController,
          hint: 'e.g. Senior Flutter Developer (optional)',
          icon: Icons.work_outline_rounded,
          isFocused: _titleFocused,
          onFocusChange: (v) => setState(() => _titleFocused = v),
        ),
        const SizedBox(height: 24),

        // Tab switcher
        _buildTabSwitcher(),
        const SizedBox(height: 16),

        // Tab content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _activeTab == 0
              ? _buildPasteTab(isWeb: isWeb)
              : _buildUrlTab(isLoading: isLoading),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ─── Tab Switcher ────────────────────────────────────────────────────────────

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: Row(
        children: [
          _buildTabPill(
            label: 'Paste text',
            icon: Icons.content_paste_rounded,
            isActive: _activeTab == 0,
            onTap: () {
              _tabController.animateTo(0);
              setState(() => _activeTab = 0);
            },
          ),
          _buildTabPill(
            label: 'From URL',
            icon: Icons.link_rounded,
            isActive: _activeTab == 1,
            onTap: () {
              _tabController.animateTo(1);
              setState(() => _activeTab = 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF534AB7).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF534AB7).withOpacity(0.4)
                  : Colors.transparent,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isActive
                    ? const Color(0xFF8B82D4)
                    : const Color(0xFF4A4E6A),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFFEEEDFE)
                      : const Color(0xFF4A4E6A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Paste Tab ───────────────────────────────────────────────────────────────

  Widget _buildPasteTab({required bool isWeb}) {
    return Column(
      key: const ValueKey('paste'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isWeb ? 280 : 200,
          decoration: BoxDecoration(
            color: _textFocused
                ? const Color(0xFF534AB7).withOpacity(0.06)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _textFocused
                  ? const Color(0xFF534AB7).withOpacity(0.5)
                  : Colors.white.withOpacity(0.08),
              width: 0.5,
            ),
          ),
          child: Focus(
            onFocusChange: (v) => setState(() => _textFocused = v),
            child: TextField(
              controller: _rawTextController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                color: Color(0xFFEEEDFE),
                fontSize: 14,
                height: 1.6,
              ),
              decoration: const InputDecoration(
                hintText:
                    'Paste the full job description here...\n\nInclude responsibilities, requirements and any other relevant details for the best AI analysis.',
                hintStyle: TextStyle(
                  color: Color(0xFF4A4E6A),
                  fontSize: 13,
                  height: 1.6,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildFieldLabel('Source URL (Optional)'),
        const SizedBox(height: 8),
        _buildAnimatedField(
          controller: _sourceUrlController,
          hint: 'e.g. https://boards.greenhouse.io/...',
          icon: Icons.link_rounded,
          isFocused: _sourceUrlFocused,
          onFocusChange: (v) => setState(() => _sourceUrlFocused = v),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  // ─── URL Tab ─────────────────────────────────────────────────────────────────

  Widget _buildUrlTab({required bool isLoading}) {
    return Column(
      key: const ValueKey('url'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Job URL'),
        const SizedBox(height: 8),
        _buildAnimatedField(
          controller: _urlController,
          hint: 'https://boards.greenhouse.io/...',
          icon: Icons.link_rounded,
          isFocused: _urlFocused,
          onFocusChange: (v) => setState(() => _urlFocused = v),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),

        // Scrape button
        isLoading
            ? _buildLoadingBar('Fetching job description...')
            : GestureDetector(
                onTap: _onScrapePressed,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF534AB7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF534AB7).withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: Color(0xFF8B82D4),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Import job description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B82D4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

        const SizedBox(height: 16),

        // Scraping Notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF378ADD).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF378ADD).withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF378ADD),
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Automated extraction works best on platforms that permit scraping. Sites with aggressive bot-protection may require you to use the "Paste text" tab.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: const Color(0xFFEEEDFE).withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Save Bar ────────────────────────────────────────────────────────────────

  Widget _buildSaveBar({required bool isLoading, required bool isWeb}) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 40 : 20,
        16,
        isWeb ? 40 : 20,
        isWeb ? 24 : 28,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1E),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
      ),
      child: isLoading
          ? _buildLoadingBar('Saving...')
          : GestureDetector(
              onTap: _onSaveJobPressed,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63E0), Color(0xFF534AB7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF534AB7).withOpacity(0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_add_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Save Job',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Widget _buildFieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: Color(0xFF6B7089),
      ),
    );
  }

  Widget _buildAnimatedField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isFocused,
    required ValueChanged<bool> onFocusChange,
    TextInputType? keyboardType,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        color: isFocused
            ? const Color(0xFF534AB7).withOpacity(0.08)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused
              ? const Color(0xFF534AB7).withOpacity(0.6)
              : Colors.white.withOpacity(0.09),
          width: 0.5,
        ),
      ),
      child: Focus(
        onFocusChange: onFocusChange,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFFEEEDFE), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4A4E6A), fontSize: 14),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF534AB7)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBar(String message) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF534AB7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF534AB7).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: Color(0xFF8B82D4),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8B82D4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tips Panel (web sidebar) ─────────────────────────────────────────────────

class _TipsPanel extends StatelessWidget {
  const _TipsPanel();

  @override
  Widget build(BuildContext context) {
    final tips = [
      (
        icon: Icons.content_paste_rounded,
        title: 'Full description',
        body:
            'Include the complete job posting for the most accurate AI match score.',
        color: const Color(0xFF534AB7),
      ),
      (
        icon: Icons.link_rounded,
        title: 'URL import',
        body:
            'Paste a direct URL from supported platforms or company career pages to auto-extract.',
        color: const Color(0xFF378ADD),
      ),
      (
        icon: Icons.title_rounded,
        title: 'Add a title',
        body:
            'A job title helps you find the listing quickly in your saved jobs.',
        color: const Color(0xFF1D9E75),
      ),
      (
        icon: Icons.insights_rounded,
        title: 'Run analysis after',
        body: 'Once saved, match this job against any CV to get an AI score.',
        color: const Color(0xFFEF9F27),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Tips',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEEEDFE),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: t.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(t.icon, color: t.color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEEEDFE),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.body,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7089),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
