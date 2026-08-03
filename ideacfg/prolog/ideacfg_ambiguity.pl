%% ideacfg_ambiguity.pl
%% Ambiguity detection and reporting for IdeaCFG.
:- module(ideacfg_ambiguity,
    [
        detect_ambiguities/3,
        ambiguity_mode/1,
        default_ambiguity_mode/1,
        report_ambiguity/1
    ]).

:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% ambiguity_mode(?Mode) is nondet.
%  Valid ambiguity handling modes.
ambiguity_mode(report).
ambiguity_mode(generate_all).
ambiguity_mode(prefer_simple).
ambiguity_mode(require_resolution).

%% default_ambiguity_mode(-Mode) is det.
default_ambiguity_mode(report).

%% detect_ambiguities(+IdeaName, +Tokens, -Ambiguities) is det.
%  Detects structural ambiguities in a token sequence.
detect_ambiguities(_IdeaName, Tokens, Ambiguities) :-
    must_be(list, Tokens),
    findall(ambiguity(Id, Interpretations, source_tokens),
            (   ambiguous_pattern(Tokens, Id, Interpretations)
            ),
            Ambiguities).

%% ambiguous_pattern(+Tokens, -Id, -Interpretations) is nondet.
%  Known ambiguous patterns.
ambiguous_pattern(Tokens, attachment_ambiguity, [high_attachment, low_attachment]) :-
    append(_, [observes|Rest], Tokens),
    append(_, [with|_], Rest).

ambiguous_pattern(Tokens, conjunction_ambiguity, [narrow_scope, wide_scope]) :-
    append(Before, [and|After], Tokens),
    Before \= [],
    After \= [],
    append(_, [or|_], Before).

%% report_ambiguity(+Ambiguity) is det.
%  Reports an ambiguity as a diagnostic.
report_ambiguity(ambiguity(Id, Alternatives, Src)) :-
    length(Alternatives, N),
    format(atom(Msg), 'Ambiguity ~w: ~w alternative interpretations found', [Id, N]),
    emit_diagnostic(warning, ambiguity, Msg, Src, Alternatives,
                    'Resolve ambiguity or use ambiguity_mode(generate_all)').
