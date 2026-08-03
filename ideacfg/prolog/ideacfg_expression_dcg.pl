%% ideacfg_expression_dcg.pl
%% Reusable mathematical expression DCG and AST builder.
:- module(ideacfg_expression_dcg,
    [
        expression//1,
        term//1,
        factor//1,
        expression_tail//2,
        term_tail//2,
        number_token//1,
        variable_token//1,
        parse_expression/2
    ]).

:- use_module(library(dcg/basics)).

%% expression(-AST)// is det.
%  Parses an arithmetic expression into an AST.
expression(AST) -->
    term(Term),
    expression_tail(Term, AST).

expression_tail(Left, AST) -->
    [+], term(Right),
    { Node = add(Left, Right) },
    expression_tail(Node, AST).
expression_tail(Left, AST) -->
    [-], term(Right),
    { Node = sub(Left, Right) },
    expression_tail(Node, AST).
expression_tail(AST, AST) --> [].

%% term(-AST)// is det.
term(AST) -->
    factor(Factor),
    term_tail(Factor, AST).

term_tail(Left, AST) -->
    [*], factor(Right),
    { Node = mul(Left, Right) },
    term_tail(Node, AST).
term_tail(Left, AST) -->
    [/], factor(Right),
    { Node = div(Left, Right) },
    term_tail(Node, AST).
term_tail(Left, AST) -->
    ['^'], factor(Right),
    { Node = pow(Left, Right) },
    term_tail(Node, AST).
term_tail(AST, AST) --> [].

%% factor(-AST)// is det.
factor(number(N)) -->
    number_token(N).
factor(variable(V)) -->
    variable_token(V).
factor(AST) -->
    ['('], expression(AST), [')'].
factor(neg(AST)) -->
    [-], factor(AST).

%% number_token(-Number)// is det.
number_token(N) --> [N], { number(N) }.

%% variable_token(-Name)// is det.
variable_token(V) --> [V], { atom(V), \+ reserved(V) }.

reserved(+). reserved(-). reserved(*). reserved(/).
reserved('('). reserved(')'). reserved('^').

%% parse_expression(+Tokens, -AST) is semidet.
%  Parses a token list as an expression.
parse_expression(Tokens, AST) :-
    must_be(list, Tokens),
    phrase(expression(AST), Tokens).
