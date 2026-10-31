# replit_ui example

This runnable Gemini chat uses the integrated `UiDesignChat` controller and
`UiDesignChatView`. It includes a `set_theme` tool to demonstrate app-owned
actions, along with streaming, stop, retry, edit, attachments, copy and
feedback.

Get a key from [Google AI Studio](https://aistudio.google.com/apikey), then
run the app with:

```bash
flutter run --dart-define=GEMINI_API_KEY=AIza...
```

You can also copy `env.example.json` to the gitignored `env.json`, add the key,
and launch with:

```bash
flutter run --dart-define-from-file=env.json
```

With no key, the app still runs and shows the normal error state after a send.

For a live tour of every component, open the hosted
[playground](https://replit.asimawdah.com/playground) or run it from the repository:

```bash
cd playground && flutter run -d chrome
```
