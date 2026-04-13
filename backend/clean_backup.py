import json

def clean_backup(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # List of models to exclude
    exclude_models = [
        'contenttypes.contenttype',
        'auth.permission',
        'admin.logentry',
        'sessions.session',
        'authtoken.token'
    ]
    
    cleaned_data = [item for item in data if item['model'] not in exclude_models]
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(cleaned_data, f, indent=4)
    
    print(f"Cleaned backup saved to {output_file}")
    print(f"Original items: {len(data)}")
    print(f"Cleaned items: {len(cleaned_data)}")

if __name__ == "__main__":
    clean_backup('backup_20260131_185930.json', 'cleaned_backup.json')
