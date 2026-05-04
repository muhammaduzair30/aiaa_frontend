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

class _CVUploadScreenState extends State<CVUploadScreen> {
  List<int>? _selectedFileBytes;
  String? _selectedFileName;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload CV')),
      body: BlocConsumer<CVCubit, CVState>(
        listener: (context, state) {
          if (state is CVUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('CV Uploaded Successfully!')),
            );
            context.go('/cv/list');
          } else if (state is CVError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Select CV (PDF, DOCX)'),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedFileBytes != null && _selectedFileName != null)
                    Text(
                      'Selected: $_selectedFileName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 32),
                  if (state is CVUploading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed:
                          _selectedFileBytes == null ? null : _uploadFile,
                      child: const Text('Upload'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
