# Define note constants
c = "c"
c_sharp = "c_sharp"
d_flat = "c_sharp"
d = "d"
d_sharp = "d_sharp"
e_flat = "d_sharp"
e = "e"
f = "f"
f_sharp = "f_sharp"
g_flat = "f_sharp"
g = "g"
g_sharp = "g_sharp"
a = "a"
a_sharp = "a_sharp"
b_flat = "a_sharp"
b = "b"

def note_from_midi_val(midi_val):
  n = midi_val % 12
  return [c, c_sharp, d, d_sharp, e, f, f_sharp, g, g_sharp, a, a_sharp, b][n]
