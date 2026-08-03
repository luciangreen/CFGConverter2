%% economics/investment.pl — Compound interest example.
:- use_module('../../prolog/ideacfg_api').

%% Idea: Investment scenario with compound interest.
%
% An investment scenario contains principal, interest rate and periods.
% Compound value is principal multiplied by one plus the rate raised to the number of periods.

%% compound_value(+Principal, +Rate, +Periods, -Value) is det.
%  Computes compound interest: FV = P * (1 + r)^n
compound_value(Principal, Rate, Periods, Value) :-
    must_be(number, Principal),
    must_be(number, Rate),
    must_be(integer, Periods),
    (   Principal < 0
    ->  throw(error(negative_principal(Principal), compound_value/4))
    ;   Rate < 0
    ->  throw(error(negative_rate(Rate), compound_value/4))
    ;   Periods < 0
    ->  throw(error(negative_periods(Periods), compound_value/4))
    ;   Value is Principal * ((1 + Rate) ** Periods)
    ).

economics_example :-
    idea_to_cfg(investment,
        'An investment scenario contains principal interest rate and periods. Compound value is principal multiplied by one plus the rate raised to the number of periods.',
        _Result),
    compound_value(1000, 0.05, 10, FV),
    format('Future value: ~2f~n', [FV]).
