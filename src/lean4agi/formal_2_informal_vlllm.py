import logging
from datasets import load_dataset
from vllm import LLM, SamplingParams
import json

# Configure logging
logging.basicConfig(filename='generation_log.txt', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def generate_informal_proof(formal_proof, llm, sampling_params):
    """
    Generate an informal proof for a given formal proof using the Mistral model.
    This function modifies the prompt to include an explicit request to convert the formal proof to informal language.
    Includes error handling to manage potential issues during generation.
    """
    task_description = """
    You are tasked with translating formal mathematical proofs, written in the Lean proof assistant language, into informal, narrative explanations. The goal is to make the logic and conclusions of these proofs accessible to individuals with a foundational understanding of mathematics but who may not be familiar with formal proof languages or advanced mathematical concepts. Simplify the language while preserving the logical sequence and integrity of the proofs. Avoid unnecessary jargon and aim for clarity.

    Instructions:
    1. Read the formal Lean proof provided below.
    2. Rewrite the proof as an informal, narrative explanation. Your explanation should:
    - Accurately reflect the logical sequence and conclusions of the Lean proof.
    - Use accessible language suitable for an audience with basic mathematical knowledge.
    - Clearly explain the rationale behind each step of the proof, translating formal operations into narrative form.
    - Be concise, avoiding unnecessary technical terms and details.

    Example:
    Formal (Lean): 
    ```Lean
    -- Define a formal Lean proof
    theorem example_theorem : ∀ (A B : set X) (x : X), x ∈ A ∩ B → x ∈ B :=
    begin
    intros A B x,
    intro h,
    cases h with hA hB,
    exact hB,
    end
    Informal: Imagine we have two sets, A and B, where every element of A is also in B. If we take any other set and find the common elements it shares with A, this group of common elements will also be found in the common elements between the same set and B. It's like saying if A's members are all in B, then A's overlap with anyone else is also part of B's overlap with them.

    Now, please translate the following formal Lean proof into an informal narrative explanation:
    """

    complete_prompt = f"{task_description}\n{formal_proof}"
    try:
        outputs = llm.generate([complete_prompt], sampling_params)
        generated_text = outputs[0].outputs[0].text  # Assuming each call generates a single response
        return generated_text
    except Exception as e:
        logging.error(f"Error generating informal proof for formal proof: {formal_proof[:30]}... Error: {e}")
        return None

def main():
    llm = LLM(model="mistralai/Mistral-7B-v0.1", dtype="half", seed=42)
    sampling_params = SamplingParams(temperature=0.5, top_p=0.9)

    dataset = load_dataset("akjadhav/leandojo-lean4-formal-informal-strings-split", split='test')
    updated_entries = []

    counter = 0
    for entry in dataset:
        counter += 1
        if counter > 5:
            break

        formal_proof = entry["formal"]
        informal_proof = generate_informal_proof(formal_proof, llm, sampling_params)
        if informal_proof:
            updated_entry = {
                "formal": formal_proof,
                "informal": informal_proof
            }
            updated_entries.append(updated_entry)
            logging.info(f"Successfully generated informal proof for formal proof: {formal_proof[:30]}...")
        else:
            logging.warning(f"Failed to generate informal proof for formal proof: {formal_proof[:30]}...")

    updated_dataset_json = json.dumps(updated_entries, ensure_ascii=False, indent=4)
    with open("updated_dataset.json", "w", encoding="utf-8") as file:
        file.write(updated_dataset_json)
    logging.info("Updated dataset saved successfully.")

if __name__ == '__main__':
    main()
