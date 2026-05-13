# Radare2 snap and docker repository

[![snap: radare2](https://snapcraft.io/radare2/badge.svg "snap latest stable version")](https://snapcraft.io/radare2)
[![docker: radare/radare2](https://img.shields.io/docker/pulls/radare/radare2?logo=docker&logoColor=white&label=radare%2Fradare2 "docker pulls")](https://hub.docker.com/r/radare/radare2)

This repository contains the recipie to build the snap version of radare2 using docker as well to build a standalone docker image with the same build.

The resulting build includes the following projects:

* [radare2](https://github.com/radareorg/radare2)
* [r2ghidra](https://github.com/radareorg/r2ghidra)
* [r2frida](https://github.com/nowsecure/r2frida) (only in supported platforms)
* [r2dec](https://github.com/wargio/r2dec-js)
* [r2yara](https://github.com/radareorg/r2yara)
* [r2ai](https://github.com/radareorg/r2ai)
* [r2mcp](https://github.com/radareorg/radare2-mcp)
* [r2book](https://github.com/radareorg/radare2-book) (as `info` file)

## Install the snap

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/radare2)

Radare requires snap classic confinement, to install run:

```sh
sudo snap install radare2 --classic
```

Once installed all radare commands are available as:
`radare2.<command>` (ex: `radare2.rasm2`).

### Configure CLI aliases

To allow using radare commands without this prefix, it can be solved by using shell aliases. So as an example could be something like this:

```sh
alias r2='radare2.r2'
alias r2agent='radare2.r2agent'
alias r2frida-compile='radare2.r2frida-compile'
alias r2mcp='radare2.r2mcp'
alias r2p='radare2.r2p'
alias r2pm='radare2.r2pm'
alias r2r='radare2.r2r'
alias r2sdb='radare2.r2sdb'
alias rabin2='radare2.rabin2'
alias radiff2='radare2.radiff2'
alias rafind2='radare2.rafind2'
alias rafs2='radare2.rafs2'
alias ragg2='radare2.ragg2'
alias rahash2='radare2.rahash2'
alias rapatch2='radare2.rapatch2'
alias rarun2='radare2.rarun2'
alias rasign2='radare2.rasign2'
alias rasm2='radare2.rasm2'
alias ravc2='radare2.ravc2'
alias rax2='radare2.rax2'
alias sleighc='radare2.sleighc'
alias yara='radare2.yara'
alias yarac='radare2.yarac'
alias clang-format-radare2='radare2.clang-format-radare2'
```

### Configure MCP

<details>
<summary>Claude Desktop Integration</summary>

In the Claude Desktop app, press `CMD + ,` to open the Developer settings. Edit the configuration file and restart the client after editing the JSON file as explained below:

1. Locate your Claude Desktop configuration file:

   * macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
   * Windows: `%APPDATA%\Claude\claude_desktop_config.json`

2. Add the following to your configuration file:

```json
{
  "mcpServers": {
    "radare2": {
      "command": "radare2.r2mcp"
    }
  }
}
```

</details>

<details>
<summary>VS Code Integration</summary>

To use r2mcp with GitHub Copilot Chat in Visual Studio Code by [adding it to your user configuration](https://code.visualstudio.com/docs/copilot/chat/mcp-servers#_add-an-mcp-server-to-your-user-configuration) (see also [add an mcp server to vscode](https://code.visualstudio.com/docs/copilot/chat/mcp-servers#_add-an-mcp-server)):

1. Open the Command Palette with `CMD + Shift + P` (macOS) or `Ctrl + Shift + P` (Windows/Linux).
2. Search for and select `Copilot: Open User Configuration` (typically found in `~/Library/Application Support/Code/User/mcp.json` in macOS).
3. Add the following to your configuration file:

```json
{
  "servers": {
    "radare2": {
      "type": "stdio",
      "command": "radare2.r2mcp"
    }
  },
  "inputs": []
}
```

</details>

<details>
<summary>Zed Integration</summary>

You can use r2mcp with Zed as well by [adding it to your configuration](https://zed.dev/docs/ai/mcp):

1. Open the command palette: `CMD + Shift + P` (macOS) or `Ctrl + Shift + P` (Windows/Linux).1º
2. Search of `agent: open configuration` or search of `settings`.
3. Add your server as such:

```json
  "context_servers": {
    "r2-mcp-server": {
      "source": "custom",
      "command": "radare2.r2mcp"
    }
  }
```

Note: you will need another LLM agent, such as Claude, Gemini or else to be able to use it.
</details>

## The docker image

As explained, with the same snap build a [docker image](https://hub.docker.com/r/radare/radare2) is generated.

For documentation on how to use this docker image you can refer to [containers section](README-containers.md) in this respository.
