%% test_expressions.pl — Tests for expression DCG and evaluator.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_expression_dcg').
:- use_module('../prolog/ideacfg_evaluator').

:- begin_tests(expression_parsing).

test(parse_number) :-
    parse_expression([42], number(42)).

test(parse_variable) :-
    parse_expression([x], variable(x)).

test(parse_addition) :-
    parse_expression([1, +, 2], add(number(1), number(2))).

test(parse_multiplication) :-
    parse_expression([3, *, 4], mul(number(3), number(4))).

test(parse_nested) :-
    parse_expression([2, *, 3, +, 4],
                     add(mul(number(2), number(3)), number(4))).

test(parse_power) :-
    parse_expression([x, '^', 2], pow(variable(x), number(2))).

test(parse_parenthesised) :-
    parse_expression(['(', 1, +, 2, ')', *, 3],
                     mul(add(number(1), number(2)), number(3))).

:- end_tests(expression_parsing).

:- begin_tests(evaluator).

test(evaluate_number) :-
    evaluate(number(5), [], 5).

test(evaluate_variable) :-
    evaluate(variable(x), [x-3], 3).

test(evaluate_addition) :-
    evaluate(add(number(2), number(3)), [], 5).

test(evaluate_subtraction) :-
    evaluate(sub(number(10), number(4)), [], 6).

test(evaluate_multiplication) :-
    evaluate(mul(number(3), number(4)), [], 12).

test(evaluate_division) :-
    evaluate(div(number(10), number(2)), [], R),
    R =:= 5.

test(evaluate_division_by_zero, [throws(error(division_by_zero, _))]) :-
    evaluate(div(number(1), number(0)), [], _).

test(evaluate_power) :-
    evaluate(pow(number(2), number(10)), [], R),
    R =:= 1024.

test(evaluate_negation) :-
    evaluate(neg(number(5)), [], -5).

test(evaluate_safe) :-
    evaluate_safe(add(number(1), number(2)), [], 3).

test(safe_expression_number) :-
    safe_expression(number(42)).

test(safe_expression_nested) :-
    safe_expression(mul(add(number(1), variable(x)), number(3))).

test(allowed_operator_add) :- allowed_operator(add).
test(allowed_operator_div) :- allowed_operator(div).

test(sqrt_negative, [throws(error(negative_sqrt, _))]) :-
    evaluate(sqrt_op(number(-1)), [], _).

:- end_tests(evaluator).
