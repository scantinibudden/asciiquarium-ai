# asciiquarium-plus

[![CI](https://github.com/scantinibudden/asciiquarium-plus/actions/workflows/ci.yml/badge.svg)](https://github.com/scantinibudden/asciiquarium-plus/actions/workflows/ci.yml)
[![License: GPL v2+](https://img.shields.io/badge/license-GPL--2.0--or--later-blue.svg)](LICENSE)
[![Perl](https://img.shields.io/badge/perl-5-39457E.svg)](https://www.perl.org)

Kirk Baucom's [Asciiquarium](https://robobunny.com/projects/asciiquarium/html/) with a few additions. The castle's spot on the sea floor now holds something that sank, and the shark, whale and the rest take turns in order with a pause between them.

It is still a single Perl script, and the original is left alone apart from these changes.

## What's new

- **Sunken decorations.** A treasure chest, a skull or an anchor sits where the castle used to. By default each scene picks one at random (a new one on every redraw), and `-d castle` brings the castle back.
- **Events take turns.** The shark, fish hook, ship, dolphins, big fish, ducks, sea monster, swan and whale appear one at a time in that fixed order and loop forever, starting from a random one. After each one leaves, the sea stays calm for a shared cooldown (`-e`, 30 seconds by default).
- **Named fish.** Every 4 seconds a new fish swims in with the name of one of your running agents (in random order) floating above it. Under Herdr that's every agent pane it tracks, Claude Code and Codex alike, read from `herdr pane list`; without Herdr, the Claude Code sessions in `~/.claude/sessions`. No agents, no names.

## The sea floor

`-d treasure`
```
       _.-~~~~~~~~~~~~~~~~~~~-._
    .-' -_ =  | =  _-  =| _- =  '-.
   /  = _-  _ |  -_ =  _| =  _ -   \
  /_-_=____-__|___=_-___|__-__=__-__\
  |[]=======[]|=.-----.=|[]=======[]|
  | _-  = -_  | | (@) | |  -_ =  _- |
  |=  _- =  _ | |  V  | | _ =  -_ = |
  | -_ =  - _ | '-----' |  = _ -  _-|
  |[]=======[]|=========|[]=======[]|
  |_=_-___=_-_|__-_=____|_=-__-_=___|
```

`-d skull`
```
            _.--~~~~~--._
        .-~' ,      _/   '~-.
      .'  .        / \_      '.
     /  ,         _/  \     .  \
    |    .-~~~~~-. .-~~~~~-.    |
    |   /::'    `\ /'    '::\   |
    |  |:::      | |      :::|  |
    |   \::.    .' '.    .::/   |
     \  `-.__.-' /^\ '-.__.-'  /
      `.        /: :\        .'
        |`.    (__^__)    .'|
        |  `-._________.-'  |
        |   |_|_|_|_|_|_|   |
         \  |_|_|_|_|_|_|  /
          `-.___________.-'
```

`-d anchor`
```
            .-~-.
           /     \
           \     /
            `-.-'
   (_)=-_=-_=|:|=_-=_-=(_)
             |:|
             |:|
             |:|
             |:|
 __          |:|          __
\  `.        |:|        .'  /
 \   `.      |:|      .'   /
  \    `.    |:|    .'    /
   `.    `-._|:|_.-'    .'
     `-.____.\:/.____.-'
              V
```

## Usage

```sh
asciiquarium                  # random sunken decoration, 30 s between events
asciiquarium -d skull         # always the skull
asciiquarium -e 0             # no quiet time: events back to back
asciiquarium -d castle -e 90  # the classic castle, calmer sea
```

| Flag | Meaning | Default |
| --- | --- | --- |
| `-d random\|anchor\|castle\|skull\|treasure` | what sits on the sea floor | `random` (anchor, skull or treasure) |
| `-e <seconds>` | cooldown between events, whole seconds | `30` |

While it runs:

| Key | Action |
| --- | --- |
| `q` | quit |
| `p` | pause / resume |
| `r` | redraw (recreates everything and picks a new random decoration) |

A new scene opens with a random event right away; the cooldown applies between events after that.

## Configuration

To change the defaults without typing flags every time, create `~/.config/asciiquarium-plus/config` (or `$XDG_CONFIG_HOME/asciiquarium-plus/config`):

```ini
# asciiquarium-plus
decoration = skull   # random, anchor, castle, skull or treasure
cooldown = 60        # seconds between events
```

Flags override the file, and the file overrides the built-in defaults (`random`, `30`). The file is only ever read, never written, and it can't break anything:

- a missing, empty or unreadable file means the defaults
- an empty or unknown `decoration` means `random`
- a `cooldown` that isn't a whole number means `30`
- unknown keys and junk lines are ignored

## Install

The script needs Perl 5 with the [Curses](https://metacpan.org/pod/Curses) and [Term::Animation](https://metacpan.org/pod/Term::Animation) modules. It runs anywhere curses does (Linux, macOS, BSD, WSL), but not natively on Windows.

**macOS (Homebrew).** The `asciiquarium` formula already bundles both modules, built for the system Perl, so run the script with `/usr/bin/perl` (a Homebrew `perl` on your `PATH` can't load them):

```sh
brew install asciiquarium
git clone https://github.com/scantinibudden/asciiquarium-plus.git
cd asciiquarium-plus
PERL5LIB="$(brew --prefix asciiquarium)/libexec/lib/perl5" /usr/bin/perl ./asciiquarium
```

**Debian / Ubuntu**

```sh
sudo apt-get install libcurses-perl cpanminus
sudo cpanm Term::Animation
git clone https://github.com/scantinibudden/asciiquarium-plus.git
cd asciiquarium-plus && sudo make install   # installs to /usr/local/bin/asciiquarium
```

**Anywhere else:** install the two modules with `cpan Curses Term::Animation`, then run `./asciiquarium` or `make install PREFIX=~/.local`.

## Development

```sh
make test   # prove t/: compiles, CLI validation, config fallbacks, art/colour-mask alignment, event order
make lint   # perlcritic (gentle, see .perlcriticrc)
```

CI runs both on Linux and runs the tests on macOS.

To add a decoration, write an `add_<name>` sub like `add_treasure` (an image and a colour mask of the same shape) and register it in `%decorations`. It automatically joins the random pool, and `t/art.t` checks that its mask lines up with the art.

## Credits

- **Kirk Baucom**: [Asciiquarium](https://robobunny.com/projects/asciiquarium/html/) and [Term::Animation](https://metacpan.org/pod/Term::Animation).
- **Joan Stark**: most of the original ASCII art.
- **Sebastian Cantini Budden**: asciiquarium-plus (sunken decorations and the event rotation).

The first commit in this repository is the unmodified 1.1 release tarball (tagged `upstream-1.1`), so `git diff upstream-1.1` shows every change.

## License

GPL-2.0-or-later, same as the original. See [LICENSE](LICENSE).
