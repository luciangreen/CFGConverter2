%% cfg2_provenance.pl
%% Tracks source-to-output traceability for CFG Converter 2.
%%
%% Every generated item is traceable to its input source, evidence
%% identifiers, transformation stages, and generated artefacts.

:- module(cfg2_provenance,
    [
        provenance_chain/3,
        record_provenance/4,
        provenance_record/4,
        provenance_sources/2,
        provenance_stages/2,
        explain_provenance/2,
        empty_provenance_db/1,
        add_provenance_entry/3
    ]).

:- use_module(library(lists)).

%% Provenance database is a list of provenance_entry/4 terms:
%%   provenance_entry(ItemId, Sources, Stages, Notes).

%% empty_provenance_db(-DB) is det.
empty_provenance_db([]).

%% add_provenance_entry(+DB0, +Entry, -DB1) is det.
add_provenance_entry(DB0, Entry, [Entry|DB0]).

%% record_provenance(+ItemId, +Sources, +Stages, -Entry) is det.
%  Creates a provenance entry term.
record_provenance(ItemId, Sources, Stages, provenance_entry(ItemId, Sources, Stages, [])).

%% provenance_chain(+ItemId, +DB, -Chain) is det.
%  Retrieves the full provenance chain for a generated item.
provenance_chain(ItemId, DB, Chain) :-
    include([provenance_entry(Id,_,_,_)]>>(Id == ItemId), DB, Matches),
    (   Matches = []
    ->  Chain = provenance_chain(ItemId, not_found)
    ;   Matches = [provenance_entry(ItemId, Sources, Stages, Notes)|_],
        Chain = provenance_chain(
            item(ItemId),
            sources(Sources),
            stages(Stages),
            notes(Notes)
        )
    ).

%% provenance_record(+Entry, -Id, -Sources, -Stages) is det.
provenance_record(provenance_entry(Id, Sources, Stages, _), Id, Sources, Stages).

%% provenance_sources(+Entry, -Sources) is det.
provenance_sources(provenance_entry(_, Sources, _, _), Sources).

%% provenance_stages(+Entry, -Stages) is det.
provenance_stages(provenance_entry(_, _, Stages, _), Stages).

%% explain_provenance(+Chain, -Explanation) is det.
%  Converts a provenance chain into a human-readable explanation term.
explain_provenance(provenance_chain(item(Id), sources(Srcs), stages(Stages), _), Explanation) :-
    Explanation = explanation(
        item_id(Id),
        derived_from(Srcs),
        via_stages(Stages)
    ).
explain_provenance(provenance_chain(_, not_found), explanation(not_found)).
