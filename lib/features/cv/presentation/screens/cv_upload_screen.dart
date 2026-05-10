import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/cv_cubit.dart';

class CVUploadScreen extends StatefulWidget {
  const CVUploadScreen({super.key});

  @override
  State<CVUploadScreen> createState() => _CVUploadScreenState();
}

class _CVUploadScreenState extends State<CVUploadScreen>
    with SingleTickerProviderStateMixin {
  List<int>? _selectedFileBytes;
  String? _selectedFileName;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFileBytes = result.files.single.bytes;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  void _uploadFile() {
    if (_selectedFileBytes != null && _selectedFileName != null) {
      context.read<CVCubit>().uploadCV(_selectedFileBytes!, _selectedFileName!);
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFileBytes = null;
      _selectedFileName = null;
    });
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  bool get _isPdf => _selectedFileName?.toLowerCase().endsWith('.pdf') ?? false;

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      body: BlocConsumer<CVCubit, CVState>(
        listener: (context, state) {
          if (state is CVUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Color(0xFF1D9E75), size: 18),
                    SizedBox(width: 10),
                    Text('CV uploaded successfully!',
                        style: TextStyle(color: Color(0xFFEEEDFE))),
                  ],
                ),
                backgroundColor: const Color(0xFF1A1730),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
            context.go('/cv/list');
          } else if (state is CVError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message,
                    style: const TextStyle(color: Color(0xFFEEEDFE))),
                backgroundColor: const Color(0xFF1A1730),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isUploading = state is CVUploading;

          return Stack(
            children: [
              // Background glows
              Positioned(
                top: -120,
                right: -80,
                child: _GlowCircle(
                    size: 380, color: const Color(0xFF534AB7), opacity: 0.14),
              ),
              Positioned(
                bottom: -80,
                left: -60,
                child: _GlowCircle(
                    size: 300, color: const Color(0xFF1D9E75), opacity: 0.1),
              ),

              // Main content
              Column(
                children: [
                  // Header
                  _UploadHeader(isWeb: isWeb),

                  // Body
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isWeb ? 48 : 24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: isWeb ? 560 : double.infinity),
                          child: Column(
                            children: [
                              // Drop zone / file picker
                              _selectedFileName == null
                                  ? _DropZone(
                                      onTap: _pickFile,
                                      pulseAnimation: _pulseAnimation,
                                      isWeb: isWeb,
                                    )
                                  : _FilePreview(
                                      fileName: _selectedFileName!,
                                      fileSize: _formatSize(
                                          _selectedFileBytes!.length),
                                      isPdf: _isPdf,
                                      onClear: _clearFile,
                                      onReplace: _pickFile,
                                    ),

                              const SizedBox(height: 32),

                              // Tips card
                              if (_selectedFileName == null)
                                _TipsCard(isWeb: isWeb),

                              if (_selectedFileName != null) ...[
                                // Upload button
                                isUploading
                                    ? _UploadingIndicator()
                                    : _GradientButton(
                                        onPressed: _uploadFile,
                                        label: 'Upload CV',
                                        icon: Icons.cloud_upload_outlined,
                                      ),
                                const SizedBox(height: 16),
                                // Cancel
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF4A4E6A),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _UploadHeader extends StatelessWidget {
  final bool isWeb;
  const _UploadHeader({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 32 : 20,
        isWeb ? 32 : 56,
        isWeb ? 32 : 20,
        isWeb ? 24 : 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1E),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white.withOpacity(0.08), width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF8B82D4), size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Upload CV',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEEDFE),
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'PDF or DOCX · Max 10MB',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7089)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Drop Zone ────────────────────────────────────────────────────────────────

class _DropZone extends StatelessWidget {
  final VoidCallback onTap;
  final Animation<double> pulseAnimation;
  final bool isWeb;

  const _DropZone({
    required this.onTap,
    required this.pulseAnimation,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: pulseAnimation.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          height: isWeb ? 280 : 240,
          decoration: BoxDecoration(
            color: const Color(0xFF534AB7).withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF534AB7).withOpacity(0.3),
              width: 1.5,
              // Dashed border via CustomPainter below
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon container
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF534AB7).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: Color(0xFF8B82D4),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Drop your CV here',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEEEDFE),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'or tap to browse files',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7089)),
              ),
              const SizedBox(height: 20),
              // Format pills
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FormatPill(label: 'PDF'),
                  const SizedBox(width: 8),
                  _FormatPill(label: 'DOCX'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatPill extends StatelessWidget {
  final String label;
  const _FormatPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF534AB7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF534AB7).withOpacity(0.25), width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B82D4),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── File Preview ─────────────────────────────────────────────────────────────

class _FilePreview extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final bool isPdf;
  final VoidCallback onClear;
  final VoidCallback onReplace;

  const _FilePreview({
    required this.fileName,
    required this.fileSize,
    required this.isPdf,
    required this.onClear,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPdf ? const Color(0xFFE24B4A) : const Color(0xFF378ADD);
    final label = isPdf ? 'PDF' : 'DOCX';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
      ),
      child: Column(
        children: [
          // Success checkmark
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1D9E75).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF1D9E75), size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'File selected',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEEEDFE),
            ),
          ),
          const SizedBox(height: 20),
          // File info row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
            ),
            child: Row(
              children: [
                // Type badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEEEDFE),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        fileSize,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF6B7089)),
                      ),
                    ],
                  ),
                ),
                // Clear button
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Color(0xFF6B7089), size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Replace link
          GestureDetector(
            onTap: onReplace,
            child: const Text(
              'Replace file →',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7C74E0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tips Card ────────────────────────────────────────────────────────────────

class _TipsCard extends StatelessWidget {
  final bool isWeb;
  const _TipsCard({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final tips = [
      (
        icon: Icons.check_circle_outline_rounded,
        text: 'Use a clean, ATS-friendly format',
        color: const Color(0xFF1D9E75),
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        text: 'Include keywords from the job description',
        color: const Color(0xFF1D9E75),
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        text: 'Keep it to 1–2 pages for best results',
        color: const Color(0xFF1D9E75),
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        text: 'PDF format recommended for accuracy',
        color: const Color(0xFF1D9E75),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D9E75).withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF1D9E75).withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: Color(0xFF1D9E75), size: 16),
              SizedBox(width: 8),
              Text(
                'Tips for better AI analysis',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D9E75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(tip.icon, color: tip.color, size: 14),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip.text,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFAAAABB),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Uploading Indicator ──────────────────────────────────────────────────────

class _UploadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF534AB7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF534AB7).withOpacity(0.2), width: 0.5),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: Color(0xFF8B82D4),
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Uploading...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B82D4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const _GradientButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Glow Circle ──────────────────────────────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowCircle(
      {required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }
}
