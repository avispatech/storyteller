#!/bin/bash
# Read Claude's tool input
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only run for Ruby files
if [[ ! "$file_path" =~ \.(rb|rake)$ ]]; then
  exit 0
fi

# Run StandardRB on the file
# --format simple keeps the output clean for the AI
lint_output=$(bundle exec standardrb --format simple "$file_path" 2>&1)

if [[ $? -ne 0 ]]; then
  # Block the change and provide the linting errors as the reason
  echo "{\"decision\": \"block\", \"reason\": \"Standard linting errors:\n$lint_output\"}"
else
  # Allow the change to proceed
  echo "{\"decision\": \"allow\"}"
fi
