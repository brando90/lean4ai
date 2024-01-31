from vllm import LLM, SamplingParams


def main():
  # TODO control seed 
  # TODO: formal to formal instruction + concat of formal proof
  prompts = [
    "Hello, my name is",
    "The president of the United States is",
    "The capital of France is",
    "The future of AI is",
]
  sampling_params = SamplingParams(temperature=0.8, top_p=0.95)
  # 7B
  llm = LLM(model="facebook/opt-125m")

  outputs = llm.generate(prompts, sampling_params)

  # Print the outputs.
  for output in outputs:
      prompt = output.prompt
    generated_text = output.outputs[0].text
      print(f"Prompt: {prompt!r}, Generated text: {generated_text!r}")

if __name__ == '__main__':
  main()
