%% ideacfg_export.pl
%% Export facilities for IdeaCFG.
:- module(ideacfg_export,
    [
        idea_export/2,
        idea_export/3,
        export_format/1,
        write_to_file/2,
        validate_path/1
    ]).

:- use_module(ideacfg_ir).
:- use_module(ideacfg_codegen).
:- use_module(ideacfg_explain).
:- use_module(ideacfg_diagnostics).

%% export_format(?Format) is nondet.
export_format(prolog).
export_format(cfg).
export_format(dcg).
export_format(markdown).
export_format(json).

%% idea_export(+IdeaName, +Path) is det.
%  Exports an idea's generated Prolog to a file.
idea_export(IdeaName, Path) :-
    idea_export(IdeaName, prolog, Path).

%% idea_export(+IdeaName, +Format, +Path) is det.
idea_export(IdeaName, Format, Path) :-
    must_be(atom, IdeaName),
    must_be(atom, Format),
    must_be(atom, Path),
    (   export_format(Format)
    ->  true
    ;   type_error(export_format, Format)
    ),
    validate_path(Path),
    emit_diagnostic(info, export_started, 'Export started', unknown, [IdeaName, Format, Path],
                    'Review exported file').

%% write_to_file(+Path, +Content) is det.
%  Writes content atom to a file safely.
write_to_file(Path, Content) :-
    must_be(atom, Path),
    must_be(atom, Content),
    validate_path(Path),
    setup_call_cleanup(
        open(Path, write, Stream, [encoding(utf8)]),
        write_term(Stream, Content, [quoted(false)]),
        close(Stream)
    ).

%% validate_path(+Path) is det.
%  Validates a file path for safety (no path traversal).
validate_path(Path) :-
    atom_string(Path, PathStr),
    (   sub_string(PathStr, _, _, _, "..")
    ->  throw(error(permission_error(write, path, Path), validate_path/1))
    ;   true
    ).
