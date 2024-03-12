import logging
from datasets import load_dataset
from vllm import LLM, SamplingParams
import json
import anthropic
from typing import Dict

# Configure logging
logging.basicConfig(filename='generation_log.txt', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def extract_text_from_content_block(content_blocks):
    # Assuming content_blocks is a list of ContentBlock objects
    # This function extracts and combines text from all ContentBlock objects
    return "\n".join([block.text for block in content_blocks])

def generate_informal_proof(formal_proof):
    """
    Generate an informal proof for a given formal proof using the Mistral model.
    This function modifies the prompt to include an explicit request to convert the formal proof to informal language.
    Includes error handling to manage potential issues during generation.
    """
    task_description = """
    You are tasked with translating formal mathematical proofs, written in the Lean proof assistant language, into informal, natural language explanations. The goal is to make the logic and conclusions of these proofs accessible to individuals with a foundational understanding of mathematics but who may not be familiar with formal proof languages or advanced mathematical concepts. Simplify the language while preserving the logical sequence and integrity of the proofs. Avoid unnecessary jargon and aim for clarity.

    Instructions:
    1. Read the formal Lean proof provided below.
    2. Rewrite the proof as an informal, narrative explanation. Your explanation should:
    - Accurately reflect the logical sequence and conclusions of the Lean proof.
    - Use accessible language similar to the language used in the 2 provided examples.
    - Clearly explain the rationale behind each step of the proof.
    - Be concise, avoiding unnecessary technical terms, details, and filler.

    Example 1:'''
    Formal (Lean): 
    and_left_comm ** a b c : Prop ⊢ a ∧ b ∧ c ↔ b ∧ a ∧ c ** rw [← and_assoc, ← and_assoc, @and_comm a b] ** Qed

    Informal: 
    Theorem: For any propositions a, b, and c, the logical conjunction a ∧ b ∧ c is logically equivalent to b ∧ a ∧ c.
    Proof:
    We aim to establish the equivalence of two compound propositions, a ∧ b ∧ c and b ∧ a ∧ c, by demonstrating that the ordering of the propositions a and b within a series of logical conjunctions does not affect the overall truth value when c is also conjoined with them.
    Associativity of Logical Conjunction: The operation of logical conjunction (∧) is associative. This property allows us to regroup the operands without altering the truth value of the expression. Specifically, we apply the associativity to decompose our expression into a form where the conjunction involving a and b is more explicit. This yields (a ∧ b) ∧ c, emphasizing that a and b are conjoined first, followed by their conjunction with c.
    Commutativity of Logical Conjunction: Logical conjunction is also commutative, meaning that the order of the operands does not impact the result. Thus, swapping a and b in their conjunction, i.e., a ∧ b becoming b ∧ a, does not change the truth value of their conjunction.
    Reapplication of Associativity: After swapping a and b, we reassociate them with c to maintain the structure of the conjunction. This step is justified by the associativity of conjunction, which permits the reorganization of the conjunctions without affecting the overall logical equivalence.
    By applying the principles of associativity and commutativity to the conjunction of propositions a, b, and c, we have demonstrated that a ∧ b ∧ c is logically equivalent to b ∧ a ∧ c. This completes our proof, showing that the specific ordering of propositions a and b in conjunction with c does not alter the truth value of the expression.
    '''

    Example 2:'''
    Foram (Lean):
    and_congr_right_iff ** a b c : Prop h : a ∧ b ↔ a ∧ c ha : a ⊢ b ↔ c ** simp [ha] at h ** a b c : Prop ha : a h : b ↔ c ⊢ b ↔ c ** exact h ** Qed

    Informal:
    Theorem: Given propositions \(a\), \(b\), and \(c\), if \(a\) is true, then \(b\) is logically equivalent to \(c\) if and only if \(a ∧ b\) is logically equivalent to \(a ∧ c\).
    Proof:
    Let's start by considering the conditions under which propositions \(b\) and \(c\) can be considered equivalent, given the truth of proposition \(a\). Our goal is to establish a relationship that illustrates under what circumstances the compound propositions \(a ∧ b\) and \(a ∧ c\) can be considered equivalent.
    Firstly, we acknowledge the premise \(a\) is true. This premise is crucial as it sets the stage for examining the relationship between \(b\) and \(c\) within the context of their conjunction with \(a\).
    Next, we examine the hypothesis that \(b\) is equivalent to \(c\) (\(b ↔ c\)). This equivalence suggests that the truth of \(b\) guarantees the truth of \(c\) and vice versa, but this relationship is considered within the framework where \(a\) is already established as true.
    With the acceptance of \(a\)'s truth, the equivalence \(b ↔ c\) directly impacts the compound propositions \(a ∧ b\) and \(a ∧ c\). Specifically, if \(b\) is true when \(a\) is true (thus making \(a ∧ b\) true), and given \(b\) is equivalent to \(c\), \(c\) must also be true under the condition \(a\) is true, making \(a ∧ c\) true as well. Conversely, if \(a ∧ c\) is true, implying \(c\) is true when \(a\) is true, the equivalence \(b ↔ c\) ensures that \(b\) is also true under the truth of \(a\), making \(a ∧ b\) true.
    Therefore, through the application of the equivalence \(b ↔ c\) within the context of \(a\)'s truth, we have demonstrated that the compound propositions \(a ∧ b\) and \(a ∧ c\) are logically equivalent. This equivalence holds because the truth of \(a\) enables the direct comparison of \(b\) and \(c\), where their interchangeability does not alter the overall truth value of the expressions \(a ∧ b\) and \(a ∧ c\).
    This completes our proof, illustrating that given the truth of proposition \(a\), \(b\) is equivalent to \(c\) if and only if the conjunction of \(a\) with \(b\) is equivalent to the conjunction of \(a\) with \(c\).
    '''

    ***Now, translate the following formal Lean proof into an informal narrative explanation matching the given example:
    """

    complete_prompt = f"{task_description}\n{formal_proof}"

    client = anthropic.Anthropic(
        # defaults to os.environ.get("ANTHROPIC_API_KEY")
        api_key="sk-ant-api03--........key",
    )

    message = client.messages.create(
        model="claude-3-opus-20240229",
        max_tokens=1000,
        temperature=0,
        system=complete_prompt,
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Follow system prompt.\n"
                    }
                ]
            }
        ]
    )
    print(message.content)
    return(message.content)
    # try:
    #     outputs = llm.generate([complete_prompt], sampling_params)
    #     generated_text = outputs[0].outputs[0].text  # Assuming each call generates a single response
    #     return generated_text
    # except Exception as e:
    #     logging.error(f"Error generating informal proof for formal proof: {formal_proof[:30]}... Error: {e}")
    #     return None

def main():
    dataset_type = "train"
    # llm = LLM(model="morph-labs/morph-prover-v0-7b", dtype="half", seed=42)
    #llm = LLM(model="meta-llama/Llama-2-7b", dtype="half", seed=42)

    #llm = LLM(model="openai-community/gpt2")


    # TODO: play around with the max token length to figure out what's the best
    # sampling_params = SamplingParams(temperature=0.5, top_p=0.9, max_tokens=2000)

    dataset = load_dataset("akjadhav/leandojo-lean4-formal-informal-strings-split", split=dataset_type)
    updated_entries = []

    counter = 0

    for index, entry in enumerate(dataset):
        if index < 2:  # Skip the first x entries
            continue
        counter += 1
        if counter > 25: break

        formal_proof = entry["formal"]
        content_blocks = generate_informal_proof(formal_proof)  # This should return ContentBlock objects
        informal_proof = extract_text_from_content_block(content_blocks)  # Extract text
        if informal_proof:
            updated_entry = {
                "formal": formal_proof,
                "informal": informal_proof
            }
            updated_entries.append(updated_entry)
            logging.info(f"Successfully generated informal proof for formal proof: {formal_proof[:30]}...")
        else:
            logging.warning(f"Failed to generate informal proof for formal proof: {formal_proof[:30]}...")

    # updated_dataset_json = json.dumps(updated_entries, ensure_ascii=False, indent=4)
    updated_dataset_json = json.dumps(updated_entries, ensure_ascii=False, indent=4)

    with open("claude_working_updated_dataset_" + dataset_type + ".json", "w", encoding="utf-8") as file:
        file.write(updated_dataset_json)
    logging.info("Updated dataset saved successfully.")
    logging.info("Updated dataset saved successfully.")

if __name__ == '__main__':
    main()
