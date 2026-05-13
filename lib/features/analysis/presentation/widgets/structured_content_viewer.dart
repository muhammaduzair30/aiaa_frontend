import 'package:flutter/material.dart';
import '../../domain/entities/content_block_entity.dart';

class StructuredContentViewer extends StatelessWidget {
  final List<ContentBlockEntity> contentBlocks;

  const StructuredContentViewer({super.key, required this.contentBlocks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          contentBlocks.map((block) => _buildBlock(context, block)).toList(),
    );
  }

  Widget _buildBlock(BuildContext context, ContentBlockEntity block) {
    switch (block.type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                block.content.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEEDFE),
                  letterSpacing: -0.3,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 1.5,
                width: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF534AB7).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        );

      case 'subheading':
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF534AB7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.content.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFCECBF6),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        );

      case 'contact':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
            ),
            child: SelectableText(
              block.content.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8B82D4),
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );

      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SelectableText(
            block.content.toString(),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFAAAABB),
              height: 1.75,
              fontWeight: FontWeight.w400,
            ),
          ),
        );

      case 'list':
        final listItems =
            (block.content as List).map((e) => e.toString()).toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listItems.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF534AB7).withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SelectableText(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFAAAABB),
                          height: 1.65,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );

      case 'divider':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 0.5,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF534AB7).withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 0.5,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ],
          ),
        );

      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SelectableText(
            block.content.toString(),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
              height: 1.6,
            ),
          ),
        );
    }
  }
}
