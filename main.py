#!/usr/bin/python
from midipy import read_file, DEFAULT_FILE
from midipy import Frame

from analyzer import analyze

import sys, getopt

WIDTH = 12
SAMPLING = 3

def main(argv):
  try:
    opts, args = getopt.getopt(argv,"f:hvd",["file=", "verbose"])
  except getopt.GetoptError:
    print('test.py -f <inputfile>')
    sys.exit(2)

  filepath = ''
  verbose = False
  debug = False
  for opt, arg in opts:
    if opt == '-h':
      print('test.py -f <inputfile>')
      sys.exit()
    elif opt in ('-f', '--file'):
      filepath = arg
    elif opt in ('-v', '--verbose'):
      verbose = True
    elif opt == '-d':
      debug = True

  if filepath == '':
    print('test.py -f <inputfile>')
    sys.exit()

  print('Reading from file', filepath)

  note_dict, chord_list = read_file(filepath)

  framesdump = open("out/frames.txt", "w+")
  print('Writing frames to out/frames.txt')
  for f in chord_list:
    n_out = [note_dict[nid].description for nid in f.notes]
    l_out = '{0:03d} {1}\n'.format(f.index, n_out)
    framesdump.write(l_out)

  framesdump.close()
  print('Finished writing frames to out/frames.txt')

  scale = ['g_sharp', 'major']
  progression = ''

  analysis_chord_list = chord_list
  if debug:
    analysis_chord_list = chord_list[0:24]#[138:205]

  for step in range(0, len(analysis_chord_list) - WIDTH, SAMPLING):
    analysis_frames = [[[[note_dict[nid].name, note_dict[nid].function]
                        for nid in chord.notes],
                        chord.function]
                       for chord in analysis_chord_list[step:step+WIDTH]]
    if verbose:
      print(analysis_frames, step)

    scale, progression = analyze(analysis_frames, note_dict, chord_list, scale)

    if progression == None:
      # Try again without specifying scale, in case of key change
      scale = None
      scale, progression = analyze(analysis_frames, note_dict, chord_list, scale)

    # TODO: combine progression fragments
    if verbose:
      print(scale, progression)


  notesdump = open("out/notedict.txt", "w+")
  notedictstr = '\n'.join("{!s}: {!r}".format(key,val) for (key,val) in note_dict.items())
  notesdump.write(notedictstr+'\n')
  notesdump.close()

  # print note_dict
  # print(chord_list)
  print(scale)
  print(progression)

if __name__ == '__main__':
  # main(sys.argv[1:])
  main(['-f', DEFAULT_FILE, '-v', '-d'])
