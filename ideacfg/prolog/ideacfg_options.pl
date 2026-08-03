%% ideacfg_options.pl
%% Option handling for IdeaCFG.
:- module(ideacfg_options,
    [
        default_options/1,
        merge_options/3,
        option/3,
        validate_options/1
    ]).

:- use_module(library(lists)).

%% default_options(-Options) is det.
%  Returns the default option list for IdeaCFG.
default_options(
    [
        dialect(general),
        domain(general),
        output(both),
        operation_extraction(iterative),
        maximum_depth(20),
        maximum_generation_length(500),
        maximum_alternatives(100),
        factor_common_prefixes(true),
        factor_common_suffixes(true),
        eliminate_left_recursion(true),
        semantic_validation(true),
        normalise_synonyms(true),
        preserve_source_words(false),
        strict_operations(false),
        allow_approximations(true),
        emit_explanation(true),
        emit_tests(true),
        compact_output(false),
        ambiguity_mode(report),
        maximum_rules(5000),
        maximum_alternatives_per_rule(100),
        maximum_generation_depth(20),
        maximum_generated_tokens(500),
        maximum_operation_dependencies(1000),
        maximum_examples(10000)
    ]
).

%% merge_options(+UserOptions, +Defaults, -Merged) is det.
%  Merges user options with defaults, user options taking precedence.
merge_options([], Defaults, Defaults).
merge_options([Opt|Rest], Defaults, Merged) :-
    functor(Opt, Key, Arity),
    functor(Pattern, Key, Arity),
    (   select(Pattern, Defaults, Remaining)
    ->  merge_options(Rest, [Opt|Remaining], Merged)
    ;   merge_options(Rest, [Opt|Defaults], Merged)
    ).

%% option(+Key, +Options, -Value) is semidet.
%  Retrieves an option value from an option list.
option(Key, Options, Value) :-
    must_be(atom, Key),
    must_be(list, Options),
    Goal =.. [Key, Value],
    memberchk(Goal, Options).

%% validate_options(+Options) is det.
%  Validates that all options have acceptable types.
validate_options(Options) :-
    must_be(list, Options),
    maplist(validate_single_option, Options).

validate_single_option(Opt) :-
    (   valid_option(Opt)
    ->  true
    ;   type_error(valid_option, Opt)
    ).

valid_option(dialect(_)).
valid_option(domain(_)).
valid_option(output(X)) :- memberchk(X, [cfg, dcg, both]).
valid_option(operation_extraction(X)) :- memberchk(X, [prior, secondary, iterative]).
valid_option(maximum_depth(X)) :- integer(X), X > 0.
valid_option(maximum_generation_length(X)) :- integer(X), X > 0.
valid_option(maximum_alternatives(X)) :- integer(X), X > 0.
valid_option(factor_common_prefixes(X)) :- boolean(X).
valid_option(factor_common_suffixes(X)) :- boolean(X).
valid_option(eliminate_left_recursion(X)) :- boolean(X).
valid_option(semantic_validation(X)) :- boolean(X).
valid_option(normalise_synonyms(X)) :- boolean(X).
valid_option(preserve_source_words(X)) :- boolean(X).
valid_option(strict_operations(X)) :- boolean(X).
valid_option(allow_approximations(X)) :- boolean(X).
valid_option(emit_explanation(X)) :- boolean(X).
valid_option(emit_tests(X)) :- boolean(X).
valid_option(compact_output(X)) :- boolean(X).
valid_option(ambiguity_mode(X)) :- memberchk(X, [report, generate_all, prefer_simple, require_resolution]).
valid_option(maximum_rules(X)) :- integer(X), X > 0.
valid_option(maximum_alternatives_per_rule(X)) :- integer(X), X > 0.
valid_option(maximum_generation_depth(X)) :- integer(X), X > 0.
valid_option(maximum_generated_tokens(X)) :- integer(X), X > 0.
valid_option(maximum_operation_dependencies(X)) :- integer(X), X > 0.
valid_option(maximum_examples(X)) :- integer(X), X > 0.

boolean(true).
boolean(false).
