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
      - Note: these are typically self-signed, in which case the signing CA must be imported into the keychain of the computer remotely accessing projector.
   2. URL for downloading GlobalProtect in a secret named `gp-linux-url`
   3. Private key used by `git login` in a secret named `ProductivityTools/id_rsa`

2. When generating a gpg key, leave the passphrase empty

## Morning routine

In a tmux session run the following:
```shell
good-morning
```

to ensure the VPN, GoLand and SSH Agent are running, and the git key is loaded.

## Using projector

The most responsive and stable client on macOS for the projector seems to be Safari.
In addition to being quick, it also opens the links in the GUI directly in a separate tab.
The native projector client, for example will call the server-side browser, and that will require
setting up X forwarding.

To open an IDE from the browser, follow the URL:

https://_[hostname]_:_[port]_?token=_[password]_

where:
- _[hostname]_ is either the host name, or the IP address of the linux box
- _[port]_ is the IDE port, defaults to 9999, but may be overridden
- _[password]_ is the password set at configuration time. It is possible to set a separate read-only password.
- _https_ will only be available when the certificate has been successfully installed, otherwise projector will fall 
  back to _http_ (highly discouraged)  