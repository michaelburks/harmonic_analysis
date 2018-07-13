from midi_io import read_midi

from analyzer import analyze

file = '/Users/michael/Desktop/MIDI_Archive/Classical_Piano/format0/pathetique_2_format0.mid'

def main():

  file_chords = read_midi(file)[0:5]

  sanitized = []
  for l in file_chords:
    while len(l) < 3:
      l.append('_')
    sanitized.append(l)

  results = analyze(sanitized)
  # print sanitized
  print results

if __name__ == '__main__':
  main()
