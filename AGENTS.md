# AGENTS

## Project overview

Lato is ecosystem of Rails engines for building admin panels with authentication, user management, Bootstrap UI, reusable components, operations, settings, storage, spaces, and CMS features.

`lato` is base Rails engine. Other Lato gems extend it with specific modules.

## Gem purpose

`lato` provides core admin panel infrastructure:

- Authentication and account management.
- Optional verification and authentication methods.
- Bootstrap layout, navbar, sidebar, and overridable partials.
- UI components for forms, index tables, actions, and data rendering.
- Operations system for visual background job execution.
- Shared models such as users, sessions, invitations, and operations.

## Documentation

- Complete generated documentation: `docs/SKILL.md`.
- Generated plain documentation: `docs/documentation.txt`.
- Documentation generator: `bin/generate_docs.rb`.
- Public behavior changes must update source documentation views and generated docs.
- Extension gems must keep `test/dummy/app/views/application/documentation.html.erb` updated with user-facing documentation for installation and usage.

## Local setup

- Ruby via `rbenv`.
- Install gems: `bundle`.
- Migrate dummy DB: `rails db:migrate`.
- Seed dummy DB: `rails db:seed`.
- Start dev stack: `foreman start -f Procfile.dev`.

## Main commands

- Run tests: `bin/rails test`.
- Generate docs: `ruby bin/generate_docs.rb`.
- Publish gem: `ruby ./bin/publish.rb`.

## Agent notes

- Keep Ruby strings double quoted.
- Do not add implementation details to user documentation unless needed for usage.
- Keep generated docs aligned with actual views and public APIs.
