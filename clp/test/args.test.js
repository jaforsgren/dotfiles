import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parseArgs, ArgsError } from '../src/args.js';

test('parses a plain prompt', () => {
  const args = parseArgs(['Fix the failing tests']);
  assert.equal(args.prompt, 'Fix the failing tests');
  assert.equal(args.resume, false);
  assert.equal(args.sessionId, null);
});

test('joins multiple positional words into one prompt', () => {
  const args = parseArgs(['Fix', 'the', 'failing', 'tests']);
  assert.equal(args.prompt, 'Fix the failing tests');
});

test('parses --resume with a trailing prompt', () => {
  const args = parseArgs(['--resume', 'Continue fixing the tests']);
  assert.equal(args.resume, true);
  assert.equal(args.prompt, 'Continue fixing the tests');
});

test('parses --session <id>', () => {
  const args = parseArgs(['--session', 'abc123', 'Continue working']);
  assert.equal(args.sessionId, 'abc123');
  assert.equal(args.prompt, 'Continue working');
});

test('parses --verbose and -v', () => {
  assert.equal(parseArgs(['--verbose', 'hi']).verbose, true);
  assert.equal(parseArgs(['-v', 'hi']).verbose, true);
  assert.equal(parseArgs(['hi']).verbose, false);
});

test('parses --help', () => {
  assert.equal(parseArgs(['--help']).help, true);
  assert.equal(parseArgs(['-h']).help, true);
});

test('no prompt yields null', () => {
  assert.equal(parseArgs([]).prompt, null);
});

test('--session requires a value', () => {
  assert.throws(() => parseArgs(['--session']), ArgsError);
});

test('rejects unknown flags', () => {
  assert.throws(() => parseArgs(['--bogus', 'hi']), ArgsError);
});

test('rejects --resume and --session together', () => {
  assert.throws(() => parseArgs(['--resume', '--session', 'abc', 'hi']), ArgsError);
});
