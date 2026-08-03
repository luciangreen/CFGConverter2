%% tests/test_schema.pl
%% Schema validation tests for CFG Converter 2.

:- use_module(library(plunit)).
:- use_module('../prolog/cfg2_schema').
:- use_module('../prolog/cfg2_evidence').

:- begin_tests(schema).

test(olfactory_schema_registered, [true]) :-
    schema_registered(olfactory_schema).

test(formula_schema_registered, [true]) :-
    schema_registered(formula_schema).

test(indicator_schema_registered, [true]) :-
    schema_registered(indicator_schema).

test(required_fields_fail, [true(Errors \= [])]) :-
    validate_schema(olfactory_schema, [department=neuroolfaction], Errors).

test(required_fields_pass, [true(Errors = [])]) :-
    validate_schema(olfactory_schema,
                    [id=e1, subject=response_intensity, value=strong],
                    Errors).

test(wrong_type_confidence, [true(Errors \= [])]) :-
    validate_schema(olfactory_schema,
                    [id=e1, subject=s1, value=strong, confidence=not_a_confidence],
                    Errors).

test(schema_to_evidence_basic, [true(nonvar(Ev))]) :-
    schema_to_evidence(olfactory_schema,
                       [id=e1, subject=response_intensity, value=strong],
                       [], Ev).

test(unknown_schema, [true(Errors = [error(schema, not_registered, bogus_schema)])]) :-
    validate_schema(bogus_schema, [], Errors).

test(list_schemas_includes_olfactory, [true]) :-
    list_schemas(Schemas),
    member(olfactory_schema, Schemas).

:- end_tests(schema).
