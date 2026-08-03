%% ideacfg_relations.pl
%% Relation extraction: sequences, alternatives, optionality, repetition, causation.
:- module(ideacfg_relations,
    [
        extract_relations/3,
        extract_sequences/2,
        extract_alternatives/2,
        extract_optionals/2,
        extract_repetitions/2,
        extract_causal/2
    ]).

:- use_module(ideacfg_ir).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% extract_relations(+IdeaName, +IR, -Relations) is det.
%  Extracts all relations from the IR.
extract_relations(IdeaName, IR, Relations) :-
    must_be(atom, IdeaName),
    ir_elements(IR, Elems),
    foldl([Elem, Acc0, Acc1]>>(
              extract_relations_from_element(IdeaName, Elem, New),
              append(Acc0, New, Acc1)
          ), Elems, [], Relations).

%% extract_relations_from_element(+IdeaName, +Element, -Relations) is det.
extract_relations_from_element(IdeaName, assumption(Id, Text, _, Src), Relations) :-
    atom(Text),
    tokenise_rel(Text, Tokens),
    (   detect_sequence(Id, Tokens, Src, Seq)
    ->  Relations = [Seq]
    ;   detect_alternatives(Id, Tokens, Src, Alt)
    ->  Relations = [Alt]
    ;   detect_optional(Id, Tokens, Src, Opt)
    ->  Relations = [Opt]
    ;   detect_repetition(Id, Tokens, Src, Rep)
    ->  Relations = [Rep]
    ;   detect_causal(Id, Tokens, Src, Causal)
    ->  Relations = [Causal]
    ;   Relations = []
    ),
    (   Relations = []
    ->  emit_diagnostic(info, no_relation, 'No structural relation found', Src, [IdeaName, Id], 'Consider rephrasing')
    ;   true
    ).
extract_relations_from_element(_, relation(Type, From, To, Props, Src),
                               [relation(Type, From, To, Props, Src)]).
extract_relations_from_element(_, sequence(Id, Members, Props, Src),
                               [sequence(Id, Members, Props, Src)]).
extract_relations_from_element(_, alternative(Id, Members, Props, Src),
                               [alternative(Id, Members, Props, Src)]).
extract_relations_from_element(_, optional(Id, Member, Props, Src),
                               [optional(Id, Member, Props, Src)]).
extract_relations_from_element(_, repetition(Id, Member, Min, Max, Props, Src),
                               [repetition(Id, Member, Min, Max, Props, Src)]).
extract_relations_from_element(_, _, []).

%% extract_sequences(+IR, -Sequences) is det.
%  Extracts sequence elements from IR.
extract_sequences(IR, Sequences) :-
    ir_elements(IR, Elems),
    include([E]>>(E = sequence(_, _, _, _)), Elems, Sequences).

%% extract_alternatives(+IR, -Alternatives) is det.
%  Extracts alternative elements from IR.
extract_alternatives(IR, Alternatives) :-
    ir_elements(IR, Elems),
    include([E]>>(E = alternative(_, _, _, _)), Elems, Alternatives).

%% extract_optionals(+IR, -Optionals) is det.
%  Extracts optional elements from IR.
extract_optionals(IR, Optionals) :-
    ir_elements(IR, Elems),
    include([E]>>(E = optional(_, _, _, _)), Elems, Optionals).

%% extract_repetitions(+IR, -Repetitions) is det.
%  Extracts repetition elements from IR.
extract_repetitions(IR, Repetitions) :-
    ir_elements(IR, Elems),
    include([E]>>(E = repetition(_, _, _, _, _, _)), Elems, Repetitions).

%% extract_causal(+IR, -Causals) is det.
%  Extracts causal relations from IR.
extract_causal(IR, Causals) :-
    ir_elements(IR, Elems),
    include([E]>>(E = relation(cause, _, _, _, _) ; E = relation(precedes, _, _, _, _)),
            Elems, Causals).

% --- Internal pattern detection ---

detect_sequence(Id, Tokens, Src, sequence(SeqId, Members, [], Src)) :-
    phrase(sequence_pattern(Members), Tokens, _),
    Members = [_|_],
    atomic_list_concat([Id, '_seq'], SeqId).

detect_alternatives(Id, Tokens, Src, alternative(AltId, Members, [], Src)) :-
    phrase(alternatives_pattern(Members), Tokens, _),
    Members = [_,_|_],
    atomic_list_concat([Id, '_alt'], AltId).

detect_optional(Id, Tokens, Src, optional(OptId, Member, [], Src)) :-
    phrase(optional_pattern(Member), Tokens, _),
    atomic_list_concat([Id, '_opt'], OptId).

detect_repetition(Id, Tokens, Src, repetition(RepId, Member, 1, unbounded, [], Src)) :-
    phrase(repetition_pattern(Member), Tokens, _),
    atomic_list_concat([Id, '_rep'], RepId).

detect_causal(Id, Tokens, Src, relation(cause, Cause, Effect, [], Src)) :-
    phrase(causal_pattern(Cause, Effect), Tokens, _),
    atomic_list_concat([Id, '_cause'], _).

% Sequence: "X contains A, B and C" or "X consists of A and B" or "X has A, B and C"
sequence_pattern(Members) -->
    skip_tokens(_),
    [contains], !,
    noun_list(Members),
    skip_tokens(_).
sequence_pattern(Members) -->
    skip_tokens(_),
    ['consists', of], !,
    noun_list(Members),
    skip_tokens(_).
sequence_pattern(Members) -->
    skip_tokens(_),
    [begins, with], !,
    noun_list(Members),
    skip_tokens(_).
sequence_pattern(Members) -->
    skip_tokens(_),
    [has], !,
    noun_list(Members),
    skip_tokens(_).
sequence_pattern(Members) -->
    skip_tokens(_),
    [have], !,
    noun_list(Members),
    skip_tokens(_).

% Alternatives: "X may be A, B or C" or "X can be A or B"
alternatives_pattern(Members) -->
    skip_tokens(_),
    alt_keyword, !,
    noun_list_or(Members),
    skip_tokens(_).

alt_keyword --> [may, be].
alt_keyword --> [can, be].
alt_keyword --> ['may use'].
alt_keyword --> [is, either].
alt_keyword --> [either].

% Optional: "may include X" or "may contain X"
optional_pattern(Member) -->
    skip_tokens(_),
    opt_keyword,
    [Member], { atom(Member), \+ connector(Member) },
    skip_tokens(_).

opt_keyword --> [may, include].
opt_keyword --> [may, contain].
opt_keyword --> [optionally].
opt_keyword --> [may, have].

% Repetition: "one or more X" or "X or more"
repetition_pattern(Member) -->
    skip_tokens(_),
    [one, or, more],
    [Member], { atom(Member) },
    skip_tokens(_).
repetition_pattern(Member) -->
    skip_tokens(_),
    [Member], { atom(Member) },
    [or, more],
    skip_tokens(_).

% Causal: "X causes Y" or "X leads to Y"
causal_pattern(Cause, Effect) -->
    [Cause], { atom(Cause), \+ connector(Cause) },
    causal_verb,
    [Effect], { atom(Effect), \+ connector(Effect) },
    skip_tokens(_).

causal_verb --> [causes].
causal_verb --> [leads, to].
causal_verb --> [results, in].
causal_verb --> [produces].

% Noun lists
noun_list([N|Ns]) --> opt_article, [N], { atom(N), \+ connector(N), \+ article(N) }, noun_list_cont(Ns).
noun_list([N]) --> opt_article, [N], { atom(N), \+ connector(N), \+ article(N) }.

noun_list_cont([N|Ns]) --> [','], opt_article, [N], { atom(N), \+ connector(N), \+ article(N) }, noun_list_cont(Ns).
noun_list_cont([N]) --> [and], opt_article, [N], { atom(N), \+ connector(N), \+ article(N) }.
noun_list_cont([]) --> [].

noun_list_or([N|Ns]) --> opt_article, [N], { atom(N), \+ connector(N), \+ article(N) }, noun_list_or_cont(Ns).
noun_list_or_cont([N|Ns]) --> [','], opt_article, [N], { atom(N), \+ connector(N), \+ article(N) }, noun_list_or_cont(Ns).
noun_list_or_cont([N]) --> [or], opt_article, [N], { atom(N), \+ connector(N), \+ article(N) }.
noun_list_or_cont([]) --> [].

opt_article --> [A], { article(A) }, !.
opt_article --> [].

article(a). article(an). article(the).

% Skip any tokens
skip_tokens([]) --> [].
skip_tokens([H|T]) --> [H], skip_tokens(T).

connector(and). connector(or). connector(',').
connector(a). connector(an). connector(the).
connector(is). connector(are). connector(has).
connector(may). connector(can). connector(will).

tokenise_rel(Text, Tokens) :-
    downcase_atom(Text, Lower),
    atom_string(Lower, LowerStr),
    split_string(LowerStr, " \t\n\r", " \t\n\r.;:!?", Parts),
    include([P]>>(P \= ""), Parts, NonEmpty),
    maplist([S, Toks]>>(split_on_commas(S, Toks)), NonEmpty, TokLists),
    flatten(TokLists, Tokens).

split_on_commas(S, Toks) :-
    split_string(S, ",", "", Parts),
    (   Parts = [_SinglePart]
    ->  % No commas in S at all
        atom_string(T, S), Toks = [T]
    ;   % Has commas: collect non-empty parts as words
        include([P]>>(P \= ""), Parts, NonEmptyParts),
        maplist([Str, Tok]>>(atom_string(Tok, Str)), NonEmptyParts, WordToks),
        % Check if S ends in comma
        last(Parts, LastPart),
        (   LastPart = ""
        ->  % Trailing comma: words came with commas between/after them
            interleave_commas(WordToks, WithCommas),
            append(WithCommas, [','], Toks)
        ;   interleave_commas(WordToks, Toks)
        )
    ).

interleave_commas([], []).
interleave_commas([W], [W]) :- !.
interleave_commas([W|Ws], [W, ','|Rest]) :-
    interleave_commas(Ws, Rest).
