%% music/melody.pl — Melody and transposition example.
:- use_module('../../prolog/ideacfg_api').
:- use_module(library(lists)).

%% Idea: Melody with transposition.
%
% A melody contains notes and transformations.
% Transposition adds a fixed number of semitones to each note.

music_example(Result) :-
    idea_to_cfg(melody,
        [sequence(melody, [notes, transformation], [], src),
         alternative(transformation, [transposition, inversion, retrograde], [], src),
         operation(transpose, transformation, [pitches, semitones], pitches, direct, [], src)],
        Result).

%% transpose_pitches(+Pitches, +Semitones, -Transposed) is det.
%  Transposes a list of MIDI pitches by the given number of semitones.
transpose_pitches(Pitches, Semitones, Transposed) :-
    must_be(list, Pitches),
    must_be(integer, Semitones),
    maplist([P, T]>>(
                must_be(integer, P),
                T0 is P + Semitones,
                (   T0 < 0   -> T = 0
                ;   T0 > 127 -> T = 127
                ;   T = T0
                )
            ), Pitches, Transposed).

%% transpose_pitch(+Pitch, +Semitones, -Result) is det.
transpose_pitch(Pitch, Semitones, Result) :-
    must_be(integer, Pitch),
    must_be(integer, Semitones),
    R0 is Pitch + Semitones,
    Result is max(0, min(127, R0)).
