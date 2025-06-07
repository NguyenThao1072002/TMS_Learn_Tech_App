# Localization System

This directory contains the localization files for the TMS Learn Tech App. The app supports both English and Vietnamese languages.

## Files Structure

- `app_en.arb`: English localization strings
- `app_vi.arb`: Vietnamese localization strings

## How to Use

### 1. Add new strings

To add a new string to the localization system:

1. Add the string to both `app_en.arb` and `app_vi.arb` files with the same key
2. Use proper translation for each language

Example:
```json
// In app_en.arb
{
  "newFeature": "New Feature"
}

// In app_vi.arb
{
  "newFeature": "Tính năng mới"
}
```

### 2. Use in your Flutter code

Import the localization extension:
```dart
import 'package:tms_app/core/localization/app_localization.dart';
```

Use the extension method on BuildContext:
```dart
// In a widget
Text(context.tr('newFeature'))
```

Or use the localization object directly:
```dart
final localizations = AppLocalizations.of(context);
if (localizations != null) {
  Text(localizations.translate('newFeature'))
}
```

## Best Practices

1. Always add strings to both language files
2. Use meaningful keys that reflect the content
3. Keep translations consistent across the app
4. Group related strings together in the ARB files
5. For placeholder text, use the ICU message format:

```json
{
  "greeting": "Hello {name}",
  "@greeting": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

## Rebuilding the App

After modifying the localization files, you may need to restart your app to see the changes. 