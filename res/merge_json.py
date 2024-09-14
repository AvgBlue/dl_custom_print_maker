# res\\TextLabel.json
# res\\DragonData.json

import json

# Load the JSON files
with open('res\\DragonData.json', 'r') as dragon_file, open('res\\TextLabel.json', 'r') as text_label_file:
    dragon_data = json.load(dragon_file)
    text_label_data = json.load(text_label_file)

# Helper function to get the label from TextLabel based on ID
def get_text_label(label_id, text_label_data):
    return text_label_data.get(label_id, {}).get('_Text', '')

# Iterate over the entries in DragonData and replace _Name and _SecondName with corresponding labels
for dragon_entry in dragon_data['dict']['entriesValue']['Array']:
    # Get the _Name and _SecondName values (e.g., "DRAGON_NAME_20050415")
    name_key = dragon_entry.get('_Name', '')
    second_name_key = dragon_entry.get('_SecondName', '')

    # Replace the _Name with the corresponding label text from TextLabel.json
    if name_key:
        dragon_entry['_Name'] = get_text_label(name_key, text_label_data)
    
    # Replace the _SecondName with the corresponding label text from TextLabel.json
    if second_name_key:
        dragon_entry['_SecondName'] = get_text_label(second_name_key, text_label_data)

# Save the modified data back to a new JSON file
with open('ModifiedDragonData.json', 'w') as output_file:
    json.dump(dragon_data, output_file, indent=4)

print("DragonData has been successfully updated and saved to 'ModifiedDragonData.json'")
