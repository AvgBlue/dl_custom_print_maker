import json

# Load data from both files
with open('CharaData_filtered.json') as chara_file, open('abilitiesTextDescriptions.json') as abilities_file:
    chara_data = json.load(chara_file)
    abilities_data = json.load(abilities_file)

# Function to update abilities with "BelongsTo"
def add_belongsto(chara_data, abilities_data):
    for chara_id, chara in chara_data.items():
        # Get the character's name or both name and second name
        if chara["_Name"] == chara["_SecondName"]:
            chara_name = chara["_Name"]
        else:
            chara_name = f'{chara["_Name"]}, {chara["_SecondName"]}'
        
        # List of abilities attributes to check
        ability_fields = [
            "_Abilities11", "_Abilities12", "_Abilities13", "_Abilities14",
            "_Abilities21", "_Abilities22", "_Abilities23", "_Abilities24",
            "_Abilities31", "_Abilities32", "_Abilities33", "_Abilities34",
            "_ExAbility2Data1", "_ExAbility2Data2", "_ExAbility2Data3", 
            "_ExAbility2Data4", "_ExAbility2Data5"
        ]
        
        # For each ability field, check if it's valid and not zero
        for field in ability_fields:
            ability_id = chara.get(field, 0)
            if ability_id != 0 and str(ability_id) in abilities_data:
                ability_entry = abilities_data[str(ability_id)]
                
                # Add "BelongsTo" attribute or update it
                if "BelongsTo" not in ability_entry:
                    ability_entry["BelongsTo"] = set()
                ability_entry["BelongsTo"].add(chara_name)
    
    # Convert sets back to lists for JSON serialization
    for ability in abilities_data.values():
        if "BelongsTo" in ability:
            ability["BelongsTo"] = list(ability["BelongsTo"])

# Add the "BelongsTo" attribute
add_belongsto(chara_data, abilities_data)

# Save the updated abilities file
with open('updated_abilitiesTextDescriptions.json', 'w') as updated_abilities_file:
    json.dump(abilities_data, updated_abilities_file, indent=4)
