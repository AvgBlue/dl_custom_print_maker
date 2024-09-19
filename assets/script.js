const fileInput = document.getElementById('fileInput');
const downloadBtn = document.getElementById('downloadBtn');
const addButton = document.getElementById('addButton');

let jsonData;

// Function to read and parse file content
function parseFileToJson(file) {
    const reader = new FileReader();
    // Define what happens when the file is read
    reader.onload = function (event) {
        const fileContent = event.target.result;
        // Assuming the file content is JSON, parse it
        try {
            jsonData = JSON.parse(fileContent);
        } catch (error) {
            console.error('Error parsing JSON:', error);
        }
    };
    // Read the file as text
    reader.readAsText(file);
}

// Handle file selection
fileInput.addEventListener('change', function () {
    if (fileInput.files.length > 0) {
        parseFileToJson(fileInput.files[0]);
    }
});

const createTalisman = function (key_id, talisman_id, ability_id_1, ability_id_2, ability_id_3, additional_hp, additional_attack, gettime) {
    return {
        "talisman_key_id": key_id,
        "talisman_id": talisman_id,
        "is_lock": 0,
        "is_new": 1,
        "talisman_ability_id_1": ability_id_1,
        "talisman_ability_id_2": ability_id_2,
        "talisman_ability_id_3": ability_id_3,
        "additional_hp": additional_hp,
        "additional_attack": additional_attack,
        "gettime": gettime
    };
};

let add_talisman = function (talisman_id, ability_id_1, ability_id_2, ability_id_3) {
    if (jsonData.data.talisman_list) {
        let talismanList = jsonData.data.talisman_list;
        const lastTalisman = talismanList[talismanList.length - 1];
        let talisman = createTalisman(lastTalisman.talisman_key_id + 100, talisman_id, ability_id_1, ability_id_2, ability_id_3, 0, 0, lastTalisman.gettime + 1);
        talismanList.push(talisman);
    }
}

// Handle file download
downloadBtn.addEventListener('click', function () {
    if (jsonData) {
        // Convert jsonData to a JSON string and create a Blob
        const jsonString = JSON.stringify(jsonData, null, 2);
        const blob = new Blob([jsonString], { type: 'application/json' });

        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;

        a.download = `output.json`;
        a.click();

        // Revoke the object URL after downloading
        URL.revokeObjectURL(url);
    }
});

// Function to populate dropdown menu from character_data.json
function populateCharacterDropdown() {
    fetch('character_data.json')
        .then(response => response.json())
        .then(data => {
            const characterSelect = document.getElementById('characterSelect');

            // Sort the data by title alphabetically
            data.sort((a, b) => a.title.localeCompare(b.title));

            // Populate the dropdown menu with sorted data
            data.forEach(character => {
                const option = document.createElement('option');
                option.value = character.talisman_id; // Set the talisman_id as the value
                option.textContent = character.title;
                characterSelect.appendChild(option);
            });
        })
        .catch(error => console.error('Error fetching character data:', error));
}

// Handle the "Add" button click event
addButton.addEventListener('click', function () {
    // Get the selected talisman_id from the dropdown menu
    const selectedTalismanId = parseInt(document.getElementById('characterSelect').value);

    // Get the selected number of copies from the dropdown menu
    const numCopies = parseInt(document.getElementById('copiesSelect').value);

    // Get the values of the abilities from the input fields
    const ability1 = parseInt(document.getElementById('ability1').value);
    const ability2 = parseInt(document.getElementById('ability2').value);
    const ability3 = parseInt(document.getElementById('ability3').value);

    // Check if jsonData and character_data are loaded
    if (jsonData && jsonData.data && jsonData.data.talisman_list) {
        // Run the add_talisman function k times
        for (let i = 0; i < numCopies; i++) {
            add_talisman(selectedTalismanId, ability1, ability2, ability3);
        }
    } else {
        console.error('jsonData not loaded or invalid structure');
    }
});

// Call the function to populate the dropdown when the page loads
document.addEventListener('DOMContentLoaded', populateCharacterDropdown);
