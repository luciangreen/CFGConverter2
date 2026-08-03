%% ideacfg_tokenise.pl
%% Tokenisation for IdeaCFG.
:- module(ideacfg_tokenise,
    [
        tokenise_text/2,
        tokenise_sentence/2,
        normalise_token/2,
        split_sentences/2
    ]).

:- use_module(library(lists)).

%% tokenise_text(+Text, -Tokens) is det.
%  Tokenises a text atom into a list of lowercase atom tokens.
tokenise_text(Text, Tokens) :-
    must_be(atom, Text),
    atom_string(Text, Str),
    split_string(Str, " \t\n\r", " \t\n\r.,;:!?()[]{}\"'", Parts),
    include([P]>>(P \= ""), Parts, NonEmpty),
    maplist([S, T]>>(atom_string(A, S), downcase_atom(A, T)), NonEmpty, Tokens).

%% tokenise_sentence(+Sentence, -Tokens) is det.
%  Tokenises a single sentence.
tokenise_sentence(Sentence, Tokens) :-
    tokenise_text(Sentence, Tokens).

%% normalise_token(+Token, -Normalised) is det.
%  Normalises a token (lowercase, trim).
normalise_token(Token, Normalised) :-
    downcase_atom(Token, Normalised).

%% split_sentences(+Text, -Sentences) is det.
%  Splits text into sentences based on punctuation.
split_sentences(Text, Sentences) :-
    must_be(atom, Text),
    atom_string(Text, Str),
    split_string(Str, ".!?", "", RawSentences),
    maplist([S, A]>>(string_concat("", S, S2), atom_string(A, S2)), RawSentences, All),
    include([A]>>(atom_length(A, L), L > 0), All, SentencesConcats),
    maplist([A, Trimmed]>>(atom_string(A, Str2),
                            string_trim(Str2, TrimStr),
                            atom_string(Trimmed, TrimStr)), SentencesConcats, Sentences).

string_trim(Str, Trimmed) :-
    split_string(Str, "", " \t\n\r", [Trimmed|_]).
