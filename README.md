# conscript

Tengo una computadora con script(s)

## Install

```
git clone https://github.com/ahobsonsayers/conscript ~/scripts
```

In `.bashrc`

```bash
SCRIPTS="$HOME/scripts/scripts.sh"
[[ -r "$SCRIPTS" ]] && 
  source "$SCRIPTS"
```