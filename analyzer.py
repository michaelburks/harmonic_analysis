from pyswip import Prolog

def _stringify(my_list):
  return [_stringify(itm) if type(itm) == type([]) else str(itm)
          for itm in my_list]

def _encode(chords):
  s = str(chords)
  return ''.join(s.split('\''))

def analyze(chords):
  """
  Analyze a list of chords (list of list of note constants).
  Returns a list of valid analyses.
  Each has the form [((ScaleRoot, ScaleQuality),
                      [(ChordFunction, ScaleDegree)])]
  """
  prolog = Prolog()
  prolog.consult("chords.pl")

  scale_var = "Scale"
  result_var = "Result"
  encode = _encode(chords)

  q_str = "analyze({0},{1},{2})".format(encode, scale_var, result_var)
  q = prolog.query(q_str)

  results = [(tuple(_stringify(r[scale_var])),
             [tuple(y) for y in _stringify(r[result_var])])
            for r in q]

  return results
