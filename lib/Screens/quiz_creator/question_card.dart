import 'package:flutter/material.dart';

/// A stateless widget that displays the UI for editing a single question.
class QuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;
  final void Function(String field, dynamic value) onQuestionChanged;
  final void Function(String optionKey, String value) onOptionChanged;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onQuestionChanged,
    required this.onOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.grey[900], // Dark card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Question',
              initialValue: question["question"],
              onChanged: (value) => onQuestionChanged("question", value),
            ),
            const SizedBox(height: 12),
            ...question["options"].keys.map((key) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildTextField(
                  label: 'Option $key',
                  initialValue: question["options"][key],
                  onChanged: (value) => onOptionChanged(key, value),
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Correct Answer (Option Number)',
              keyboardType: TextInputType.number,
              initialValue: question["answer"].toString(),
              onChanged: (value) =>
                  onQuestionChanged("answer", int.tryParse(value) ?? 0),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Answer Explanation',
              initialValue: question["ansExplanation"],
              maxLines: 3,
              onChanged: (value) => onQuestionChanged("ansExplanation", value),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'Difficulty',
              value: ['Easy', 'Medium', 'Hard'].contains(question["difficulty"])
                  ? question["difficulty"]
                  : 'Easy', // Default to 'Easy' if invalid
              items: ['Easy', 'Medium', 'Hard'],
              onChanged: (value) => onQuestionChanged("difficulty", value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Marks',
                    keyboardType: TextInputType.number,
                    initialValue: question["marks"].toString(),
                    onChanged: (value) =>
                        onQuestionChanged("marks", int.tryParse(value) ?? 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Tags (comma separated)',
                    initialValue: question["tags"].join(", "),
                    onChanged: (value) => onQuestionChanged("tags",
                        value.split(',').map((tag) => tag.trim()).toList()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildImageUploadButton(context),
          ],
        ),
      ),
    );
  }

  /// Builds a dark-themed text field with rounded borders
  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white), // White text color
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.white70), // Slightly dimmed text
        filled: true,
        fillColor: Colors.grey[800], // Darker background
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: onChanged,
    );
  }

  /// Builds a dark-themed dropdown for selecting difficulty
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: Colors.grey[900], // Dark background for dropdown
      style: const TextStyle(color: Colors.white), // White text
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items
          .map((difficulty) => DropdownMenuItem(
                value: difficulty,
                child: Text(difficulty),
              ))
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }

  /// Builds an image upload button with dark mode styling
  Widget _buildImageUploadButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        // TODO: Implement Image Picker functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image Upload Not Implemented')),
        );
      },
      icon: const Icon(Icons.image, color: Colors.white70),
      label:
          const Text('Upload Image', style: TextStyle(color: Colors.white70)),
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[800],
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
