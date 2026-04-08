# Ollama Bash Autocompletion

A smart autocompletion script for the `ollama` CLI in Bash.

## Features
- **Dynamic Local Models**: Automatically fetches your currently downloaded models for commands like `ollama run`, `ollama rm`, `ollama show`, `ollama cp`, and `ollama push`.
- **Intelligent Pull Suggestions**: When typing `ollama pull`, it will suggest the most popular base models (like `llama3`, `qwen2.5`, `mistral`, etc.) and seamlessly combine them with the base names of models you already have locally.
- **Colon Tag Support**: Seamlessly handles tags containing colons (e.g. `llama3:8b`) without breaking word splitting.

## Installation

### Temporary Usage (Current Session)
Source the script directly in your terminal:
```bash
source ./ollama-bash-completion.sh
```

### Permanent Installation
To have it load automatically every time you open a terminal:

1. Copy the script to a safe location, or the default bash-completion user directory:
```bash
mkdir -p ~/.local/share/bash-completion/completions
cp ollama-bash-completion.sh ~/.local/share/bash-completion/completions/ollama
```

2. Alternatively, you can add it to your `.bashrc`:
```bash
echo "source \"$(pwd)/ollama-bash-completion.sh\"" >> ~/.bashrc
source ~/.bashrc
```

## Testing it out
Try typing the following and hitting `<TAB>`:
- `ollama r<TAB>` -> completes to `rm` or `run`
- `ollama run <TAB>` -> lists your downloaded models
- `ollama pull l<TAB>` -> lists popular models like `llama3`, `llava`
