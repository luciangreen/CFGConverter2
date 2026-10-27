%% tests/test_sources.pl
%% Source adapter tests for CFG Converter 2.

:- use_module(library(plunit)).
:- use_module('../prolog/cfg2_sources').
:- use_module('../prolog/cfg2_evidence').

:- begin_tests(source_adapters).

test(prolog_terms_evidence, [true(Evids = [e1])]) :-
    E = evidence(e1, neuroolfaction, qualitative_measurement, subject, val,
                 unit, context([]), 0.8, provenance([]), unknown, unknown, []),
    source_adapter(prolog_terms, [E], [], Evidence),
    maplist(evidence_id, Evidence, Evids).

test(prolog_terms_non_evidence_filtered, [true(Evidence = [])]) :-
    source_adapter(prolog_terms, [not_evidence(x)], [], Evidence).

test(csv_rows_basic, [true(Evidence \= [])]) :-
    Rows = [row(id, subject, value),
            row(e1, response, strong)],
    source_adapter(csv, rows(Rows), [], Evidence).

test(formula_terms_basic, [true(Evidence \= [])]) :-
    source_adapter(formula_terms,
                   [formula(f1, plus(2,3,5)), assumption(a1, integer(x))],
                   [department(mathematics)], Evidence).

test(formula_single_term, [true(Evidence \= [])]) :-
    source_adapter(formula_terms, formula(f1, plus(2,3,5)),
                   [department(mathematics)], Evidence).

test(indicator_records, [true(Inds = [I])]) :-
    I = indicator(i1, literary_analysis, narrator, evasion,
                  supports(unreliable_narrator), moderate, 0.7,
                  chapter(3), provenance(reader(r1))),
    source_adapter(indicator_records, [I], [], Inds).

test(text_atom, [true(Evidence \= [])]) :-
    source_adapter(text, 'A simple text observation.', [id(t1)], Evidence).

test(text_file_preserves_initial_text, [true(Value = 'A plain text file.')]) :-
    with_temp_file("A plain text file.", Path,
                   source_adapter(text, file(Path), [id(t2)], [Evidence])),
    evidence_value(Evidence, Value).

test(json_lines_file_reads_json_objects, [true(Ids = [e1, e2])]) :-
    Text = "{\"id\":\"e1\",\"department\":\"physics\",\"subject\":\"temperature\",\"value\":273.15}\n{\"id\":\"e2\",\"department\":\"physics\",\"subject\":\"pressure\",\"value\":101}\n",
    with_temp_file(Text, Path,
                   source_adapter(json_lines, file(Path), [], Evidence)),
    maplist(evidence_id, Evidence, Ids).

test(key_value, [true(Evidence \= [])]) :-
    source_adapter(key_value,
                   [id=kv1, department=physics, type=observation,
                    subject=temperature, value=300, unit=kelvin,
                    confidence=0.9],
                   [], Evidence).

test(unsupported_format, [throws(error(unsupported_format(_), _))]) :-
    load_source(xml_unsupported, file('test.xml'), [], _).

test(missing_file, [throws(error(file_not_found(_), _))]) :-
    source_adapter(csv, file('/nonexistent/path/data.csv'), [], _).

with_temp_file(Text, Path, Goal) :-
    setup_call_cleanup(
        tmp_file_stream(text, Path, Stream),
        write(Stream, Text),
        close(Stream)
    ),
    setup_call_cleanup(true, call(Goal), delete_file(Path)).

:- end_tests(source_adapters).
