# Bring a Map

## The purpose

Being new to Neovim, I sometimes lose track of where I am or how I got there.

This is even worse in large, unfamiliar projects.

To remedy this, Bring a Map can be used to record the files you've been to and
how you got there.

## Planning

### Keybinds

| Builtin | Keybind | What it does |
| - | - | - |
| BMToggle | `<leader>ms` | Starts/Stops recording the map |
| BMExplorer | `<leader>me` | Shows the text map explorer |
| BMMap | `<leader>mc` | Shows the ASCII map |

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

```js
const nodes = Map();
nodes.set('/path/to/file/a', [
    '/path/to/file/b',
]);
nodes.set('/path/to/file/b', [
    '/path/to/file/in/dir1/c',
]);
nodes.set('/path/to/file/in/dir1/c', [
    '/path/to/file/in/dir2/d',
]);
nodes.set('/path/to/file/in/dir2/d', []);
```

This could be rendered like so

```
▷ ─ ▪ ─ ▪ ─ ▣
```

##### Graph with a loop

```js
const nodes = Map();
nodes.set('/path/to/file/a', [
    '/path/to/file/b', 'path/to/file/e',
]);
nodes.set('/path/to/file/b', [
    '/path/to/file/that/loops/a',
]);
nodes.set('/path/to/file/that/loops/a', [
    '/path/to/file/a',
]);
nodes.set('path/to/file/e', []);
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

