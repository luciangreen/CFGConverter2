%% tests/test_provenance.pl
%% Provenance tracking tests for CFG Converter 2.

:- use_module(library(plunit)).
:- use_module('../prolog/cfg2_provenance').

:- begin_tests(provenance).

test(empty_db, [true(DB = [])]) :-
    empty_provenance_db(DB).

test(add_entry, [true(DB \= [])]) :-
    empty_provenance_db(DB0),
    record_provenance(item1, [source(s1)], [stage1, stage2], Entry),
    add_provenance_entry(DB0, Entry, DB).

test(provenance_chain_found, [true(nonvar(Chain))]) :-
    record_provenance(item1, [source(s1)], [stage1], Entry),
    provenance_chain(item1, [Entry], Chain).

test(provenance_chain_not_found, [true(Chain = provenance_chain(missing, not_found))]) :-
    provenance_chain(missing, [], Chain).

test(explain_provenance, [true(nonvar(Expl))]) :-
    Chain = provenance_chain(item(r14), sources([e17,e18]),
                             stages([evidence_extraction, cfg_generation]),
                             notes([])),
    explain_provenance(Chain, Expl).

test(provenance_accessors, [true]) :-
    record_provenance(test_id, [s1, s2], [st1], Entry),
    provenance_sources(Entry, [s1, s2]),
    provenance_stages(Entry, [st1]).

:- end_tests(provenance).
