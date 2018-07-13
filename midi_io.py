import mido

from notes import note_from_midi_val

def read_midi(filename):
  '''
    returns data with contents of filename.
    data has shape (-1, channel count).
  '''
  file = mido.MidiFile(filename)
  c = extract_chords(file)
  return c

def extract_chords(midifile):
    notes = []
    chords = []

    for trk in midifile.tracks:
        current_notes = []
        note_stack = {}
        time = 0
        for msg in trk:
            if msg.time > 0:
              chords.append(_notes(current_notes))
            time += msg.time
            note_on = msg.type == 'note_on' and msg.velocity > 0
            note_off = (msg.type == 'note_on' and msg.velocity == 0) or msg.type == 'note_off'
            if note_on:
                note_stack[msg.note] = (time, msg.velocity)
                current_notes.append(msg.note)
            elif note_off:
                n = note_stack.pop(msg.note, None)
                if n:
                    (t, v) = n
                    d = time-t
                    current_notes.remove(msg.note)
                    notes.append([msg.note])
    return chords

def _notes(midi_list):
  l = [note_from_midi_val(m) for m in midi_list]
  return list(set(l))
