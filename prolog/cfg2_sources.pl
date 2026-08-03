%% cfg2_sources.pl
%% Source adapter protocol for CFG Converter 2.
%%
%% source_adapter(+Format, +Source, +Options, -EvidenceRecords).
%%
%% Supported first-release formats:
%%   prolog_terms, csv, tsv, json, json_lines, text,
%%   key_value, observation_table, formula_terms, indicator_records.

:- module(cfg2_sources,
    [
        source_adapter/4,
        registered_format/1,
        load_source/4
    ]).

:- use_module(library(lists)).
:- use_module(library(csv)).
:- use_module(cfg2_evidence).
:- use_module(cfg2_schema).

%% registered_format(+Format) is semidet.
registered_format(prolog_terms).
registered_format(csv).
registered_format(tsv).
registered_format(json).
registered_format(json_lines).
registered_format(text).
registered_format(key_value).
registered_format(observation_table).
registered_format(formula_terms).
registered_format(indicator_records).

%% load_source(+Format, +Source, +Options, -Records) is det.
%  Thin wrapper around source_adapter/4 with error handling.
load_source(Format, Source, Options, Records) :-
    (   registered_format(Format)
    ->  source_adapter(Format, Source, Options, Records)
    ;   throw(error(unsupported_format(Format), load_source/4))
    ).

%% source_adapter(+Format, +Source, +Options, -EvidenceRecords) is det.

%% prolog_terms: Source is a list of evidence/indicator/intuition terms.
source_adapter(prolog_terms, Terms, Options, Evidence) :-
    is_list(Terms),
    maplist(prolog_term_to_evidence(Options), Terms, RawList),
    flatten(RawList, Evidence).
source_adapter(prolog_terms, file(Path), Options, Evidence) :-
    atom(Path),
    read_terms_from_file(Path, Terms),
    source_adapter(prolog_terms, Terms, Options, Evidence).

prolog_term_to_evidence(_Opts, E, [E]) :-
    E = evidence(_,_,_,_,_,_,_,_,_,_,_,_), !.
prolog_term_to_evidence(_Opts, T, []) :-
    \+ T = evidence(_,_,_,_,_,_,_,_,_,_,_,_).

read_terms_from_file(Path, Terms) :-
    setup_call_cleanup(
        open(Path, read, Stream),
        read_terms_from_stream(Stream, Terms),
        close(Stream)
    ).

read_terms_from_stream(Stream, Terms) :-
    read(Stream, T0),
    read_terms_continue(T0, Stream, Terms).

read_terms_continue(end_of_file, _, []) :- !.
read_terms_continue(T, Stream, [T|Rest]) :-
    read(Stream, T1),
    read_terms_continue(T1, Stream, Rest).

%% csv: Source is file(Path) or rows(Rows).  Schema option required.
source_adapter(csv, file(Path), Options, Evidence) :-
    atom(Path),
    (   exists_file(Path)
    ->  csv_read_file(Path, Rows, [functor(row), arity(_)]),
        csv_rows_to_evidence(Rows, Options, Evidence)
    ;   throw(error(file_not_found(Path), source_adapter/4))
    ).
source_adapter(csv, rows(Rows), Options, Evidence) :-
    csv_rows_to_evidence(Rows, Options, Evidence).

csv_rows_to_evidence([], _, []).
csv_rows_to_evidence([HeaderRow|DataRows], Options, Evidence) :-
    HeaderRow =.. [_|Headers],
    maplist(atom, Headers), !,
    maplist(csv_row_to_record(Headers, Options), DataRows, Records),
    maplist(record_to_evidence(Options), Records, Evidences),
    flatten(Evidences, Evidence).
csv_rows_to_evidence(Rows, Options, Evidence) :-
    maplist(record_to_evidence(Options), Rows, Evidences),
    flatten(Evidences, Evidence).

csv_row_to_record(Headers, _Options, Row, Record) :-
    Row =.. [_|Values],
    maplist([H,V,H=V]>>true, Headers, Values, Record).

record_to_evidence(Options, Record, [Evidence]) :-
    (   member(schema(SchemaName), Options),
        schema_registered(SchemaName)
    ->  schema_to_evidence(SchemaName, Record, Options, Evidence)
    ;   generic_record_to_evidence(Record, Evidence)
    ).

generic_record_to_evidence(Record, Evidence) :-
    (   member(id=Id, Record) -> true ; gensym(ev_, Id) ),
    (   member(department=Dept, Record) -> true ; Dept = unknown ),
    (   member(type=Type, Record) -> true ; Type = observation ),
    (   member(subject=Subject, Record) -> true ; Subject = unknown ),
    (   member(value=Value, Record) -> true ; Value = missing ),
    (   member(unit=Unit, Record) -> true ; Unit = dimensionless ),
    (   member(confidence=Conf, Record) -> true ; Conf = unknown ),
    Evidence = evidence(Id, Dept, Type, Subject, Value, Unit,
                        context([]), Conf, provenance(Record),
                        unknown, unknown, []).

%% tsv: same as csv but tab-separated.
source_adapter(tsv, file(Path), Options, Evidence) :-
    atom(Path),
    (   exists_file(Path)
    ->  csv_read_file(Path, Rows, [functor(row), arity(_), separator(0'\t)]),
        csv_rows_to_evidence(Rows, Options, Evidence)
    ;   throw(error(file_not_found(Path), source_adapter/4))
    ).
source_adapter(tsv, rows(Rows), Options, Evidence) :-
    csv_rows_to_evidence(Rows, Options, Evidence).

%% json: Source is file(Path) or dict(Dict).
source_adapter(json, file(Path), Options, Evidence) :-
    atom(Path),
    (   exists_file(Path)
    ->  setup_call_cleanup(
            open(Path, read, Stream),
            (   use_module(library(http/json)),
                json_read(Stream, JSON)
            ),
            close(Stream)
        ),
        json_to_evidence(JSON, Options, Evidence)
    ;   throw(error(file_not_found(Path), source_adapter/4))
    ).
source_adapter(json, list(Items), Options, Evidence) :-
    is_list(Items),
    maplist([Item,Ev]>>(json_object_to_evidence(Item, Options, Ev)), Items, Evidences),
    flatten(Evidences, Evidence).

json_to_evidence(json(Pairs), Options, Evidence) :-
    (   member(records=Items, Pairs), is_list(Items)
    ->  maplist([I,E]>>(json_object_to_evidence(I, Options, E)), Items, Evs),
        flatten(Evs, Evidence)
    ;   json_object_to_evidence(json(Pairs), Options, Ev),
        Evidence = [Ev]
    ).
json_to_evidence(Items, Options, Evidence) :-
    is_list(Items),
    maplist([I,E]>>(json_object_to_evidence(I, Options, E)), Items, Evs),
    flatten(Evs, Evidence).

json_object_to_evidence(json(Pairs), Options, Evidence) :-
    pairs_to_record(Pairs, Record),
    record_to_evidence(Options, Record, [Evidence|_]).
json_object_to_evidence(_, _, evidence(unknown, unknown, unknown_type,
                                        unknown, missing, dimensionless,
                                        context([]), unknown, provenance([]),
                                        unknown, unknown, [])).

pairs_to_record([], []).
pairs_to_record([K=V|Rest], [K=V2|Record]) :-
    (V = @(null) -> V2 = missing ; V2 = V),
    pairs_to_record(Rest, Record).

%% json_lines: one JSON object per line.
source_adapter(json_lines, file(Path), Options, Evidence) :-
    atom(Path),
    (   exists_file(Path)
    ->  setup_call_cleanup(
            open(Path, read, Stream),
            read_json_lines(Stream, Options, Evidence),
            close(Stream)
        )
    ;   throw(error(file_not_found(Path), source_adapter/4))
    ).

read_json_lines(Stream, Options, Evidence) :-
    use_module(library(http/json)),
    read_term(Stream, T, [end_of_file(end_of_file)]),
    (   T = end_of_file
    ->  Evidence = []
    ;   json_object_to_evidence(T, Options, Ev),
        read_json_lines(Stream, Options, Rest),
        Evidence = [Ev|Rest]
    ).

%% text: Source is atom or file(Path).  Extracts concepts as text evidence.
source_adapter(text, TextAtom, Options, Evidence) :-
    atom(TextAtom), !,
    (   member(id=Id, Options) -> true ; gensym(text_, Id) ),
    (   member(department=Dept, Options) -> true ; Dept = general ),
    Evidence = [evidence(Id, Dept, observation, text, TextAtom, text_unit,
                         context([]), unknown, provenance(text_input),
                         unknown, unknown, [])].
source_adapter(text, file(Path), Options, Evidence) :-
    atom(Path),
    (   exists_file(Path)
    ->  read_file_to_atom(Path, Text, []),
        source_adapter(text, Text, Options, Evidence)
    ;   throw(error(file_not_found(Path), source_adapter/4))
    ).

read_file_to_atom(Path, Atom, _Opts) :-
    setup_call_cleanup(
        open(Path, read, Stream),
        (   read_term(Stream, _, []),
            stream_to_atom(Stream, Atom)
        ),
        close(Stream)
    ).

stream_to_atom(Stream, Atom) :-
    read_string(Stream, _, Str),
    atom_string(Atom, Str).

%% key_value: List of Key=Value pairs.
source_adapter(key_value, Pairs, Options, Evidence) :-
    is_list(Pairs),
    record_to_evidence(Options, Pairs, [Evidence|_]).

%% observation_table: List of row/N terms or list-of-list.
source_adapter(observation_table, Table, Options, Evidence) :-
    is_list(Table),
    (   Table = [Headers|DataRows],
        is_list(Headers)
    ->  maplist([Row, Ev]>>(
            maplist([H,V,H=V]>>true, Headers, Row, Record),
            record_to_evidence(Options, Record, [Ev|_])
        ), DataRows, Evidences),
        flatten(Evidences, Evidence)
    ;   csv_rows_to_evidence(Table, Options, Evidence)
    ).

%% formula_terms: List of formula/2 or assumption/2 terms.
source_adapter(formula_terms, Terms, Options, Evidence) :-
    is_list(Terms),
    maplist(formula_term_to_evidence(Options), Terms, Evs),
    flatten(Evs, Evidence).
source_adapter(formula_terms, T, Options, [Ev]) :-
    formula_term_to_evidence(Options, T, Ev).

formula_term_to_evidence(Options, formula(Id, Formula), Evidence) :-
    (   member(department=Dept, Options) -> true ; Dept = mathematics ),
    Evidence = evidence(Id, Dept, formula, formula, Formula, formula_unit,
                        context([]), unknown, provenance(formula_input),
                        unknown, unknown, []).
formula_term_to_evidence(Options, assumption(Id, Expr), Evidence) :-
    (   member(department=Dept, Options) -> true ; Dept = mathematics ),
    Evidence = evidence(Id, Dept, formula, assumption, Expr, formula_unit,
                        context([]), unknown, provenance(assumption_input),
                        unknown, unknown, []).
formula_term_to_evidence(Options, relation(Id, Rel), Evidence) :-
    (   member(department=Dept, Options) -> true ; Dept = mathematics ),
    Evidence = evidence(Id, Dept, observation, relation, Rel, relation_unit,
                        context([]), unknown, provenance(relation_input),
                        unknown, unknown, []).
formula_term_to_evidence(Options, Other, Evidence) :-
    generic_record_to_evidence([formula=Other], Evidence).

%% indicator_records: List of indicator/9 terms.
source_adapter(indicator_records, Terms, _Options, Evidence) :-
    is_list(Terms),
    Evidence = Terms.
source_adapter(indicator_records, T, _Options, [T]) :-
    T = indicator(_,_,_,_,_,_,_,_,_).
