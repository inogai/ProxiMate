import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/storage_service_wrapper.dart';
import '../config/profile_config.dart';
import '../widgets/tag_selector.dart';
import '../widgets/profile_image_picker.dart';

import 'main_screen.dart';

/// Profile setup screen where user enters additional information
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolController = TextEditingController();
  final _backgroundController = TextEditingController();
  
  List<String> _selectedMajors = [];
  List<String> _selectedInterests = [];
  String? _profileImagePath;

  @override
  void dispose() {
    _schoolController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Validate majors and interests
      if (_selectedMajors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one major'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      if (_selectedInterests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one interest'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final wrapper = StorageServiceWrapper(context);
      final success = await wrapper.updateProfile(
        school: _schoolController.text.trim(),
        major: _selectedMajors.join(', '),
        interests: _selectedInterests.join(', '),
        background: _backgroundController.text.trim(),
        profileImagePath: _profileImagePath,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<StorageService>().currentProfile?.userName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hi $userName!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us more about yourself',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ProfileImagePicker(
                    currentImagePath: _profileImagePath,
                    onImageSelected: (path) {
                      // // // debugPrint('ProfileSetupScreen - Image selected: $path');
                      setState(() {
                        _profileImagePath = path;
                      });
                      // // // debugPrint('ProfileSetupScreen - State updated with path: $_profileImagePath');
                    },
                    radius: 60,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _schoolController,
                  decoration: const InputDecoration(
                    labelText: 'School',
                    hintText: 'Enter your school name',
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your school';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                MultiTagSelector(
                  title: 'Major(s)',
                  availableTags: ProfileConfig.availableMajors,
                  selectedTags: _selectedMajors,
                  onSelected: (values) {
                    setState(() {
                      _selectedMajors = values;
                    });
                  },
                  maxSelection: ProfileConfig.maxMajorsSelection,
                ),
                const SizedBox(height: 16),
                MultiTagSelector(
                  title: 'Interests',
                  availableTags: ProfileConfig.availableInterests,
                  selectedTags: _selectedInterests,
                  onSelected: (values) {
                    setState(() {
                      _selectedInterests = values;
                    });
                  },
                  maxSelection: ProfileConfig.maxInterestsSelection,
                  allowCustom: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _backgroundController,
                  decoration: InputDecoration(
                    labelText: 'Background',
                    hintText: ProfileConfig.backgroundHintShort,
                    helperText: 'Include travel experiences, work, interesting facts',
                    helperMaxLines: 2,
                    prefixIcon: const Icon(Icons.history_edu),
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please share your background';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _handleSaveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Complete Profile',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
