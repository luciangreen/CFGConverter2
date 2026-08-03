%% test_cfg.pl — Tests for CFG generation.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_cfg').
:- use_module('../prolog/ideacfg_ir').
:- use_module('../prolog/ideacfg_input').

:- begin_tests(cfg_generation).

test(sequence_produces_rule) :-
    idea_from_terms(cfg_seq, [sequence(essay, [introduction, body, conclusion], [], src)], IR),
    generate_cfg(cfg_seq, IR, CFG),
    member(cfg_rule(essay, [introduction, body, conclusion]), CFG).

test(alternative_produces_rules) :-
    idea_from_terms(cfg_alt, [alternative(proof_method, [induction, contradiction, construction], [], src)], IR),
    generate_cfg(cfg_alt, IR, CFG),
    member(cfg_rule(proof_method, [induction]), CFG),
    member(cfg_rule(proof_method, [contradiction]), CFG),
    member(cfg_rule(proof_method, [construction]), CFG).

test(optional_produces_epsilon) :-
    idea_from_terms(cfg_opt, [optional(opt_appendix, appendix, [], src)], IR),
    generate_cfg(cfg_opt, IR, CFG),
    member(cfg_rule(opt_appendix, [appendix]), CFG),
    member(cfg_rule(opt_appendix, []), CFG).

test(repetition_produces_recursive_rule) :-
    idea_from_terms(cfg_rep, [repetition(sentences, sentence, 1, unbounded, [], src)], IR),
    generate_cfg(cfg_rep, IR, CFG),
    member(cfg_rule(sentences, [sentence, sentences]), CFG).

test(cfg_to_text_sequence) :-
    cfg_to_text([cfg_rule(essay, [introduction, body, conclusion])], Text),
    sub_atom(Text, _, _, _, 'ESSAY').

test(cfg_to_text_epsilon) :-
    cfg_to_text([cfg_rule(optional_x, [])], Text),
    sub_atom(Text, _, _, _, ε).

test(validate_cfg_undefined_nonterminal) :-
    validate_cfg([cfg_rule(essay, [introduction, undefined_nt])], Diags),
    member(diagnostic(warning, undefined_nonterminal, _, _, _, _), Diags).

test(validate_cfg_no_warnings_for_valid) :-
    validate_cfg([cfg_rule(essay, [introduction, body]),
                  cfg_rule(introduction, [terminal(intro_text)]),
                  cfg_rule(body, [terminal(body_text)])], Diags),
    \+ member(diagnostic(error, _, _, _, _, _), Diags).

:- end_tests(cfg_generation).
