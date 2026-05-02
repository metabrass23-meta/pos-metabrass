import json
import re

file_path = r'd:\HHTechHUB\MetaBrass-pos\frontend\lib\l10n\app_en.arb'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

changed = False
for key, value in data.items():
    if isinstance(value, str) and not key.startswith('@'):
        original = value
        # Replace 'Labor' with 'Labour'
        value = re.sub(r'\bLabor\b', 'Labour', value)
        value = re.sub(r'\blabor\b', 'labour', value)
        value = re.sub(r'\bLabors\b', 'Labours', value)
        value = re.sub(r'\blabors\b', 'labours', value)
        if value != original:
            data[key] = value
            changed = True
    elif isinstance(value, dict) and key.startswith('@'):
        if 'description' in value:
            original = value['description']
            desc = original
            desc = re.sub(r'\bLabor\b', 'Labour', desc)
            desc = re.sub(r'\blabor\b', 'labour', desc)
            desc = re.sub(r'\bLabors\b', 'Labours', desc)
            desc = re.sub(r'\blabors\b', 'labours', desc)
            if desc != original:
                value['description'] = desc
                changed = True

if changed:
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print("Updated app_en.arb successfully.")
else:
    print("No changes made.")
