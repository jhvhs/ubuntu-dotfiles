# ubuntu-dotfiles

## Installed software
- GlobalProtect VPN - URL required (see below)
- [JetBrains Projector](https://lp.jetbrains.com/projector/) with GoLand (other IDEs can be easily installed using projector)
- docker with `pass` credentials helper
- Kubernetes tooling: [`kind`](https://kind.sigs.k8s.io/docs/), `kubectl`, `kubectx`, `kubens`, `ko` and `kustomize`
- [Go](https://golang.org/)
- `git login` script to load your key from LastPass
- [Carvel](https://carvel.dev) tools
- [Homebrew](https://brew.sh) package manager

## Requirements
1. Lastpass secrets:
   1. HTTPS Certificate and private key for jetbrains projector with following secret names
      - `jb.workstation.crt`
      - `jb.workstation.key`
   2. URL for downloading GlobalProtect in a secret named `gp-linux-url`
   3. Private key used by `git login` in a secret named `ProductivityTools/id_rsa`

2. When generating a gpg key, leave the passphrase empty

## Morning routine

In a tmux session run the following:
```shell
good-morning
```

to ensure the VPN, GoLand and SSH Agent are running and the git key is loaded.
