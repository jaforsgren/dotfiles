import { test } from 'node:test';
import assert from 'node:assert/strict';
import { PassThrough } from 'node:stream';
import { runRepl } from '../src/repl.js';

function capture() {
  const lines = [];
  return { lines, out: { write: (s) => lines.push(s) } };
}

async function waitFor(predicate, timeoutMs = 2000) {
  const start = Date.now();
  while (!(await predicate())) {
    if (Date.now() - start > timeoutMs) throw new Error('timed out waiting for condition');
    await new Promise((resolve) => setTimeout(resolve, 5));
  }
}

/**
 * A fake `query()` that plays back one canned assistant reply per user
 * message it receives, so the REPL loop can be exercised without the real
 * SDK/network.
 */
function fakeQueryFactory(replies) {
  return function fakeQuery({ prompt }) {
    let i = 0;
    async function* gen() {
      yield { type: 'system', subtype: 'init', session_id: 'sess-1', model: 'm', cwd: '/x' };
      for await (const userMsg of prompt) {
        void userMsg;
        const reply = replies[i] ?? 'ok';
        i += 1;
        yield { type: 'assistant', message: { content: [{ type: 'text', text: reply }] } };
        yield { type: 'result', subtype: 'success', is_error: false, session_id: 'sess-1' };
      }
    }
    const it = gen();
    it.interrupt = async () => {};
    return it;
  };
}

test('REPL carries a second typed message into the same session', async () => {
  const stdin = new PassThrough();
  const { lines, out } = capture();
  const store = { projects: {} };

  const resultPromise = runRepl({
    initialPrompt: 'tell me a knock knock joke',
    project: '/tmp/clp-repl-test',
    resume: undefined,
    canUseTool: async () => ({ behavior: 'allow' }),
    config: { truncateLength: 300 },
    verbose: false,
    store,
    out,
    stdin,
    queryFn: fakeQueryFactory(['Knock knock.', "Orange you glad I didn't say banana?"]),
  });

  await waitFor(() => lines.join('').includes('Knock knock.'));
  stdin.write("who's there?\n");

  await waitFor(() => lines.join('').includes('Orange you glad'));
  stdin.write('/exit\n');

  const code = await resultPromise;
  const text = lines.join('');

  assert.equal(code, 0);
  assert.match(text, /Session: sess-1/);
  assert.match(text, /Knock knock\./);
  assert.match(text, /Orange you glad/);
  assert.equal(store.projects['/tmp/clp-repl-test'].lastSessionId, 'sess-1');
});

test('REPL prompts for input immediately when no initial prompt is given', async () => {
  const stdin = new PassThrough();
  const { lines, out } = capture();
  const store = { projects: {} };

  const resultPromise = runRepl({
    initialPrompt: null,
    project: '/tmp/clp-repl-test-2',
    resume: undefined,
    canUseTool: async () => ({ behavior: 'allow' }),
    config: { truncateLength: 300 },
    verbose: false,
    store,
    out,
    stdin,
    queryFn: fakeQueryFactory(['hi there']),
  });

  // readline's `question()` listener attaches a few microtask ticks after
  // runRepl() returns control here, so a single immediate write can land
  // before anyone is listening and get dropped. Retry until it's picked up.
  await waitFor(async () => {
    if (lines.join('').includes('hi there')) return true;
    stdin.write('hello\n');
    await new Promise((resolve) => setTimeout(resolve, 10));
    return lines.join('').includes('hi there');
  });
  stdin.write('/exit\n');

  const code = await resultPromise;
  assert.equal(code, 0);
});
