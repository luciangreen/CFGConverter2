%% tests/test_cfg.pl
%% CFG generation and grammar tests for CFG Converter 2.

:- use_module(library(plunit)).
:- use_module('../prolog/cfg2_cfg').
:- use_module('../prolog/cfg2_evidence').

:- begin_tests(cfg_generation).

test(cfg_rule_accessors, [true]) :-
    R = cfg_rule(r1, my_symbol, [part_a, part_b], [department(test)]),
    cfg_rule_id(R, r1),
    cfg_rule_lhs(R, my_symbol),
    cfg_rule_rhs(R, [part_a, part_b]),
    cfg_rule_annotations(R, [department(test)]).

test(cfg_compat, [true(Plain = cfg_rule(my_symbol, [a, b]))]) :-
    R = cfg_rule(r1, my_symbol, [a, b], []),
    cfg_rule_compat(R, Plain).

test(annotated_to_plain, [true(N =:= 2)]) :-
    Rules = [cfg_rule(r1, a, [b], [dep(x)]),
             cfg_rule(r2, b, [c], [dep(y)])],
    annotated_cfg_to_plain(Rules, Plain),
    length(Plain, N).

test(cfg_to_text_nonempty, [true(Text \= '')]) :-
    Rules = [cfg_rule(r1, start, [a, b], [])],
    cfg_to_text(Rules, Text).

test(merge_cfg_rules, [true(Merged \= [])]) :-
    R1 = [cfg_rule(r1, a, [b], [])],
    R2 = [cfg_rule(r2, c, [d], [])],
    merge_cfg_rules(R1, R2, Merged).

test(generate_cfg2_from_evidence, [true(CFGRules \= [])]) :-
    E = evidence(e1, neuroolfaction, qualitative_measurement, subject,
                 strong, neuroolfactory_unit, context([]), 0.8,
                 provenance([]), unknown, unknown, []),
    IR = cfg2_ir(test_gen, metadata([]), [concept(e1, subject, [strong], dept(neuroolfaction), [])],
                 [], [], [E], [], [], [], []),
    generate_cfg2(test_gen, IR, [E], CFGRules).

:- end_tests(cfg_generation).
