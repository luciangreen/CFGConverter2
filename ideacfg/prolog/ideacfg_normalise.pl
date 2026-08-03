%% ideacfg_normalise.pl
%% Text normalisation and synonym handling for IdeaCFG.
:- module(ideacfg_normalise,
    [
        normalise_text/2,
        normalise_tokens/2,
        synonym_of/3,
        operation_lexical_form/3,
        normalise_synonym/3
    ]).

:- use_module(library(lists)).

%% synonym_of(?Surface, ?Concept, ?Domain) is nondet.
%  Maps surface forms to canonical concepts.
synonym_of(plus, addition, general).
synonym_of('added to', addition, general).
synonym_of('increased by', addition, general).
synonym_of('the sum of', addition, general).
synonym_of(minus, subtraction, general).
synonym_of('decreased by', subtraction, general).
synonym_of('reduced by', subtraction, general).
synonym_of(times, multiplication, general).
synonym_of('multiplied by', multiplication, general).
synonym_of(over, division, general).
synonym_of('divided by', division, general).
synonym_of(equals, equality, general).
synonym_of('is equal to', equality, general).
synonym_of('greater than', greater_than, general).
synonym_of('more than', greater_than, general).
synonym_of('less than', less_than, general).
synonym_of('fewer than', less_than, general).
synonym_of('at least', at_least, general).
synonym_of('at most', at_most, general).
synonym_of('the average of', average, general).
synonym_of('the mean of', average, general).
synonym_of('the total of', sum, general).
synonym_of('the count of', count, general).
synonym_of('the number of', count, general).
synonym_of('per', rate, general).
synonym_of('for each', rate, general).

%% operation_lexical_form(?Concept, ?Domain, ?Surface) is nondet.
%  Lexical forms for operations.
operation_lexical_form(Concept, Domain, Surface) :-
    synonym_of(Surface, Concept, Domain).

%% normalise_text(+Text, -NormText) is det.
%  Normalises a text atom (lowercase, collapse whitespace).
normalise_text(Text, NormText) :-
    must_be(atom, Text),
    downcase_atom(Text, Lower),
    atom_string(Lower, Str),
    split_string(Str, "", "", [Str]),
    re_replace("\\s+"/g, " ", Str, Norm),
    atom_string(NormText, Norm).

%% normalise_tokens(+Tokens, -Normalised) is det.
%  Normalises a token list.
normalise_tokens(Tokens, Normalised) :-
    must_be(list, Tokens),
    maplist([T, N]>>(downcase_atom(T, N)), Tokens, Normalised).

%% normalise_synonym(+Token, +Domain, -Concept) is semidet.
%  Normalises a token using synonym table for a domain.
normalise_synonym(Token, Domain, Concept) :-
    (   synonym_of(Token, Concept, Domain)
    ->  true
    ;   synonym_of(Token, Concept, general)
    ).
