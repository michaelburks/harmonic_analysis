import mido

from note import Note, Frame

from note_consts import note_from_midi_val

DEFAULT_FILE = '/Users/michael/Desktop/MIDI_Archive/Classical_Piano/format0/pathetique_2_format0.mid'

def read_file(filepath):
  """
    Reads a format0 midi file, creating Note objects for each note and compiling
    a list of frames (snapshots of active notes) for each midi time increment.
  """
  midifile = mido.MidiFile(filepath)

  notes = {}  # { note_id : note }
  frames = [] # [ [note_id] ] Each frame is a list of note ids

  for trk in midifile.tracks:
    current_note_ids = []
    current_notes = {}  # { midi_val : note }

    time = 0
    for msg in trk:
      if msg.time > 0: # Grab frame
        if len(frames) == 0 or frames[-1] != current_note_ids:
          frames.append(Frame(current_note_ids, len(frames)))

      time += msg.time
      note_on = msg.type == 'note_on' and msg.velocity > 0
      note_off = (msg.type == 'note_on' and msg.velocity == 0) or msg.type == 'note_off'

      if note_on:
        n = current_notes.pop(msg.note, None)
        if n:
          n.end_t = time
          current_note_ids.remove(n.id)

        new_note = Note(msg.note, time)

        # Register note
        notes[new_note.id] = new_note
        current_notes[msg.note] = new_note

        current_note_ids.append(new_note.id)

      elif note_off:
        n = current_notes.pop(msg.note, None)
        if n:
          n.end_t = time
          current_note_ids.remove(n.id)

  return notes, frames
