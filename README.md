# Aider for Viewerly

Runs [Aider](https://aider.chat), the AI pair programmer in your terminal, as a
[Viewerly](https://viewerly.io) agent that tells Viewerly when it is waiting for you.

Viewerly already offers Aider as a built-in agent, but only knows whether it is running. This
plugin adds an agent called **Aider (with status)** that starts Aider with its notification
command pointed at Viewerly, so the session turns to *Waiting for input* when Aider has finished a
reply and wants you, and the attention badge and notifications follow as they do for Claude Code.

It is an agent definition: data, no code of its own, free on every tier.

## What it asks for

Nothing. An agent definition has no capabilities to grant: it says which executable to start,
where to find it, its arguments, and what the events it reports mean. It cannot set
`CLAUDE_CONFIG_DIR` or any `VIEWERLY_*` variable (Viewerly refuses such a definition).

## What Aider can and cannot report

Viewerly takes a session's status only from events the agent reports; it never guesses from the
terminal. Aider has one way to report, its notifications command, so:

| Status | Shown? |
| --- | --- |
| Running (the process is alive) | Yes, as for every agent. |
| **Waiting for input** | **Yes.** Aider runs the command when the model has replied and Aider is asking you for something: your next message, or a yes/no question such as adding a file, running a shell command or applying an edit. |
| Working | No. Aider has no hook for a turn starting, so after you answer, the session keeps showing *Waiting for input* until the next time Aider waits. |
| Waiting for permission | No. Aider's confirmations happen in its own terminal and show as *Waiting for input*; Viewerly cannot answer them, and no plugin can. |
| Done / ended | The session ends when the process exits, as for every agent. |

Aider only rings after the model has run at least once, so a freshly started session shows as
running, not waiting, until your first exchange.

## How it works

`agents/aider.toml` starts Aider with:

```
aider --notifications --notifications-command "\"{bridge}\" hook --event waiting"
```

Viewerly replaces `{bridge}` with the path of its `viewerly-bridge` helper and puts the session's
id and socket in Aider's environment. Aider runs the command through the shell each time it waits
for you; `viewerly-bridge hook --event waiting` tells Viewerly, and `[hooks] waiting =
"waiting_for_input"` maps that onto the status.

The flags are Aider's own: `--notifications` turns notifications on and `--notifications-command`
replaces the terminal bell with a command (see Aider's
[options](https://aider.chat/docs/config/options.html) and
[notifications](https://aider.chat/docs/usage/notifications.html) pages). That the command runs
through the shell, and only after the model has run, was checked against Aider's source
(`aider/io.py`, `ring_bell`) in October 2026. If you set `notifications-command` in your own
`.aider.conf.yml` or `AIDER_NOTIFICATIONS_COMMAND`, the command-line flag here takes precedence in
Viewerly sessions.

## Installing Aider

Any of:

```sh
python -m pip install aider-install && aider-install
uv tool install --python python3.12 aider-chat
pipx install aider-chat
```

Viewerly looks for `aider` in `~/.local/bin` (where aider-install, uv and pipx put it),
`/opt/homebrew/bin`, `/usr/local/bin` and `/home/linuxbrew/.linuxbrew/bin`, then on your `PATH`.
If yours is elsewhere, set its path in Settings › Agents. Configure Aider's model and API keys as
you normally would (`.aider.conf.yml`, `.env` or environment variables).

## Installing the plugin

Download `io.viewerly.aider-<version>.vplugin` from the
[releases](https://github.com/viewerly/plugin-aider/releases), then:

- **Settings › Plugins › Install from File…**, or
- `viewerly plugin install io.viewerly.aider-1.0.0.vplugin`.

Once it is listed in the directory, **Settings › Plugins › Browse Plugins…** installs it without a
download. **Aider (with status)** then appears in the New Session menu and in Settings › Agents.

## Building

```sh
./build.sh    # dist/io.viewerly.aider-<version>.vplugin
```

Nothing is compiled; the script zips the manifest, the agent definition, this README and the
licence. A `v*` tag builds and attaches it to a GitHub release (`.github/workflows/release.yml`).

## Licence

MIT, © 2026 Viewerly. See [LICENSE](LICENSE). Aider is © Paul Gauthier and contributors, under the
Apache License 2.0; this plugin only starts it.
