%% cfg2_validate.pl
%% Input and grammar validation for CFG Converter 2.

:- module(cfg2_validate,
    [
        validate_evidence_list/3,
        validate_grammar/3,
        validate_ir/3,
        check_safety/3,
        validate_options/2,
        diagnostic_error/3,
        validation_passed/1
    ]).

:- use_module(library(lists)).
:- use_module(cfg2_evidence).
:- use_module(cfg2_departments).

%% validate_evidence_list(+EvidenceList, +Options, -Errors) is det.
validate_evidence_list([], _, []).
validate_evidence_list([E|Es], Options, Errors) :-
    validate_evidence_term(E, Options, EErrs),
    validate_evidence_list(Es, Options, RestErrs),
    append(EErrs, RestErrs, Errors).

%% validate_grammar(+CFGRules, +Options, -Errors) is det.
validate_grammar(Rules, _Options, Errors) :-
    check_duplicate_rules(Rules, DupErrs),
    check_unreachable_rules(Rules, UnreachErrs),
    check_undefined_nonterminals(Rules, UndefErrs),
    append([DupErrs, UnreachErrs, UndefErrs], Errors).

check_duplicate_rules(Rules, Errors) :-
    maplist([R, K]>>(
        (   R = cfg_rule(_, LHS, RHS, _)
        ->  K = LHS-RHS
        ;   R = cfg_rule(LHS, RHS)
        ->  K = LHS-RHS
        ;   K = unknown
        )
    ), Rules, Keys),
    msort(Keys, Sorted),
    findall(error(duplicate_rule, duplicate, K),
            (member(K, Sorted), \+ select(K, Sorted, Sorted2), \+ Sorted = Sorted2),
            Errors0),
    sort(Errors0, Errors).

check_unreachable_rules(Rules, []) :- % Simplified: no unreachability check yet.
    true.

check_undefined_nonterminals(Rules, Errors) :-
    maplist([R, LHS]>>(
        ( R = cfg_rule(_, LHS, _, _) -> true
        ; R = cfg_rule(LHS, _) -> true
        ; LHS = unknown )
    ), Rules, LHSList),
    maplist([R, RHS]>>(
        ( R = cfg_rule(_, _, RHS, _) -> true
        ; R = cfg_rule(_, RHS) -> true
        ; RHS = [] )
    ), Rules, RHSList),
    flatten(RHSList, AllRHS),
    include(atom, AllRHS, NonTerminals),
    exclude(member(LHSList), NonTerminals, Undefined),
    maplist([NT, error(undefined_nonterminal, undefined, NT)]>>true, Undefined, Errors).

%% validate_ir(+IR, +Options, -Errors) is det.
validate_ir(IR, _Options, Errors) :-
    (   IR = cfg2_ir(Name, _, Concepts, Relations, _, Evidence, _, _, _, _)
    ->  (atom(Name) -> Errs0 = [] ; Errs0 = [error(ir_name, atom, Name)]),
        (is_list(Concepts) -> Errs1 = Errs0
        ; Errs1 = [error(ir_concepts, list, Concepts)|Errs0]),
        (is_list(Evidence) -> Errors = Errs1
        ; Errors = [error(ir_evidence, list, Evidence)|Errs1])
    ;   Errors = [error(ir_structure, cfg2_ir, IR)]
    ).

%% check_safety(+Input, +Options, -SafetyErrors) is det.
%  Checks for potential safety violations in input data.
check_safety(Terms, _Options, Errors) :-
    (   is_list(Terms)
    ->  maplist(check_term_safety, Terms, ErrorLists),
        flatten(ErrorLists, Errors)
    ;   check_term_safety(Terms, Errors)
    ).

check_term_safety(Term, Errors) :-
    (   contains_unsafe_call(Term)
    ->  Errors = [error(safety, unsafe_call, Term)]
    ;   Errors = []
    ).

contains_unsafe_call(call(_)) :- !.
contains_unsafe_call(assert(_)) :- !.
contains_unsafe_call(asserta(_)) :- !.
contains_unsafe_call(assertz(_)) :- !.
contains_unsafe_call(retract(_)) :- !.
contains_unsafe_call(consult(_)) :- !.
contains_unsafe_call(T) :-
    compound(T),
    T =.. [_|Args],
    member(A, Args),
    contains_unsafe_call(A).

%% validate_options(+Options, -Errors) is det.
validate_options(Options, Errors) :-
    is_list(Options),
    findall(E, check_option(Options, E), Errors).

check_option(Options, error(option, unknown_department, Dept)) :-
    member(department(Dept), Options),
    \+ department_registered(Dept),
    \+ Dept = unknown.

check_option(Options, error(option, invalid_max_rules, N)) :-
    member(max_rules(N), Options),
    \+ (integer(N), N > 0).

%% diagnostic_error(+Context, +Detail, -Error) is det.
diagnostic_error(Context, Detail, error(Context, Detail)).

%% validation_passed(+Errors) is semidet.
validation_passed([]).
