# harmonic_analysis
Harmonic analysis of MIDI files using Python and Prolog.

The python scripts invoke prolog rules with a list of (note, function) pairs.
Notes and functions are each initialized to a unique prolog variable.

A massive prolog query is constructed from combining the queries for each sample.

A single sample query:
```
analysis([[[c, N0], [e, N1]],
         [[c, N0], [g, N2]]]).
```

Or in general:
```
analysis(sample).
```

`sample` is a `[frame]`.

`frame` is a `[[note, function_var]]`.

`function_var` will either be a chord with root, quality, and function or an nht with note and type.
