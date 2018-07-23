from midi_io import read_file, DEFAULT_FILE

from analyzer import analyze

from note import Frame

WIDTH = 12
SAMPLING = 8

def main():
  note_dict, chord_list = read_file(DEFAULT_FILE)

  framesdump = open("out/frames.txt", "w+")
  for f in chord_list:
    n_out = [note_dict[nid].name for nid in f.notes]
    l_out = '{0:03d} {1}\n'.format(f.index, n_out)
    framesdump.write(l_out)

  framesdump.close()

  scale = None
  progression = ''

  for step in range(0, len(chord_list) - WIDTH, SAMPLING):
    analysis_frames = [[[[note_dict[nid].name, note_dict[nid].function]
                        for nid in f.notes],
                        f.function]
                       for f in chord_list[step:step+WIDTH]]
    print step
    scale, progression = analyze(analysis_frames, note_dict, chord_list, scale)

    # TODO: support key changes
    # TODO: combine progression fragments

    print progression


  print note_dict
  print scale
  print progression

if __name__ == '__main__':
  main()
