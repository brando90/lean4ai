import logging
from datasets import load_dataset
from vllm import LLM, SamplingParams
import json

# Configure logging
logging.basicConfig(filename='generation_log.txt', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def generate_boxed_answer(question, solution, llm, sampling_params):
    """
    Generate a solution analysis with a final boxed answer ($\\boxed{answer}$) for a given math question using a language model.
    This function modifies the prompt to include an explicit request for precision and adherence to a structured answer format.
    Includes error handling to manage potential issues during generation.
    """
    task_description = """
    You are tasked with explaining and solving the following math problem. Ensure that your explanation is thorough and ends with a solution clearly marked in a box (using the format $\\boxed{answer}$).

    Instructions for completing the task:
    - Provide a brief explanation of how to solve the problem.
    - MUST CONCLUDE your explanation with the final answer in a $\\boxed{answer}$ format to highlight it.

    Examples of correctly formatted solutions are shown below:

    Example 1:
    Problem: "Mr. Cole needs to select 3 girls and 5 boys to go on a backpacking trip. How many ways can he do this if 6 girls and 11 boys are interested?"
    Solution: "The number of ways to choose the girls is $$\\binom{6}{3}$$, and for the boys, it's $$\\binom{11}{5}$$. Multiplying these gives the total combinations: $$\\boxed{9,240}$$."

    Example 2:
    Problem: "The letters $A, B$, and $C$ are used to form every possible three-letter word. What is the position of the word $BAB$ when arranged alphabetically?"
    Solution: "Starting with $A$, there are 9 combinations before $B$. Thus, $BAA$ is the 10th, and $BAB$ is the 11th word: $$\\boxed{11}$$."

    Pay special attention to the $$\\boxed{ }$$ format at the end of each Solution. The $$\\boxed{ }$$ format VERY important to include. Now, solve the following problem with a detailed explanation and a boxed solution:
    """

    complete_prompt = f"{task_description}\n{question}"

    try:
        outputs = llm.generate([complete_prompt], sampling_params)
        generated_text = outputs[0].outputs[0].text  # Assuming each call generates a single response
        return generated_text
    except Exception as e:
        logging.error(f"Error generating informal proof for formal proof: {question[:30]}... Error: {e}")
        return None

def main():
    llm = LLM(model="morph-labs/morph-prover-v0-7b", dtype="half", seed=42)
    #llm = LLM(model="meta-llama/Llama-2-7b", dtype="half", seed=42)

    sampling_params = SamplingParams(temperature=0.5, top_p=0.9, max_tokens=2000)
    dataset_path = '/lfs/hyperturing1/0/smion/evals-for-autoformalization/hendrycks_test_data.jsonl'
    boxed_answers = []

    counter = 0

    # Open the JSON Lines file and iterate over each line
    with open(dataset_path, 'r', encoding='utf-8') as file:
        for line in file:
            # Each line is a JSON string, so parse it into a dictionary
            entry = json.loads(line)
            counter += 1
            if counter > 5: break

            question = entry["problem"]
            solution = entry["solution"]
            boxed_model_solution = generate_boxed_answer(question, solution, llm, sampling_params)
            if boxed_model_solution:
                updated_entry = {
                    "original_question": question,
                    "boxed_model_solution": boxed_model_solution
                }
                boxed_answers.append(updated_entry)
                logging.info(f"Successfully generated informal proof for question {counter},: {boxed_model_solution[:30]}...")
            else:
                logging.warning(f"Failed to generate informal proof for question {counter},: {boxed_model_solution[:30]}...")

    updated_dataset_json = json.dumps(boxed_answers, ensure_ascii=False, indent=4)
    with open("mistral_boxed_no_ft_" + ".json", "w", encoding="utf-8") as file:
        file.write(updated_dataset_json)
    logging.info("Updated dataset saved successfully.")
    logging.info("Updated dataset saved successfully.")

if __name__ == '__main__':
    main()
