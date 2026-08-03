%% ideacfg_operations.pl
%% Mathematical and directly computable operation extraction.
:- module(ideacfg_operations,
    [
        extract_operations/3,
        classify_operation/3,
        decide_execution_mode/3,
        operation_class/1,
        execution_mode/1,
        operation_dependency/3,
        topo_sort_operations/2,
        is_operation_phrase/2,
        operation_lexicon/2
    ]).

:- use_module(ideacfg_ir).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% operation_class(?Class) is nondet.
operation_class(arithmetic).
operation_class(comparison).
operation_class(aggregation).
operation_class(transformation).
operation_class(constraint).
operation_class(lookup).
operation_class(logical).
operation_class(probabilistic).
operation_class(symbolic).
operation_class(external).
operation_class(unknown).

%% execution_mode(?Mode) is nondet.
execution_mode(direct_prolog).
execution_mode(cfg_enumeration).
execution_mode(hybrid).
execution_mode(deferred).
execution_mode(unsupported).

%% operation_lexicon(?Phrase, ?Class) is nondet.
%  Maps linguistic phrases to operation classes.
operation_lexicon(add, arithmetic).
operation_lexicon(subtract, arithmetic).
operation_lexicon(multiply, arithmetic).
operation_lexicon(divide, arithmetic).
operation_lexicon('increase by', arithmetic).
operation_lexicon('decrease by', arithmetic).
operation_lexicon(twice, arithmetic).
operation_lexicon(half, arithmetic).
operation_lexicon('percentage of', arithmetic).
operation_lexicon(average, aggregation).
operation_lexicon(total, aggregation).
operation_lexicon(difference, arithmetic).
operation_lexicon(ratio, arithmetic).
operation_lexicon(per, arithmetic).
operation_lexicon('for each', arithmetic).
operation_lexicon('equal to', comparison).
operation_lexicon('greater than', comparison).
operation_lexicon('less than', comparison).
operation_lexicon('at least', comparison).
operation_lexicon('at most', comparison).
operation_lexicon(between, comparison).
operation_lexicon(calculate, arithmetic).
operation_lexicon(compute, arithmetic).
operation_lexicon(measure, arithmetic).
operation_lexicon(convert, transformation).
operation_lexicon(transform, transformation).
operation_lexicon('shift by', transformation).
operation_lexicon('rotate by', transformation).
operation_lexicon(count, aggregation).
operation_lexicon(sum, aggregation).
operation_lexicon(rank, aggregation).
operation_lexicon(sort, aggregation).
operation_lexicon(minimum, aggregation).
operation_lexicon(maximum, aggregation).
operation_lexicon('multiplied by', arithmetic).
operation_lexicon('divided by', arithmetic).
operation_lexicon('added to', arithmetic).
operation_lexicon('the sum of', aggregation).
operation_lexicon('the mean of', aggregation).
operation_lexicon('the average of', aggregation).
operation_lexicon('the product of', aggregation).
operation_lexicon('raised to', arithmetic).
operation_lexicon(squared, arithmetic).
operation_lexicon(cubed, arithmetic).
operation_lexicon(distance, arithmetic).
operation_lexicon(duration, arithmetic).
operation_lexicon(rate, arithmetic).
operation_lexicon(probability, probabilistic).
operation_lexicon(combination, arithmetic).
operation_lexicon(permutation, arithmetic).

%% is_operation_phrase(+Tokens, -Class) is semidet.
%  True when token list contains an operation indicator.
is_operation_phrase(Tokens, Class) :-
    operation_lexicon(Phrase, Class),
    (   atom(Phrase)
    ->  memberchk(Phrase, Tokens)
    ;   atomic_list_concat(PhraseTokens, ' ', Phrase),
        sublist(PhraseTokens, Tokens)
    ).

sublist(Sub, List) :-
    append(_, Rest, List),
    append(Sub, _, Rest).

%% extract_operations(+IdeaName, +IR, -Operations) is det.
%  Extracts operation elements from IR elements.
extract_operations(IdeaName, IR, Operations) :-
    must_be(atom, IdeaName),
    ir_elements(IR, Elems),
    foldl([Elem, Acc0, Acc1]>>(
              extract_ops_from_element(IdeaName, Elem, Ops),
              append(Acc0, Ops, Acc1)
          ), Elems, [], Operations).

extract_ops_from_element(IdeaName, assumption(Id, Text, _, Src), Ops) :-
    atom(Text),
    tokenise_ops(Text, Tokens),
    findall(operation(OpId, Class, Inputs, Output, direct, [source_phrase(Phrase)], Src),
            (   operation_lexicon(Phrase, Class),
                (   atom(Phrase)
                ->  memberchk(Phrase, Tokens)
                ;   atomic_list_concat(PT, ' ', Phrase),
                    sublist(PT, Tokens)
                ),
                extract_op_args(Tokens, Phrase, Inputs, Output),
                atomic_list_concat([IdeaName, '_', Id, '_', Phrase], '_', OpId0),
                sanitise_id(OpId0, OpId)
            ),
            Ops).
extract_ops_from_element(_, operation(Id, Class, In, Out, Mode, Props, Src),
                         [operation(Id, Class, In, Out, Mode, Props, Src)]).
extract_ops_from_element(_, _, []).

extract_op_args(Tokens, _Phrase, [], result) :-
    \+ memberchk(result, Tokens).

%% classify_operation(+Phrase, +Tokens, -Class) is det.
classify_operation(Phrase, _Tokens, Class) :-
    (   operation_lexicon(Phrase, Class)
    ->  true
    ;   Class = unknown
    ).

%% decide_execution_mode(+Class, +Tokens, -Mode) is det.
decide_execution_mode(arithmetic, _, direct_prolog) :- !.
decide_execution_mode(comparison, _, direct_prolog) :- !.
decide_execution_mode(aggregation, _, direct_prolog) :- !.
decide_execution_mode(transformation, Tokens, Mode) :-
    (   is_qualitative(Tokens)
    ->  Mode = cfg_enumeration
    ;   Mode = hybrid
    ), !.
decide_execution_mode(probabilistic, _, direct_prolog) :- !.
decide_execution_mode(_, _, deferred).

is_qualitative(Tokens) :-
    memberchk(choice, Tokens) ; memberchk(select, Tokens) ; memberchk(pick, Tokens).

%% operation_dependency(+Op1, +Op2, +Ops) is nondet.
%  True when Op1's output is an input to Op2.
operation_dependency(Op1, Op2, Ops) :-
    memberchk(Op1, Ops),
    memberchk(Op2, Ops),
    Op1 = operation(_, _, _, Out1, _, _, _),
    Op2 = operation(_, _, In2, _, _, _, _),
    Out1 \= [],
    memberchk(Out1, In2).

%% topo_sort_operations(+Ops, -Sorted) is det.
%  Topological sort of operations by dependency.
topo_sort_operations(Ops, Sorted) :-
    findall(A-B, operation_dependency(A, B, Ops), Edges),
    topo_sort(Ops, Edges, Sorted).

topo_sort(Nodes, [], Nodes) :- !.
topo_sort(Nodes, Edges, Sorted) :-
    findall(N, (memberchk(N, Nodes), \+ memberchk(_-N, Edges)), Roots),
    Roots \= [],
    subtract(Nodes, Roots, Rest),
    findall(A-B, (memberchk(A-B, Edges), \+ memberchk(A, Roots)), RestEdges),
    topo_sort(Rest, RestEdges, SortedRest),
    append(Roots, SortedRest, Sorted).
topo_sort(Nodes, _Edges, Nodes).

tokenise_ops(Text, Tokens) :-
    downcase_atom(Text, Lower),
    atom_string(Lower, LowerStr),
    split_string(LowerStr, " \t\n\r", " \t\n\r.,;:!?", Parts),
    include([P]>>(P \= ""), Parts, NonEmpty),
    maplist([S, T]>>(atom_string(T, S)), NonEmpty, Tokens).

sanitise_id(Raw, Clean) :-
    atom_string(Raw, Str),
    re_replace("[^a-z0-9_]"/g, "_", Str, Cleaned),
    atom_string(Clean, Cleaned).
