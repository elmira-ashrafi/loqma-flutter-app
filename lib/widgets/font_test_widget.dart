import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/font_helper.dart';

class FontTestWidget extends StatelessWidget {
  const FontTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Font Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // English text test
            Text(
              'English Text - Poppins Font',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            
            // Pashto text test
            Text(
              'پښتو متن - نوتو کوفی عربک',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            
            // Dari text test
            Text(
              'متن دری - نوتو کوفی عربک',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            
            // Mixed content test
            Text(
              'English and پښتو mixed text',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            // Button tests
            ElevatedButton(
              onPressed: () {},
              child: const Text('English Button'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('پښتو بټن'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('دری بټن'),
            ),
            const SizedBox(height: 24),
            
            // Input field test
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter English text',
                labelText: 'English Label',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'پښتو متن داخل کړئ',
                labelText: 'پښتو لیبل',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'متن دری وارد کنید',
                labelText: 'لیبل دری',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
