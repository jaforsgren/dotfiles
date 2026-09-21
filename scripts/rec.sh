#!/bin/bash

set -e

DIR="$HOME/DEV/weapp-notes/Meetings"
DATE=$(date +"%Y-%m-%d_%H-%M")
NAME="$1"
BASE="$DIR/$DATE${NAME:+_$NAME}"

AUDIO="$BASE.mp3"
TRANSCRIPT="$BASE-transcript"
NOTES="$BASE-notes.md"

mkdir -p "$DIR"

echo "🔴 Recording system audio..."
echo "Press Ctrl+C to stop."
echo

ffmpeg \
  -f avfoundation \
  -i ":1" \
  -ac 2 \
  -ar 48000 \
  -b:a 192k \
  "$AUDIO" || true
# ffmpeg exits non-zero when stopped via Ctrl+C (SIGINT); that's the
# expected way to end a recording, so don't let set -e kill the script here.

echo
echo "🎧 Saved: $AUDIO"
echo
echo "📝 Transcribing..."

whisper "$AUDIO" \
  --model large-v3 \
  --output_format txt \
  --output_dir "$DIR"

# Whisper names its output after the audio file.
WHISPER_TXT="$BASE.txt"

mv "$WHISPER_TXT" "$TRANSCRIPT.md"

echo
echo "🤖 Creating meeting notes..."

claude -p "$(
  cat <<EOF
The following is an automatically generated meeting transcript.

Create clean Markdown meeting notes.

Include:

# Summary

A concise summary of the meeting. short sentances. 

# Key points

Important topics, facts, and conclusions.

# Decisions

Decisions that were actually made. Do not invent decisions.

# Action items

Use checkboxes:

- [ ] Action — Owner, if identifiable

# Open questions

Anything unresolved or requiring follow-up.

The meeting may be in a language other than English.
Keep the transcript in its original language.
Write the meeting notes in English.

Under each '#' header, organise stuff after subbject under ### <subject>

Between each '#' header , add a '---' separator

TRANSCRIPT:

$(cat "$TRANSCRIPT.md")
EOF
)" >"$NOTES"

echo
echo "✅ Done"
echo
echo "Audio:      $AUDIO"
echo "Transcript: $TRANSCRIPT.md"
echo "Notes:      $NOTES"
