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
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            block.content.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        );
      case 'subheading':
        return Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
          child: Text(
            block.content.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        );
      case 'contact':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Center(
            child: Text(
              block.content.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ),
        );
      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: SelectableText(
            block.content.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        );
      case 'list':
        final listItems =
            (block.content as List).map((e) => e.toString()).toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0, left: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    Expanded(
                      child: SelectableText(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
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
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(),
        );
      default:
        // Fallback for unknown block types
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: SelectableText(block.content.toString()),
        );
    }
  }
}
