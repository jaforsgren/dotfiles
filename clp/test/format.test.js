import { test } from 'node:test';
import assert from 'node:assert/strict';
import { formatMessage, truncate } from '../src/format.js';

function capture() {
  const lines = [];
  const out = { write: (s) => lines.push(s) };
  return { lines, out };
}

test('truncate leaves short strings alone', () => {
  assert.equal(truncate('hello', 10), 'hello');
});

test('truncate clips long strings with an ellipsis', () => {
  assert.equal(truncate('abcdefghij', 5), 'abcde…');
});

test('renders assistant text as "Claude: ..."', () => {
  const { lines, out } = capture();
  formatMessage(
    { type: 'assistant', message: { content: [{ type: 'text', text: 'Checking tests...' }] } },
    { out },
  );
  assert.equal(lines.join(''), 'Claude: Checking tests...\n');
});

test('renders a Bash tool_use with the lightning icon', () => {
  const { lines, out } = capture();
  formatMessage(
    {
      type: 'assistant',
      message: { content: [{ type: 'tool_use', name: 'Bash', input: { command: 'npm test' } }] },
    },
    { out },
  );
  assert.equal(lines.join(''), '⚡ npm test\n');
});

test('renders a Read tool_use with the file path', () => {
  const { lines, out } = capture();
  formatMessage(
    {
      type: 'assistant',
      message: { content: [{ type: 'tool_use', name: 'Read', input: { file_path: 'src/auth.ts' } }] },
    },
    { out },
  );
  assert.equal(lines.join(''), '📖 src/auth.ts\n');
});

test('renders an errored tool_result with a cross mark', () => {
  const { lines, out } = capture();
  formatMessage(
    {
      type: 'user',
      message: {
        content: [{ type: 'tool_result', is_error: true, content: '2 tests failed\nmore detail' }],
      },
    },
    { out },
  );
  assert.equal(lines.join(''), '  ✗ 2 tests failed\n');
});

test('hides successful tool_result in compact mode', () => {
  const { lines, out } = capture();
  formatMessage(
    {
      type: 'user',
      message: { content: [{ type: 'tool_result', is_error: false, content: '24 tests passed' }] },
    },
    { out, verbose: false },
  );
  assert.deepEqual(lines, []);
});

test('shows successful tool_result in verbose mode', () => {
  const { lines, out } = capture();
  formatMessage(
    {
      type: 'user',
      message: { content: [{ type: 'tool_result', is_error: false, content: '24 tests passed' }] },
    },
    { out, verbose: true },
  );
  assert.equal(lines.join(''), '  24 tests passed\n');
});

test('renders a successful result as Done', () => {
  const { lines, out } = capture();
  formatMessage({ type: 'result', subtype: 'success', is_error: false }, { out });
  assert.equal(lines.join(''), '\n✔ Done\n');
});

test('renders a failed result with its reason', () => {
  const { lines, out } = capture();
  formatMessage({ type: 'result', subtype: 'error_max_turns', is_error: true }, { out });
  assert.equal(lines.join(''), '\n✖ error_max_turns\n');
});
