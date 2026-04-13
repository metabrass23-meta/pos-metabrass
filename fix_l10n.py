import os

files = ['d:/HHTechHUB/MetaBrass-pos/frontend/lib/l10n/app_en.arb', 'd:/HHTechHUB/MetaBrass-pos/frontend/lib/l10n/app_ur.arb']

replacements_en = {
    '"fabricType": "Fabric Type"': '"fabricType": "Material Type"',
    '"fabricName": "Fabric Name"': '"fabricName": "Material Name"',
    '"allFabrics": "All Fabrics"': '"allFabrics": "All Materials"',
    '"enterFabric": "Enter fabric"': '"enterFabric": "Enter material"',
    '"fabric": "Fabric"': '"fabric": "Material"',
    '"enterFabricType": "Enter fabric type (e.g., Cotton, Silk, Chiffon)"': '"enterFabricType": "Enter material type (e.g., Brass, Steel, PVC)"',
    '"pleaseEnterFabric": "Please enter a fabric"': '"pleaseEnterFabric": "Please enter a material"',
    '"fabricNameMustBeAtLeast2Characters": "Fabric name must be at least 2 characters"': '"fabricNameMustBeAtLeast2Characters": "Material name must be at least 2 characters"',
    '"searchProductsByNameFabricOrColor": "Search products by name, fabric, or color..."': '"searchProductsByNameFabricOrColor": "Search products by name, material, or color..."',
    '"embroideryWork": "Embroidery Work"': '"embroideryWork": "Premium Finish"',
    '"embroidery": "Embroidery"': '"embroidery": "Finish"',
    '"fabricQuality": "Fabric Quality"': '"fabricQuality": "Material Quality"',
    '"customTailoring": "Custom Tailoring"': '"customTailoring": "Industrial Grade"',
    '"slimFit": "Slim Fit"': '"slimFit": "Standard Flow"',
    '"setSizeQualityEmbroidery": "Set size, quality, embroidery, and options"': '"setSizeQualityEmbroidery": "Set size, quality, finish, and options"',
}

replacements_ur = {
    '"fabricType": "کپڑے کی قسم"': '"fabricType": "مٹیریل کی قسم"',
    '"fabricName": "کپڑے کا نام"': '"fabricName": "مٹیریل کا نام"',
    '"allFabrics": "تمام کپڑے"': '"allFabrics": "تمام مٹیریلز"',
    '"enterFabric": "کپڑا درج کریں"': '"enterFabric": "مٹیریل درج کریں"',
    '"fabric": "کپڑا"': '"fabric": "مٹیریل"',
    '"enterFabricType": "کپڑے کی قسم درج کریں (مثلاً: کاٹن، ریشم، شیفون)"': '"enterFabricType": "مٹیریل کی قسم درج کریں (مثلاً: پیتل، سٹیل)"',
    '"pleaseEnterFabric": "براہ کرم کپڑا درج کریں"': '"pleaseEnterFabric": "براہ کرم مٹیریل درج کریں"',
    '"fabricNameMustBeAtLeast2Characters": "کپڑے کا نام کم از کم 2 حروف کا ہونا چاہیے"': '"fabricNameMustBeAtLeast2Characters": "مٹیریل کا نام کم از کم 2 حروف کا ہونا چاہیے"',
    '"searchProductsByNameFabricOrColor": "نام، کپڑے یا رنگ کے ذریعے پروڈکٹس تلاش کریں..."': '"searchProductsByNameFabricOrColor": "نام، مٹیریل یا رنگ کے ذریعے پروڈکٹس تلاش کریں..."',
    '"embroideryWork": "کڑھائی کا کام"': '"embroideryWork": "پریمیم فنش"',
    '"embroidery": "کڑھائی"': '"embroidery": "فنش"',
    '"fabricQuality": "کپڑے کا معیار"': '"fabricQuality": "مٹیریل کا معیار"',
    '"customTailoring": "اپنی مرضی کی درزی"': '"customTailoring": "انڈسٹریل گریڈ"',
    '"slimFit": "سلم فٹ"': '"slimFit": "سٹینڈرڈ فلو"',
    '"setSizeQualityEmbroidery": "سائز، معیار، کڑھائی اور اختیارات مقرر کریں"': '"setSizeQualityEmbroidery": "سائز، معیار، فنش اور اختیارات مقرر کریں"'
}

for file_path in files:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        reps = replacements_en if 'en.arb' in file_path else replacements_ur
        for old, new in reps.items():
            content = content.replace(old, new)
            
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Successfully updated {os.path.basename(file_path)}')
    except Exception as e:
        print(f'Error processing {file_path}: {e}')
