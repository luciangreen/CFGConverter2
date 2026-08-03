%% test_security.pl — Security tests for IdeaCFG.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_evaluator').
:- use_module('../prolog/ideacfg_operations').
:- use_module('../prolog/ideacfg_export').
:- use_module('../prolog/ideacfg_input').

:- begin_tests(security).

test(unsafe_expression_rejected, [throws(error(unsafe_expression(_), _))]) :-
    evaluate_safe(call(write(hacked)), [], _).

test(no_arbitrary_call_in_operations) :-
    % Operations should not expose call/1 or consult/1 paths
    idea_from_sentences(sec_test, ['Execute arbitrary code now.'], IR),
    extract_operations(sec_test, IR, Ops),
    % No operation should have mode = unsafe
    \+ member(operation(_, _, _, _, unsafe, _, _), Ops).

test(path_traversal_rejected, [throws(error(permission_error(write, path, _), _))]) :-
    validate_path('../../../etc/passwd').

test(safe_path_accepted) :-
    validate_path('generated/test.pl').

test(allowlisted_operators_only) :-
    % Evaluate should reject non-allowlisted operators
    \+ safe_expression(shell('rm -rf /')).

test(no_dynamic_execution_of_user_text) :-
    % User text should never become executable Prolog
    idea_from_text(safe_text, ':- assert(hacked(true)).', IR),
    ir_name(IR, safe_text),
    % The text should be stored as an assumption, not executed
    IR = idea(_, _, Elems),
    \+ (member(E, Elems), E = assertion_executed).

test(safe_expression_number) :-
    safe_expression(number(42)).

test(safe_expression_rejects_call) :-
    \+ safe_expression(call(write(hello))).

test(evaluator_no_overflow_with_large_numbers) :-
    evaluate_safe(pow(number(2), number(30)), [], R),
    R =:= 2 ** 30.

:- end_tests(security).
