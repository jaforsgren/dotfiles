import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const STORE_DIR = path.join(os.homedir(), '.config', 'clp');
const STORE_PATH = path.join(STORE_DIR, 'store.json');

const MAX_SESSIONS_PER_PROJECT = 20;

function emptyProject() {
  return { lastSessionId: null, sessions: [], approvals: [] };
}

export function loadStore(storePath = STORE_PATH) {
  try {
    const raw = fs.readFileSync(storePath, 'utf8');
    const parsed = JSON.parse(raw);
    return { projects: parsed.projects ?? {} };
  } catch (err) {
    if (err.code !== 'ENOENT') throw err;
    return { projects: {} };
  }
}

export function saveStore(store, storePath = STORE_PATH) {
  fs.mkdirSync(path.dirname(storePath), { recursive: true });
  fs.writeFileSync(storePath, JSON.stringify(store, null, 2));
}

export function getProject(store, projectDir) {
  return store.projects[projectDir] ?? emptyProject();
}

export function recordSession(store, projectDir, { sessionId, prompt, timestamp }) {
  const project = store.projects[projectDir] ?? emptyProject();
  project.lastSessionId = sessionId;
  project.sessions = project.sessions.filter((s) => s.id !== sessionId);
  project.sessions.unshift({
    id: sessionId,
    prompt: prompt.slice(0, 120),
    timestamp,
  });
  project.sessions = project.sessions.slice(0, MAX_SESSIONS_PER_PROJECT);
  store.projects[projectDir] = project;
  return store;
}

export function addApproval(store, projectDir, patternKey) {
  const project = store.projects[projectDir] ?? emptyProject();
  if (!project.approvals.includes(patternKey)) {
    project.approvals.push(patternKey);
  }
  store.projects[projectDir] = project;
  return store;
}

export function storePath() {
  return STORE_PATH;
}
