%% ideacfg_input.pl
%% Input handling for IdeaCFG: accepts text, sentence lists, and structured terms.
:- module(ideacfg_input,
    [
        idea_from_text/3,
        idea_from_sentences/3,
        idea_from_terms/3,
        idea_from_hybrid/4,
        source_location/2
    ]).

:- use_module(ideacfg_ir).
:- use_module(ideacfg_tokenise).
:- use_module(ideacfg_normalise).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% idea_from_text(+IdeaName, +Text, -Model) is det.
%  Converts plain text into an initial IR model.
idea_from_text(IdeaName, Text, Model) :-
    must_be(atom, IdeaName),
    must_be(atom, Text),
    split_sentences(Text, Sentences),
    maplist([S, sent(S, Toks)]>>(tokenise_sentence(S, Toks)), Sentences, SentenceData),
    build_initial_ir(IdeaName, SentenceData, Model).

%% idea_from_sentences(+IdeaName, +Sentences, -Model) is det.
%  Converts a list of sentence atoms into an IR model.
idea_from_sentences(IdeaName, Sentences, Model) :-
    must_be(atom, IdeaName),
    must_be(list, Sentences),
    maplist([S]>>(must_be(atom, S)), Sentences),
    maplist([S, sent(S, Toks)]>>(tokenise_sentence(S, Toks)), Sentences, SentenceData),
    build_initial_ir(IdeaName, SentenceData, Model).

%% idea_from_terms(+IdeaName, +Terms, -Model) is det.
%  Converts a list of structured Prolog terms into an IR model.
idea_from_terms(IdeaName, Terms, Model) :-
    must_be(atom, IdeaName),
    must_be(list, Terms),
    foldl([Term, IR0, IR1]>>(interpret_term(Term, Elem, IdeaName),
                              ir_add_element(IR0, Elem, IR1)),
          Terms,
          idea(IdeaName, [source(structured)], []),
          Model).

%% idea_from_hybrid(+IdeaName, +Text, +Declarations, -Model) is det.
%  Combines plain-text input with explicit declarations.
idea_from_hybrid(IdeaName, Text, Declarations, Model) :-
    idea_from_text(IdeaName, Text, TextModel),
    foldl([Decl, M0, M1]>>(apply_declaration(Decl, M0, M1)),
          Declarations, TextModel, Model).

%% source_location(+SentenceIndex, -SourceLoc) is det.
%  Creates a source location term.
source_location(Idx, source_line(Idx)).

%% build_initial_ir(+Name, +SentenceData, -IR) is det.
%  Builds an initial IR from tokenised sentences.
build_initial_ir(Name, SentenceData, idea(Name, [source(text)], Elements)) :-
    build_sentence_elements(Name, SentenceData, 1, Elements).

build_sentence_elements(_, [], _, []).
build_sentence_elements(Name, [sent(S, _Toks)|Rest], Idx, [Elem|Elems]) :-
    atomic_list_concat([Name, sent, Idx], '_', SentId),
    Elem = assumption(SentId, S, extracted_from_text, source_line(Idx)),
    Idx1 is Idx + 1,
    build_sentence_elements(Name, Rest, Idx1, Elems).

%% interpret_term(+Term, -IRElement, +IdeaName) is semidet.
%  Interprets a structured Prolog term as an IR element.
interpret_term(concept(Id), concept(Id, Id, category, [], source_term), _).
interpret_term(concept(Id, Label), concept(Id, Label, category, [], source_term), _).
interpret_term(stage(Id), concept(Id, Id, stage, [], source_term), _).
interpret_term(precedes(A, B), relation(precedes, A, B, [], source_term), _).
interpret_term(requires(A, B), relation(requires, A, B, [], source_term), _).
interpret_term(operation(Id, Class), operation(Id, Class, [], [], direct, [], source_term), _).
% Full-form terms passed directly through:
interpret_term(alternative(Id, Members), alternative(Id, Members, [], source_term), _).
interpret_term(alternative(Id, Members, Props, Src), alternative(Id, Members, Props, Src), _).
interpret_term(sequence(Id, Members), sequence(Id, Members, [], source_term), _).
interpret_term(sequence(Id, Members, Props, Src), sequence(Id, Members, Props, Src), _).
interpret_term(optional(Id, Member), optional(Id, Member, [], source_term), _).
interpret_term(optional(Id, Member, Props, Src), optional(Id, Member, Props, Src), _).
interpret_term(repetition(Id, Mem, Min, Max, Props, Src), repetition(Id, Mem, Min, Max, Props, Src), _).
interpret_term(operation(Id, Class, In, Out, Mode, Props, Src),
               operation(Id, Class, In, Out, Mode, Props, Src), _).
interpret_term(constraint(Id, Type, Args, Props, Src), constraint(Id, Type, Args, Props, Src), _).
interpret_term(relation(Type, From, To, Props, Src), relation(Type, From, To, Props, Src), _).
interpret_term(Other, assumption(unknown, Other, unrecognised_term, source_term), _).

%% apply_declaration(+Decl, +IR0, -IR1) is det.
%  Applies a declaration to an IR.
apply_declaration(operation(Id, direct), IR0, IR1) :-
    ir_add_element(IR0, operation(Id, unknown, [], [], direct, [explicit_declaration], source_decl), IR1).
apply_declaration(maximum_recursion_depth(_), IR, IR).
apply_declaration(dialect(_), IR, IR).
apply_declaration(_, IR, IR).
