%% ideacfg_concepts.pl
%% Concept and category extraction from IR.
:- module(ideacfg_concepts,
    [
        extract_concepts/3,
        extract_concepts_from_tokens/3,
        concept_type/1,
        is_concept_word/1,
        build_concept/5
    ]).

:- use_module(ideacfg_ir).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% concept_type(?Type) is nondet.
%  Enumerates concept types.
concept_type(category).
concept_type(entity).
concept_type(process).
concept_type(stage).
concept_type(property).
concept_type(relation_concept).
concept_type(operation_concept).
concept_type(unknown).

%% extract_concepts(+IdeaName, +IR, -Concepts) is det.
%  Extracts concepts from the IR elements, producing a list of concept terms.
extract_concepts(IdeaName, IR, Concepts) :-
    must_be(atom, IdeaName),
    ir_elements(IR, Elems),
    foldl([Elem, Acc0, Acc1]>>(
              extract_concepts_from_element(Elem, NewConcepts),
              append(Acc0, NewConcepts, Acc1)
          ), Elems, [], Concepts).

%% extract_concepts_from_element(+Element, -Concepts) is det.
%  Extracts concepts from a single IR element.
extract_concepts_from_element(assumption(Id, Text, _, Src), Concepts) :-
    atom(Text),
    tokenise_element(Text, Tokens),
    extract_concepts_from_tokens(Id, Tokens, Concepts),
    (   Concepts = []
    ->  emit_diagnostic(info, no_concepts, 'No concepts found in sentence', Src, [Id], 'Add more descriptive text')
    ;   true
    ).
extract_concepts_from_element(concept(Id, Label, Type, Props, Src),
                              [concept(Id, Label, Type, Props, Src)]).
extract_concepts_from_element(_, []).

%% extract_concepts_from_tokens(+ContextId, +Tokens, -Concepts) is det.
%  Extracts concepts from a token list.
extract_concepts_from_tokens(ContextId, Tokens, Concepts) :-
    must_be(list, Tokens),
    findall(concept(ConceptId, Label, Type, [], source_tokens),
            (   find_concept_in_tokens(Tokens, Label, Type),
                atomic_list_concat([ContextId, '_', Label], ConceptId)
            ),
            Concepts).

%% find_concept_in_tokens(+Tokens, -Label, -Type) is nondet.
%  Identifies concept-like tokens using structural patterns.
find_concept_in_tokens(Tokens, Label, Type) :-
    phrase(concept_pattern(Label, Type), Tokens, _).
find_concept_in_tokens(Tokens, Label, category) :-
    append(_, [Kw, Label|_], Tokens),
    concept_keyword(Kw),
    atom(Label),
    is_concept_word(Label).

%% concept_pattern(-Label, -Type)// is nondet.
%  DCG for recognising concept patterns in token sequences.
concept_pattern(Label, category) --> [a], [Label], { atom(Label), is_concept_word(Label) }.
concept_pattern(Label, category) --> [an], [Label], { atom(Label), is_concept_word(Label) }.
concept_pattern(Label, process) --> [the], [Label], { atom(Label) }, [process].
concept_pattern(Label, stage) --> [Label], { atom(Label) }, [stage].

%% concept_keyword(?Keyword) is nondet.
%  Keywords that introduce concepts.
concept_keyword(a).
concept_keyword(an).
concept_keyword(the).

%% is_concept_word(+Atom) is semidet.
%  True when the atom looks like a concept word (not a stopword).
is_concept_word(W) :-
    atom(W),
    \+ stopword(W),
    atom_length(W, L),
    L > 2.

stopword(is).   stopword(are).  stopword(has).  stopword(have).
stopword(in).   stopword(on).   stopword(of).   stopword(to).
stopword(and).  stopword(or).   stopword(not).  stopword(may).
stopword(can).  stopword(will). stopword(its).  stopword(their).
stopword(each). stopword(all).  stopword(any).  stopword(one).
stopword(two).  stopword(three). stopword(by).  stopword(be).
stopword(with). stopword(from). stopword(that). stopword(this).
stopword(into). stopword(for).  stopword(than). stopword(more).
stopword(less). stopword(when). stopword(then). stopword(where).
stopword(most). stopword(also). stopword(must). stopword(only).

%% build_concept(+Id, +Label, +Type, +Properties, +Source) is det.
%  Constructs a concept term.
build_concept(Id, Label, Type, Properties, concept(Id, Label, Type, Properties, Source)) :-
    must_be(atom, Id),
    must_be(atom, Label),
    must_be(atom, Type),
    source_location(0, Source).

tokenise_element(Text, Tokens) :-
    atom(Text),
    atomic_list_concat(Parts, ' ', Text),
    maplist([P, T]>>(downcase_atom(P, T)), Parts, Tokens).
