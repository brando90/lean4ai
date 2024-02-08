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
    Objective: Transform the given formal mathematical proof into an informal narrative explanation. Adhere to the following criteria:
    1. Preserve the logical sequence and integrity of the formal proof, accurately reflecting its conclusions and methodology.
    2. Employ precise, yet accessible language tailored to an audience with foundational mathematical knowledge.
    3. Ensure each formal operation is coherently translated into its narrative equivalent, elucidating the proof’s rationale.
    4. Prioritize conciseness and clarity, avoiding superfluous technical jargon and complexities.
    Aim: Facilitate comprehension among non-specialists, retaining the proof's original logical essence.

    This is an example of a formal proof:
    and_left_comm ** a b c : Prop ⊢ a ∧ b ∧ c ↔ b ∧ a ∧ c ** rw [← and_assoc, ← and_assoc, @and_comm a b] ** Qed

    This is the informal proof that should be returned:
    Given three propositions (let's call them statements) a, b, and c, you're trying to prove that 'a and b and c' is really the same thing as 'b and a and c'. It's like saying it doesn't matter if you put on your left shoe before your right shoe, as long as both shoes end up on your feet.

    So, here's how you prove it:
    1. First, you group 'a and b' together with c. It's like saying, "Let's deal with my shoes first, then I'll worry about my pants."
    2. Then, you do the same grouping trick but make sure it's clear you're not changing anything about the 'c' part; it's still there, hanging out, waiting for its turn.
    3. Now, here's the slick move: you swap 'a' and 'b'. It's like deciding to put your right shoe on before your left shoe today. No biggie.
    4. And there you have it. Proof done!

    In fancy proof language, you used rules like 'and_assoc' (which is about how you group things) and 'and_comm' (which is about swapping things around) to show that the order of 'a' and 'b' doesn't mess with the truth of the whole statement when 'c' is also in the mix.

    So, it's all cool. Whether it's 'a and b and c' or 'b and a and c', it's all the same at the end of the day.	

    Do not return anything except the informal proof. Here's the formal proof:
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
    dataset_type = "test"

    llm = LLM(model="HuggingFaceH4/zephyr-7b-alpha", dtype="half", seed=42)
    sampling_params = SamplingParams(temperature=0.5, top_p=0.9)

    dataset = load_dataset("akjadhav/leandojo-lean4-formal-informal-strings-split", split=dataset_type)
    updated_entries = []

    counter = 0

    for entry in dataset:
        counter += 1
        if counter > 2: break

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
    with open("updated_dataset_" + dataset_type + ".json", "w", encoding="utf-8") as file:
        file.write(updated_dataset_json)
    logging.info("Updated dataset saved successfully.")

if __name__ == '__main__':
    main()
