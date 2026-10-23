#!/usr/bin/env bash

# Ollama bash completion script
# Provides smart autocompletion for ollama CLI commands.

_ollama_completion() {
    local cur prev words cword
    
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -n : || return
        # Fix an issue where _init_completion sets cur to empty for words containing colons
        cur="${words[cword]}"
    else
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    # Available top-level ollama commands
    local commands="serve create show run pull push list ps cp rm help"
    
    # If the user is typing the first command (e.g., `ollama r<TAB>`)
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${commands}" -- "$cur") )
        return 0
    fi

    # Determine which top-level command was entered
    local cmd="${words[1]}"

    # Per-command flags, offered once the current word starts with '-'
    # (so model-name completion still wins for a bare TAB after the subcommand).
    if [[ "$cur" == -* ]]; then
        local flags=""
        case "${cmd}" in
            show)   flags="--license --modelfile --parameters --system --template --verbose --help" ;;
            run)    flags="--dimensions --format --hidethinking --insecure --keepalive --nowordwrap --think --truncate --verbose --help" ;;
            pull)   flags="--insecure --help" ;;
            create) flags="--combine --draft-quantize --file --force --quantize --help" ;;
            *)      flags="--help" ;;
        esac
        COMPREPLY=( $(compgen -W "${flags}" -- "$cur") )
        return 0
    fi

    case "${cmd}" in
        run|rm|show|push|cp)
            # Suggest only downloaded (local) models for these commands
            # 'ollama list' outputs headers on the first line, so we skip it using awk
            local local_models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
            COMPREPLY=( $(compgen -W "${local_models}" -- "$cur") )
            ;;

        pull)
            local suggestions=""
            
            if [[ "$cur" == *:* ]]; then
                local model="${cur%%:*}"
                # Fetch tags from ollama.com with 1 second timeout to avoid freezing terminal
                if command -v curl >/dev/null 2>&1; then
                    local tags=$(curl -s --max-time 1 "https://ollama.com/library/${model}/tags" | grep -o 'href="/library/'"${model}"':[^/"]*"' | cut -d':' -f2 | sed 's/"//g' | sort -u)
                    for tag in $tags; do
                        suggestions="${suggestions} ${model}:${tag}"
                    done
                fi
            elif [[ ${#cur} -ge 1 ]]; then
                if command -v curl >/dev/null 2>&1; then
                    suggestions=$(curl -s --max-time 1 "https://ollama.com/search?q=${cur}" | grep -o 'href="/library/[^/"]*"' | cut -d'/' -f3 | sed 's/"//g' | sort -u)
                fi
            fi
            
            local popular_models="llama3 llama3.1 llama3.2 qwen2 qwen2.5 mistral mixtral gemma gemma2 phi3 phi3.5 llava codellama deepseek-coder starcoder2 command-r command-r-plus nomic-embed-text mxbai-embed-large dolphin-mixtral orca-mini vicuna dbrx deepseek-r1"
            
            local local_base_models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | cut -d':' -f1 | sort -u)
            
            COMPREPLY=( $(compgen -W "${suggestions} ${popular_models} ${local_base_models}" -- "$cur") )
            ;;
            
        help)
            # 'help' can take any command name
            COMPREPLY=( $(compgen -W "${commands}" -- "$cur") )
            ;;
            
        *)
            # No completion for other commands
            COMPREPLY=()
            ;;
    esac
    
    # Fix for words containing colons (like model names e.g., llama3:8b)
    # Bash completion by default breaks words at colons. This helper fixes that behavior.
    if declare -F __ltrim_colon_completions >/dev/null 2>&1; then
        __ltrim_colon_completions "$cur"
    fi

    return 0
}

# Register the completion function for 'ollama', avoiding default colon splitting
complete -o default -F _ollama_completion ollama
