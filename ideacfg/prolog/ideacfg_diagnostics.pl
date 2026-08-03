%% ideacfg_diagnostics.pl
%% Diagnostic and error-reporting module for IdeaCFG.
:- module(ideacfg_diagnostics,
    [
        emit_diagnostic/1,
        emit_diagnostic/6,
        diagnostic_severity/1,
        clear_diagnostics/0,
        get_diagnostics/1,
        format_diagnostic/2
    ]).

:- use_module(library(lists)).

:- dynamic stored_diagnostic/1.

%% emit_diagnostic(+Diagnostic) is det.
%  Records a diagnostic term.
emit_diagnostic(D) :-
    must_be(compound, D),
    assertz(stored_diagnostic(D)).

%% emit_diagnostic(+Severity, +Code, +Message, +Loc, +Related, +Action) is det.
%  Constructs and records a diagnostic.
emit_diagnostic(Severity, Code, Message, Loc, Related, Action) :-
    must_be(atom, Severity),
    must_be(atom, Code),
    must_be(atom, Message),
    D = diagnostic(Severity, Code, Message, Loc, Related, Action),
    assertz(stored_diagnostic(D)).

%% diagnostic_severity(?Severity) is nondet.
%  Enumerates valid severity levels.
diagnostic_severity(info).
diagnostic_severity(warning).
diagnostic_severity(error).
diagnostic_severity(fatal).

%% clear_diagnostics is det.
%  Removes all stored diagnostics.
clear_diagnostics :-
    retractall(stored_diagnostic(_)).

%% get_diagnostics(-Diagnostics) is det.
%  Retrieves all stored diagnostics.
get_diagnostics(Diagnostics) :-
    findall(D, stored_diagnostic(D), Diagnostics).

%% format_diagnostic(+Diagnostic, -Text) is det.
%  Formats a diagnostic as human-readable text.
format_diagnostic(
    diagnostic(Severity, Code, Message, Loc, _Related, Action),
    Text
) :-
    format(atom(Text),
        '[~w] ~w at ~w: ~w. Suggestion: ~w',
        [Severity, Code, Loc, Message, Action]).
format_diagnostic(Other, Text) :-
    format(atom(Text), '~w', [Other]).
