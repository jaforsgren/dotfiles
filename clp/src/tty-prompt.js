import fs from 'node:fs';
import tty from 'node:tty';

const CTRL_C = '\x03';

export class CtrlCError extends Error {}

/**
 * Reads a single keypress from the controlling terminal, bypassing stdin.
 * This lets permission prompts work even when the CLI's prompt is piped in
 * via stdin. Returns the lowercase character, or null if no usable TTY is
 * available (e.g. /dev/tty can't be opened, or it isn't a real terminal).
 * Rejects with CtrlCError if the user presses Ctrl+C while the prompt is up.
 */
export async function readTtyKey(validKeys) {
  let fd;
  try {
    fd = fs.openSync('/dev/tty', 'r');
  } catch {
    return null;
  }

  if (!tty.isatty(fd)) {
    fs.closeSync(fd);
    return null;
  }

  const stream = new tty.ReadStream(fd);
  try {
    return await new Promise((resolve, reject) => {
      const cleanup = () => {
        stream.removeListener('data', onData);
        stream.removeListener('error', onError);
        try {
          stream.setRawMode(false);
        } catch {
          // best-effort restore
        }
        stream.pause();
      };

      const onData = (chunk) => {
        if (chunk === CTRL_C) {
          cleanup();
          reject(new CtrlCError('Ctrl+C'));
          return;
        }
        const key = chunk.toLowerCase();
        if (validKeys.includes(key)) {
          cleanup();
          resolve(key);
        }
      };

      const onError = () => {
        cleanup();
        resolve(null);
      };

      try {
        stream.setRawMode(true);
      } catch {
        resolve(null);
        return;
      }
      stream.resume();
      stream.setEncoding('utf8');
      stream.on('data', onData);
      stream.on('error', onError);
    });
  } finally {
    stream.destroy();
  }
}
