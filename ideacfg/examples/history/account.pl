%% history/account.pl — Historical account example.
:- use_module('../../prolog/ideacfg_api').

%% Idea: Historical account structure.
%
% A historical account contains context, actors, events, causes, consequences and interpretations.

history_example(Result) :-
    idea_to_cfg(historical_account,
        [sequence(historical_account, [context, actors, events, causes, consequences, interpretations], [], src)],
        Result).

%% date_difference(+Date1, +Date2, -DiffYears) is det.
%  Computes difference in years between two dates (year integers).
date_difference(Year1, Year2, Diff) :-
    must_be(integer, Year1),
    must_be(integer, Year2),
    Diff is abs(Year2 - Year1).

%% precedes_date(+Year1, +Year2) is semidet.
%  True when Year1 comes before Year2.
precedes_date(Year1, Year2) :-
    must_be(integer, Year1),
    must_be(integer, Year2),
    Year1 < Year2.
