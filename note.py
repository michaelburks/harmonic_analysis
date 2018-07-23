from note_consts import note_from_midi_val

class NoteIDProvider:
  next_id = 0
  def new_id(self):
    new_id = self.next_id
    self.next_id += 1
    return new_id


class Note:
  id_provider = NoteIDProvider()

  def __init__(self, val, start_t):
    self.id = self.id_provider.new_id()
    self.val = val
    self.start_t = start_t
    self.end_t = 0
    self.function = 'N{0}'.format(self.id)

  @property
  def name(self):
    return note_from_midi_val(self.val)

  def __repr__(self):
    return "Note({0},{1},{2})".format(self.id, self.val, self.function)


class Frame:
  def __init__(self, notes, index):
    self.index = index
    self.notes = list(notes)
    self.function = 'C{0}'.format(index)
