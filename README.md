# Bring a Map

## Status

This is still a work in progress. Here's a list of goals and their status:

- [x] Figure out how to add user commands
- [x] Determine data structure for recording map
- [x] Figure out how to show and hide a window with buffer using a command
- [x] Get basic map rendering in place, ignoring loops and multiple children
- [ ] Close map when last window is closed
- [ ] Determine a way to render a map with loops and multiple starting points
- [ ] Implement the map rendering
- [ ] Figure out cursor navigation in the map window
- [ ] Add commands to navigate to files in the map
- [ ] Figure out what else is needed and add to this list

## The purpose

Being new to Neovim, I sometimes lose track of where I am or how I got there.

This is even worse in large, unfamiliar projects.

To remedy this, Bring a Map can be used to record the files you've been to and
how you got there.

## Planning

### Keybinds

| Command | Suggested Keybind | What it does |
| - | - | - |
| BMToggle | `<leader>ms` | Starts/Stops recording the map |
| BMMap | `<leader>me` | Shows/Hides the ASCII map |
| BMReset | `<leader>mr` | Clears the recorded map |

### Map Recording

#### Flat List Option

If we want to show a straight-line map, then we don't care about loops. In that
case, a flat list of files works fine:

```
/path/to/file/a
/path/to/file/b
/path/to/file/in/dir1/c
/path/to/file/in/dir2/d
```

#### Graph Option

If we want to show a map that includes loops, then we'll have to use a graph
structure.

*Shown in JS, because I don't know Lua yet*

##### Graph without a loop

```json
{
    "nodes": {
        "<root>": {
            "filename": "<root>",
            "children": [ "<hash a>" ]
        },
        "<hash a>": {
            "filename": "/path/to/file/a",
            "children": [ "<hash b>" ]
        },
        "<hash b>": {
            "filename": "/path/to/file/b",
            "children": [ "<hash c>" ]
        },
        "<hash c>": {
            "filename": "/path/to/file/in/dir1/c",
            "children": [ "<hash d>" ]
        },
        "<hash d>": {
            "filename": "/path/to/file/in/dir1/d",
            "children": []
        }
    }
}
```

This could be rendered like so

```
▷ ─ ▪ ─ ▪ ─ ▪ ─ ▣
```

```
▷ → ▪ → ▪ → ▪ → ▣
```

##### Graph with a loop

```json
{
    "nodes": {
        "<root>": {
            "filename": "<root>",
            "children": [ "<hash a>" ]
        },
        "<hash a>": {
            "filename": "/path/to/file/a",
            "children": [ "<hash b>", "<hash d>" ]
        },
        "<hash b>": {
            "filename": "/path/to/file/b",
            "children": [ "<hash c>" ]
        },
        "<hash c>": {
            "filename": "/path/to/file/that/loops/c",
            "children": [ "<hash a>" ]
        },
        "<hash d>": {
            "filename": "/path/to/file/d",
            "children": []
        }
    }
}
```

This could be rendered like so

```
    ┌ ─ ─ ─ ─ ┐
▷ ┬ ▪ ─ ▪ ─ ▪ ┘
  └ ▣
```

```
    ┌ ← ← ← ← ┐
▷ ┬ ▪ → ▪ → ▪ ┘
  └ ▣
```

