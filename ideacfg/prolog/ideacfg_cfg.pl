%% ideacfg_cfg.pl
%% CFG generator: converts IR into plain CFG productions.
:- module(ideacfg_cfg,
    [
        generate_cfg/3,
        cfg_to_text/2,
        cfg_rule/2,
        validate_cfg/2
    ]).

:- use_module(ideacfg_ir).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% generate_cfg(+IdeaName, +IR, -CFG) is det.
%  Generates a list of cfg_rule(Lhs, Rhs) from the IR.
generate_cfg(IdeaName, IR, CFG) :-
    must_be(atom, IdeaName),
    ir_elements(IR, Elems),
    foldl([Elem, Acc0, Acc1]>>(
              elem_to_cfg_rules(IdeaName, Elem, Rules),
              append(Acc0, Rules, Acc1)
          ), Elems, [], CFGRaw),
    sort(CFGRaw, CFG).

%% elem_to_cfg_rules(+IdeaName, +Element, -Rules) is det.
elem_to_cfg_rules(_Name, sequence(Id, Members, _Props, _Src),
                  [cfg_rule(Id, Members)]) :-
    atom(Id), is_list(Members), !.
elem_to_cfg_rules(_Name, alternative(Id, Members, _Props, _Src), Rules) :-
    atom(Id), is_list(Members), !,
    maplist([M, cfg_rule(Id, [M])]>>true, Members, Rules).
elem_to_cfg_rules(_Name, optional(Id, Member, _Props, _Src),
                  [cfg_rule(Id, [Member]), cfg_rule(Id, [])]) :-
    atom(Id), atom(Member), !.
elem_to_cfg_rules(_Name, repetition(Id, Member, _Min, Max, _Props, _Src), Rules) :-
    atom(Id), atom(Member), !,
    MoreId = Id,
    (   Max = unbounded
    ->  Rules = [cfg_rule(Id, [Member, MoreId]), cfg_rule(Id, [])]
    ;   number(Max)
    ->  numlist(0, Max, Counts),
        maplist([N, cfg_rule(Id, Body)]>>(
                    length(Body, N),
                    maplist(=(Member), Body)
                ), Counts, Rules)
    ;   Rules = [cfg_rule(Id, [Member, Id]), cfg_rule(Id, [])]
    ).
elem_to_cfg_rules(_Name, concept(Id, _Label, _Type, _Props, _Src),
                  [cfg_rule(Id, [terminal(Id)])]) :- atom(Id), !.
elem_to_cfg_rules(_Name, assumption(_Id, _Text, _, _Src), []) :- !.
elem_to_cfg_rules(_, _, []).

%% cfg_to_text(+CFG, -Text) is det.
%  Converts a CFG list to human-readable text.
cfg_to_text(CFG, Text) :-
    maplist(cfg_rule_to_text, CFG, Lines),
    atomic_list_concat(Lines, '\n', Text).

cfg_rule_to_text(cfg_rule(Lhs, []), Text) :-
    format(atom(Text), '~w → ε', [Lhs]).
cfg_rule_to_text(cfg_rule(Lhs, [terminal(T)]), Text) :-
    upcase_atom(Lhs, LhsU),
    upcase_atom(T, TU),
    format(atom(Text), '~w → "~w"', [LhsU, TU]).
cfg_rule_to_text(cfg_rule(Lhs, Rhs), Text) :-
    upcase_atom(Lhs, LhsU),
    maplist([R, RU]>>(upcase_atom(R, RU)), Rhs, RhsUpper),
    atomic_list_concat(RhsUpper, ' ', RhsText),
    format(atom(Text), '~w → ~w', [LhsU, RhsText]).

%% validate_cfg(+CFG, -Diagnostics) is det.
%  Validates a CFG and returns diagnostic messages.
validate_cfg(CFG, Diagnostics) :-
    must_be(list, CFG),
    findall(D,
            (   member(cfg_rule(Lhs, Rhs), CFG),
                check_rule(cfg_rule(Lhs, Rhs), CFG, D)
            ),
            Diagnostics).

check_rule(cfg_rule(Lhs, Rhs), CFG, D) :-
    member(Sym, Rhs),
    atom(Sym),
    \+ Sym = terminal(_),
    \+ member(cfg_rule(Sym, _), CFG),
    format(atom(Msg), 'Undefined nonterminal: ~w in rule ~w', [Sym, Lhs]),
    D = diagnostic(warning, undefined_nonterminal, Msg, rule(Lhs), [Sym],
                   'Add a production for this nonterminal').

%% cfg_rule(?Lhs, ?Rhs) is nondet.
%  Type constructor for cfg_rule.
cfg_rule(Lhs, Rhs) :-
    atom(Lhs), is_list(Rhs).
