import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const CONFIG_DIR = path.join(os.homedir(), '.config', 'clp');
const CONFIG_PATH = path.join(CONFIG_DIR, 'config.json');

export const DEFAULT_CONFIG = {
  verbose: false,
  truncateLength: 300,
  // What to do with a permission request when no TTY is available to prompt the user.
  nonInteractiveDefault: 'deny',
};

export function loadConfig() {
  try {
    const raw = fs.readFileSync(CONFIG_PATH, 'utf8');
    return { ...DEFAULT_CONFIG, ...JSON.parse(raw) };
  } catch (err) {
    if (err.code !== 'ENOENT') throw err;
    return { ...DEFAULT_CONFIG };
  }
}

export function configPath() {
  return CONFIG_PATH;
}
