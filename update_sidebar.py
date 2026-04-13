import os

file1 = r'd:\HHTechHUB\MetaBrass-pos\frontend\lib\presentation\widgets\globals\sidebar.dart'
with open(file1, 'r', encoding='utf-8') as f:
    text = f.read()
text = text.replace("{'icon': Icons.settings_rounded, 'title': l10n.settings, 'badge': null},",
                    "{'icon': Icons.description_rounded, 'title': 'Quotations', 'badge': null},\n      {'icon': Icons.settings_rounded, 'title': l10n.settings, 'badge': null},")
with open(file1, 'w', encoding='utf-8') as f:
    f.write(text)

file2 = r'd:\HHTechHUB\MetaBrass-pos\frontend\lib\presentation\widgets\dashboard\dashboard_content.dart'
with open(file2, 'r', encoding='utf-8') as f:
    text2 = f.read()

text2 = text2.replace("import '../../screens/zakat/zakat_screen.dart';", "import '../../screens/zakat/zakat_screen.dart';\nimport '../../screens/quotation/quotation_list_screen.dart';")
text2 = text2.replace("case 19:\n        return const SettingsScreen();", "case 19:\n        return const QuotationListScreen();\n      case 20:\n        return const SettingsScreen();")
text2 = text2.replace("case 19:\r\n        return const SettingsScreen();", "case 19:\r\n        return const QuotationListScreen();\r\n      case 20:\r\n        return const SettingsScreen();")
text2 = text2.replace("AppLocalizations.of(context)!.receipts,\n      AppLocalizations.of(context)!.settings,", "AppLocalizations.of(context)!.receipts,\n      'Quotations',\n      AppLocalizations.of(context)!.settings,")
text2 = text2.replace("AppLocalizations.of(context)!.receipts,\r\n      AppLocalizations.of(context)!.settings,", "AppLocalizations.of(context)!.receipts,\r\n      'Quotations',\r\n      AppLocalizations.of(context)!.settings,")

with open(file2, 'w', encoding='utf-8') as f:
    f.write(text2)
