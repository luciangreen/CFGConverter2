%% ideacfg_evaluator.pl
%% Safe arithmetic evaluator with allowlisted operators.
:- module(ideacfg_evaluator,
    [
        evaluate/3,
        evaluate_safe/3,
        allowed_operator/1,
        safe_expression/1
    ]).

:- use_module(library(lists)).

%% allowed_operator(?Op) is nondet.
%  Operators permitted in safe evaluation.
allowed_operator(add).
allowed_operator(sub).
allowed_operator(mul).
allowed_operator(div).
allowed_operator(pow).
allowed_operator(neg).
allowed_operator(abs_val).
allowed_operator(sqrt_op).
allowed_operator(log_op).
allowed_operator(mod_op).

%% safe_expression(+AST) is semidet.
%  True when the AST uses only allowlisted operators.
safe_expression(number(_)) :- !.
safe_expression(variable(_)) :- !.
safe_expression(AST) :-
    compound(AST),
    AST =.. [Op | Args],
    allowed_operator(Op),
    maplist(safe_expression, Args).

%% evaluate(+AST, +Env, -Value) is semidet.
%  Evaluates an AST with the given environment (list of Name-Value pairs).
evaluate(number(N), _Env, N) :- !.
evaluate(variable(Name), Env, Value) :-
    memberchk(Name-Value, Env), !.
evaluate(add(A, B), Env, R) :-
    evaluate(A, Env, AV), evaluate(B, Env, BV), R is AV + BV.
evaluate(sub(A, B), Env, R) :-
    evaluate(A, Env, AV), evaluate(B, Env, BV), R is AV - BV.
evaluate(mul(A, B), Env, R) :-
    evaluate(A, Env, AV), evaluate(B, Env, BV), R is AV * BV.
evaluate(div(A, B), Env, R) :-
    evaluate(A, Env, AV), evaluate(B, Env, BV),
    (   BV =:= 0
    ->  throw(error(division_by_zero, evaluate/3))
    ;   R is AV / float(BV)
    ).
evaluate(pow(A, B), Env, R) :-
    evaluate(A, Env, AV), evaluate(B, Env, BV), R is AV ** BV.
evaluate(neg(A), Env, R) :-
    evaluate(A, Env, AV), R is -AV.
evaluate(abs_val(A), Env, R) :-
    evaluate(A, Env, AV), R is abs(AV).
evaluate(sqrt_op(A), Env, R) :-
    evaluate(A, Env, AV),
    (   AV < 0
    ->  throw(error(negative_sqrt, evaluate/3))
    ;   R is sqrt(AV)
    ).
evaluate(log_op(A), Env, R) :-
    evaluate(A, Env, AV),
    (   AV =< 0
    ->  throw(error(non_positive_log, evaluate/3))
    ;   R is log(AV)
    ).
evaluate(mod_op(A, B), Env, R) :-
    evaluate(A, Env, AV), evaluate(B, Env, BV),
    (   BV =:= 0
    ->  throw(error(division_by_zero, evaluate/3))
    ;   R is AV mod BV
    ).

%% evaluate_safe(+AST, +Env, -Result) is semidet.
%  Like evaluate/3 but first checks for safety.
evaluate_safe(AST, Env, Result) :-
    (   safe_expression(AST)
    ->  evaluate(AST, Env, Result)
    ;   throw(error(unsafe_expression(AST), evaluate_safe/3))
    ).
