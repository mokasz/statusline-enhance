# Claude Code Statusline

Enhanced status line script for Claude Code that displays token usage, directory information, and git status.

## Features

- **Token Usage Display**: Shows remaining and total context window tokens with color-coded usage percentage
- **Smart Color Coding**:
  - 🟢 Green: < 30% usage
  - 🟡 Yellow: 30-70% usage
  - 🔴 Red: > 70% usage
- **Git Integration**: Displays current branch and dirty state indicator
- **Current Directory**: Shows the working directory path

## Display Format

```
[残りトークンk/コンテキストサイズk] カレントディレクトリ (ブランチ*)
```

Example:
```
[167k/200k] /Users/username/project (main*)
```

The asterisk (*) indicates uncommitted changes in the repository.

## Installation

### 1. Copy the script

```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

### 2. Update Claude Code settings

Add the following to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

### 3. Restart Claude Code

The status line will now appear at the top of your Claude Code interface.

## How It Works

### Input

Claude Code passes JSON data to the script via stdin with the following structure:

```json
{
  "context_window": {
    "context_window_size": 200000,
    "current_usage": {
      "input_tokens": 43000,
      "output_tokens": 2000,
      "cache_creation_input_tokens": 5000,
      "cache_read_input_tokens": 10000
    }
  },
  "workspace": {
    "current_dir": "/path/to/directory"
  }
}
```

### Processing

1. Parses JSON input using `jq`
2. Calculates total token usage across all token types:
   - `input_tokens`
   - `output_tokens`
   - `cache_creation_input_tokens`
   - `cache_read_input_tokens`
3. Computes remaining tokens and usage percentage
4. Retrieves git branch and status information
5. Formats and outputs the status line with ANSI color codes

### Output

The script outputs a formatted string with ANSI escape codes for colorization that Claude Code displays in the status line area.

## Dependencies

- `bash`
- `jq` - JSON processor
- `git` - For branch and status information

## Customization

You can modify the color thresholds in `statusline.sh`:

```bash
# Lines 29-35
if [ $PERCENT_USED -gt 70 ]; then
    BUDGET_COLOR="\033[31m"  # Red (high usage)
elif [ $PERCENT_USED -ge 30 ]; then
    BUDGET_COLOR="\033[33m"  # Yellow (medium usage)
else
    BUDGET_COLOR="\033[32m"  # Green (low usage)
fi
```

Adjust the percentages (70, 30) to your preference.

## Troubleshooting

### Status line not appearing

1. Verify the script is executable: `ls -l ~/.claude/statusline.sh`
2. Check settings.json syntax is valid
3. Ensure `jq` is installed: `which jq`
4. Test the script manually:
   ```bash
   echo '{"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":10000,"output_tokens":1000,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}},"workspace":{"current_dir":"'"$PWD"'"}}' | ~/.claude/statusline.sh
   ```

### Colors not showing

ANSI color support depends on your terminal. The script uses standard ANSI escape codes that should work in most modern terminals.

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
