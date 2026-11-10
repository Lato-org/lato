# Upgrading Lato

Version-specific notes. For the generic upgrade steps see the [README](README.md#upgrading).

## 3.26.1

- `lato_data_badge` uses Bootstrap `text-bg-*` classes: text on `warning`, `success` and `info` badges is now dark for readable contrast.
- Index sort buttons and pagination links are at least 24x24px (WCAG 2.2 target size).
- Each index paginator has its own `aria-label`, built from the `lato.pagination_label` translation (override it in your locale files if needed).
- Account security confirmation fields have per-form ids: do not rely on the `user_current_password` id in custom JavaScript or tests.

## 3.26.0

- Run `rails lato:install:migrations && rails db:migrate`: the release adds `authenticator_last_used_at` and `webauthn_sign_count` to `lato_users`.
- `lato_page_head(title)` now escapes the title. Pass an `html_safe` string to render HTML.
- `lato_form_item_input_check` escapes the label unless it is `html_safe`.
- `data-turbo-confirm` messages and `data-action-title` are rendered as plain text.
- New config `Lato.config.auth_password_min_length` (default 8), checked whenever a password is set.
- Rate limits are stricter: `limit_requests` allows exactly `limit` requests per IP and action, signin is also limited per email (10 failed attempts in 15 minutes) and second factor attempts are counted per user. The pending second factor step expires after 10 minutes or 5 wrong codes.
- TOTP codes can be used only once and the WebAuthn signature counter is enforced.
- Web3 signin uses a message bound to host, nonce and issue time (single use, 5 minutes) and requires `gem "eth"`.
- `switch_locale` redirects only to same-host referers. The GET route `switch_locale_get` is deprecated: use POST `lato.switch_locale_path(locale:)`.
- `Lato::Operation#start` only starts classes inheriting from `Lato::ApplicationJob`.
- Schedule the maintenance jobs `Lato::LatoOperationsCleanerJob` and `Lato::ActiveStorageCleanerJob` (see the operations documentation).

## 3.25

Lato 3.25 requires Rails >= 8.1.3.1 and < 8.2. Install the new session migration before serving requests (`rails lato:install:migrations && rails db:migrate`).

Sessions are stored as revocable token hashes in the database. Existing cookies require a fresh sign-in after upgrading (global logout). Signing out revokes the current device; changing or recovering a password revokes all devices. Password recovery preserves existing second factors and does not disable them.

Account password, email, authentication factor, wallet, and account deletion changes require the current password plus an enrolled authenticator or security key. Authenticator enrollment requires confirmation with a valid code; an active authenticator's secret is never displayed again. API clients submit `user[current_password]` and, when enrolled, `user[current_authenticator_code]`. Security key clients first POST to `account/security_challenge`, then submit the assertion as `user[current_webauthn_credential]`. Enrollment continuations expire after five minutes and can only be used once.

Extensions updating session attributes must call `session_update(extra_params)` to preserve the revocable session and secure cookie attributes.
