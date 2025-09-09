"Project Template Organizer" for Emacs is a set of functions that allows for the
organization of project templates. Starting a new project does not need to start
at zero, but from a template that provides some initial content, so that the wheel
does not have to be re-invented more often than necessary.

How does it work?

- In `pto/templates-directory` each subdirectory is considered a project template.
- Projects can be "installed" to any directory, but will default to `pto/default-repo`.
- Projects may contain placeholders in arbitrary files. These will be replaced by user
  defined strings, according to the content of `pto/project-parameters`.
