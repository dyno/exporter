## How to refresh certificate

```bash
tmux ls
tmux attach -t whatever

make terminate
make certrenew

make start-services
```

## How to detatch from a nested tmux session

```bash
# https://blog.damonkelley.me/2016/09/07/tmux-send-keys/
tmux send-keys -t 1 C-B d Enter
```
