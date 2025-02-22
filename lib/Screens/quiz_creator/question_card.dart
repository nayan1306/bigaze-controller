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
    // Wrap in a Card for visual separation.
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Question Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => onQuestionChanged("question", value),
            ),
            const SizedBox(height: 10),
            ...question["options"].keys.map((key) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Option $key',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => onOptionChanged(key, value),
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Correct Answer (Option Number)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  onQuestionChanged("answer", int.tryParse(value) ?? 0),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Answer Explanation',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => onQuestionChanged("ansExplanation", value),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Difficulty (easy, medium, hard)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => onQuestionChanged("difficulty", value),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => onQuestionChanged("imageUrl", value),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Marks',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  onQuestionChanged("marks", int.tryParse(value) ?? 0),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => onQuestionChanged(
                  "tags", value.split(',').map((tag) => tag.trim()).toList()),
            ),
          ],
        ),
      ),
    );
  }
}
