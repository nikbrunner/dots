# Authentication

One route boundary owns authentication. The provider, session mechanism, endpoint paths, and login/logout transport belong
to the application.

## Route groups

- Public routes live under a pathless `_public/` group, authenticated routes under a pathless `_app/` group.
- `_app/` is guarded before its children render. The root route stays neutral: it owns the outlet and the global error and
  not-found boundaries.
- Both groups may resolve the current-user query in `beforeLoad`. On a 401, `_app/` navigates to login and `_public/`
  continues as an anonymous user.
- The `_app/` guard catches only the authentication 401. Redirects, server and connection failures, and schema errors are
  rethrown for the error boundary.

## One current-user query

- Identity comes from one server-backed current-user query, parsed at the network boundary. That response is the source of
  truth.
- Authentication is never inferred from local storage, decoded tokens, route flags, or permission-gated UI.
- Credentials and access tokens stay out of React state.

## Login and logout

Follow the server's documented flow. When the server owns the session, login is a browser navigation, not a Query fetch.
Logout uses the server's state-changing action. A validated same-origin return path is preserved when the server supports
one.
