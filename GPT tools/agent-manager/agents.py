import os
import openai

# Constants
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
OPENAI_CLIENT = openai.Client(api_key=OPENAI_API_KEY)
ASSISTANTS_DIR = "agent-instructions"

def print_assistant_info(assistant, extended=False):
    print(f"Assistant ID: {assistant.id}\tName: {assistant.name}\tCreated at timestamp: {assistant.created_at}\tModel: {assistant.model}\tDescription: {assistant.description if hasattr(assistant, 'description') else 'No description'}")
    if extended:
        print("\nInstructions/Description:")
        print(assistant.instructions if hasattr(assistant, 'instructions') else 'No instructions')

def list_assistants():
    try:
        assistants = OPENAI_CLIENT.beta.assistants.list().data
        if assistants:
            print("Available Assistants:")
            print("ID\tName")
            for assistant in assistants:
                print(f"{assistant.id}\t{assistant.name}")
        else:
            print("No assistants available.")
    except Exception as e:
        print(f"Error listing assistants: {str(e)}")

def create_assistant(name, description, instructions=None):
    assistant_params = {
        "name": name,
        "description": description,
        "model": "gpt-3.5-turbo-1106"
    }
    if instructions:
        assistant_params["instructions"] = instructions

    try:
        new_assistant = OPENAI_CLIENT.beta.assistants.create(**assistant_params)
        print_assistant_info(new_assistant)
    except Exception as e:
        print(f"Error creating assistant: {str(e)}")

def update_assistant(id, name, description):
    try:
        updated_assistant = OPENAI_CLIENT.beta.assistants.update(id, name=name, description=description)
        print_assistant_info(updated_assistant)
    except Exception as e:
        print(f"Error updating assistant: {str(e)}")

def delete_assistant(id):
    try:
        response = OPENAI_CLIENT.beta.assistants.delete(id)
        print(f"Deleted Assistant: {id}")
    except Exception as e:
        print(f"Error deleting assistant: {str(e)}")

def delete_all_assistants():
    confirm = input("Are you sure you want to delete all assistants? (yes/no): ").lower()
    if confirm == "yes":
        try:
            assistants = OPENAI_CLIENT.beta.assistants.list().data
            for assistant in assistants:
                OPENAI_CLIENT.beta.assistants.delete(assistant.id)
            print("All assistants have been deleted.")
        except Exception as e:
            print(f"Error deleting all assistants: {str(e)}")
    else:
        print("Deletion canceled.")

def load_instructions_from_file(filename):
    try:
        with open(filename, 'r') as file:
            return file.read()
    except FileNotFoundError:
        print(f"File '{filename}' not found.")
        return None

def get_assistant_details(id, extended=False):
    try:
        assistant = OPENAI_CLIENT.beta.assistants.retrieve(id)
        print_assistant_info(assistant, extended)
    except Exception as e:
        print(f"Error fetching details for assistant {id}: {str(e)}")

# Create a directory for agent instructions if it doesn't exist
if not os.path.exists(ASSISTANTS_DIR):
    os.makedirs(ASSISTANTS_DIR)

while True:
    command = input("Please enter a command (list, create, update, delete, deleteall, info [-e], quit): ")
    command_parts = command.split()
    base_command = command_parts[0].lower()
    extended = "-e" in command_parts

    if base_command == 'quit':
        break
    elif base_command == 'list':
        list_assistants()
    elif base_command == 'create':
        available_instruction_files = os.listdir(ASSISTANTS_DIR)
        if available_instruction_files:
            print("Available instruction files:")
            for i, file in enumerate(available_instruction_files, start=1):
                print(f"{i}. {file}")
            name = input("Enter the name of the new assistant: ")
            description = input("Enter the description: ")
            file_index = int(input("Enter the index of the instruction file (or 0 for none): "))
            instructions = None
            if 0 < file_index <= len(available_instruction_files):
                instructions_file = available_instruction_files[file_index - 1]
                instructions = load_instructions_from_file(os.path.join(ASSISTANTS_DIR, instructions_file))
            create_assistant(name, description, instructions)
        else:
            print("No instruction files available in 'agent-instructions' directory.")
    elif base_command == 'update':
        id = input("Enter the ID of the assistant to update: ")
        name = input("Enter the new name: ")
        description = input("Enter the new description: ")
        update_assistant(id, name, description)
    elif base_command == 'delete':
        id_to_delete = input("Enter the ID of the assistant to delete: ")
        delete_assistant(id_to_delete)
    elif base_command == 'deleteall':
        delete_all_assistants()
    elif base_command == 'info':
        id = input("Enter the ID of the assistant to get more information: ")
        get_assistant_details(id, extended)
    else:
        print("Invalid command. Please enter one of the following: list, create, update, delete, deleteall, info [-e], quit.")
