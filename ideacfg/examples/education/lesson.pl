%% education/lesson.pl — Lesson plan example with score calculation.
:- use_module('../../prolog/ideacfg_api').

%% Idea: Lesson structure.
%
% A lesson contains objectives, explanation, examples, practice and assessment.
% A score is the number correct divided by the number attempted.

education_example(Result) :-
    idea_to_cfg(lesson,
        [sequence(lesson, [objectives, explanation, examples, practice, assessment], [], src),
         operation(score, arithmetic, [correct, attempted], score_value, direct, [], src)],
        Result).

%% lesson_score(+Correct, +Attempted, -Score) is det.
%  Computes normalised score; handles division by zero.
lesson_score(_Correct, 0, _Score) :-
    throw(error(no_questions_attempted, lesson_score/3)).
lesson_score(Correct, Attempted, Score) :-
    must_be(integer, Correct),
    must_be(integer, Attempted),
    Attempted > 0,
    Score is Correct / Attempted.
