import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { loadStore, saveStore, getProject, recordSession, addApproval } from '../src/store.js';

function tmpStorePath() {
  return path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'clp-test-')), 'store.json');
}

test('loadStore returns an empty store when the file does not exist', () => {
  const store = loadStore(tmpStorePath());
  assert.deepEqual(store, { projects: {} });
});

test('getProject returns defaults for an unknown project', () => {
  const store = { projects: {} };
  assert.deepEqual(getProject(store, '/some/project'), {
    lastSessionId: null,
    sessions: [],
    approvals: [],
  });
});

test('recordSession sets lastSessionId and prepends to history', () => {
  const store = { projects: {} };
  recordSession(store, '/proj', { sessionId: 's1', prompt: 'first', timestamp: '2026-01-01T00:00:00.000Z' });
  recordSession(store, '/proj', { sessionId: 's2', prompt: 'second', timestamp: '2026-01-02T00:00:00.000Z' });
  const project = getProject(store, '/proj');
  assert.equal(project.lastSessionId, 's2');
  assert.deepEqual(project.sessions.map((s) => s.id), ['s2', 's1']);
});

test('addApproval is idempotent', () => {
  const store = { projects: {} };
  addApproval(store, '/proj', 'Bash:npm');
  addApproval(store, '/proj', 'Bash:npm');
  assert.deepEqual(getProject(store, '/proj').approvals, ['Bash:npm']);
});

test('saveStore + loadStore round-trip', () => {
  const p = tmpStorePath();
  const store = { projects: {} };
  recordSession(store, '/proj', { sessionId: 's1', prompt: 'hi', timestamp: '2026-01-01T00:00:00.000Z' });
  saveStore(store, p);
  const reloaded = loadStore(p);
  assert.equal(getProject(reloaded, '/proj').lastSessionId, 's1');
});
