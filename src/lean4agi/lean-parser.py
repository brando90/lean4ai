import json

def convert_proof_to_string_format(proof):
    """
    Convert a single theorem proof into the specified string format.
    """

    formatted_proof = f"{proof['full_name']}" # adding thm name

    for step in proof['traced_tactics']:
        proof_state_before = step['state_before'].replace('\n', ' ').strip()
        # proof_state_after = step['state_after'].replace('\n', ' ').strip()
        tactic = step['tactic']
        formatted_proof += f" {deliminter} {proof_state_before} {deliminter} {tactic}"
    formatted_proof += f" {deliminter} Qed"
    return formatted_proof

def convert_proofs_in_file(file_path):
    """
    Read a JSON file containing theorem proofs and convert each proof into the specified format.
    """
    return_json = []
    no_tactics = []

    with open(file_path, 'r') as file:
        data = json.load(file)

    total_proofs = len(data)
    counter = 0

    for proof in data:
        counter += 1
        print(f"Processing proof {counter} of {total_proofs}\n")

        if proof['traced_tactics'] == []:
            no_tactics.append(proof['full_name'])
            continue

        formal_proof = convert_proof_to_string_format(proof)

        return_json.append({"formal": formal_proof, "informal": ""})
    metadata = {"total_valid_proofs": total_proofs, "total_no_tactics": len(no_tactics), "deliminter": deliminter, "no_tactics": no_tactics}

    return (return_json, metadata)

deliminter = "**"

file_name = "novel_premises/train"  # change input file name here
file_path = file_name + '.json'
(formatted_proofs, metadata) = convert_proofs_in_file(file_path)

file_output = file_name + "_formal_informal.json"
metadata_output = file_name + "_formal_informal_metadata.json"

with open(file_output, 'w') as file:
    json.dump(formatted_proofs, file, indent=4)

with open(metadata_output, 'w') as file:
    json.dump(metadata, file, indent=4)

print(f"Data successfully written to {file_output}")