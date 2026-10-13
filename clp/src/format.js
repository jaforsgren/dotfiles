const TOOL_ICONS = {
  Bash: '⚡',
  Read: '📖',
  Write: '✏️',
  Edit: '✏️',
  Grep: '🔍',
  Glob: '🔍',
  WebFetch: '🌐',
  WebSearch: '🌐',
  Task: '🤖',
  Agent: '🤖',
};

function iconFor(toolName) {
  return TOOL_ICONS[toolName] ?? '🔧';
}

export function truncate(str, length) {
  if (!str) return '';
  if (str.length <= length) return str;
  return `${str.slice(0, length)}…`;
}

function formatToolUse(toolName, input, truncateLength) {
  const icon = iconFor(toolName);
  if (toolName === 'Bash' && typeof input?.command === 'string') {
    return `${icon} ${truncate(input.command, truncateLength)}`;
  }
  if (typeof input?.file_path === 'string') {
    return `${icon} ${input.file_path}`;
  }
  if (toolName === 'Grep' || toolName === 'Glob') {
    return `${icon} ${input?.pattern ?? ''}`.trim();
  }
  if ((toolName === 'WebFetch' || toolName === 'WebSearch') && (input?.url || input?.query)) {
    return `${icon} ${input.url ?? input.query}`;
  }
  if (typeof input?.description === 'string') {
    return `${icon} ${toolName}: ${truncate(input.description, truncateLength)}`;
  }
  return `${icon} ${toolName} ${truncate(JSON.stringify(input ?? {}), truncateLength)}`;
}

function extractToolResultText(content) {
  if (typeof content === 'string') return content;
  if (Array.isArray(content)) {
    return content
      .filter((block) => block.type === 'text' && typeof block.text === 'string')
      .map((block) => block.text)
      .join('\n');
  }
  return '';
}

function firstNonEmptyLine(text) {
  return text.split('\n').find((line) => line.trim().length > 0) ?? '';
}

/**
 * Renders one SDK stream message as compact (or verbose) text onto `ctx.out`.
 */
export function formatMessage(message, ctx) {
  const { verbose = false, truncateLength = 300, out = process.stdout } = ctx;

  switch (message.type) {
    case 'system': {
      if (message.subtype === 'init') {
        out.write(`Session: ${message.session_id}\n`);
        if (verbose) {
          out.write(`· model ${message.model}, cwd ${message.cwd}\n`);
        }
      }
      return;
    }

    case 'assistant': {
      const blocks = message.message?.content ?? [];
      for (const block of blocks) {
        if (block.type === 'text' && block.text?.trim()) {
          out.write(`Claude: ${block.text.trim()}\n`);
        } else if (block.type === 'tool_use') {
          out.write(`${formatToolUse(block.name, block.input, truncateLength)}\n`);
        } else if (block.type === 'thinking' && verbose && block.thinking?.trim()) {
          out.write(`… ${truncate(block.thinking.trim(), truncateLength)}\n`);
        }
      }
      return;
    }

    case 'user': {
      const content = message.message?.content;
      if (!Array.isArray(content)) return;
      for (const block of content) {
        if (block.type !== 'tool_result') continue;
        const text = extractToolResultText(block.content).trim();
        if (!text) continue;
        if (!block.is_error && !verbose) continue;
        const line = truncate(firstNonEmptyLine(text).trim(), truncateLength);
        out.write(`  ${block.is_error ? '✗ ' : ''}${line}\n`);
      }
      return;
    }

    case 'result': {
      if (message.subtype === 'success' && !message.is_error) {
        const detail = verbose
          ? ` (${message.duration_ms}ms, $${(message.total_cost_usd ?? 0).toFixed(4)})`
          : '';
        out.write(`\n✔ Done${detail}\n`);
      } else {
        const reason = message.subtype === 'success' ? (message.result || 'unknown error') : message.subtype;
        out.write(`\n✖ ${reason}\n`);
      }
      return;
    }

    default: {
      if (verbose) {
        out.write(`[${message.type}] ${truncate(JSON.stringify(message), truncateLength)}\n`);
      }
    }
  }
}
