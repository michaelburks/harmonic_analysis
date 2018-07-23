from pyswip import Prolog

def _stringify(my_list):
  return [_stringify(itm) if type(itm) == type([]) else str(itm)
          for itm in my_list]

def _encode(my_list):
  s = str(my_list)
  return ''.join(s.split('\''))

def analyze(frames, note_dict, chord_list, scale_in):
  """
  Analyze a list of chords (list of list of note constants).
  Returns a list of valid analyses.
  Each has the form [((ScaleRoot, ScaleQuality),
                      [(ChordFunction, ScaleDegree)])]
  """
  prolog = Prolog()
  prolog.consult("analysis.pl")

  scale_var = _encode(scale_in) if scale_in else "Scale"
  result_var = "Result"
  encoded = _encode(frames)

  scale_out = scale_in
  result_out = None

  q_str = "analysis({0},{1},{2})".format(encoded, scale_var, result_var)
  q = prolog.query(q_str, 1)

  for r in q:
    for key in r.keys():
      if key[0] == 'N':
        note_id = int(key[1:])
        note_dict[note_id].function = _stringify(r[key])

      elif key[0] == 'C':
        index = int(key[1:])
        v = r[key]
        if str(v)[0] != "_":
          chord_list[index].function = _stringify(v)

      elif key == scale_var:
        scale_out = _stringify(r[key])

      elif key == result_var:
        result_out = _stringify(r[result_var])

    break

  return scale_out, result_out
