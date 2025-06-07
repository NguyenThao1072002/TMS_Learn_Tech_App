import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/presentation/controller/language_controller.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageController = Provider.of<LanguageController>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngôn ngữ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn ngôn ngữ hiển thị',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thay đổi ngôn ngữ ứng dụng sẽ có hiệu lực ngay lập tức',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ...languageController.availableLanguages.map((language) {
              final bool isSelected = 
                  languageController.currentLocale.languageCode == language['code'];
              
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      languageController.setLanguage(language['code']);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Text(
                            language['flag'],
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            language['name'],
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              );
            }).toList(),
            const SizedBox(height: 24),
            _buildLanguageExample(context, languageController),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageExample(BuildContext context, LanguageController controller) {
    // Example texts in different languages
    final Map<String, Map<String, String>> examples = {
      'en': {
        'title': 'Language Example',
        'greeting': 'Hello, welcome to TMS Learn Tech!',
        'description': 'This is how the app will look in English.',
        'button': 'Continue'
      },
      'vi': {
        'title': 'Ví dụ ngôn ngữ',
        'greeting': 'Xin chào, chào mừng đến với TMS Learn Tech!',
        'description': 'Đây là cách ứng dụng sẽ hiển thị bằng tiếng Việt.',
        'button': 'Tiếp tục'
      }
    };
    
    // Get current language code
    final String langCode = controller.currentLocale.languageCode;
    final exampleTexts = examples[langCode] ?? examples['en']!;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              exampleTexts['title']!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exampleTexts['greeting']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exampleTexts['description']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: null, // Disabled in preview
                    child: Text(exampleTexts['button']!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
