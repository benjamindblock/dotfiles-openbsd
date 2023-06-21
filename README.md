# dotfiles-openbsd
Dotfiles for OpenBSD systems. This repo should be directly cloned into the `$HOME` directory of the OpenBSD system. No using `mkrc`, worrying about symlinks, etc.

## TODO:
- Separate the OpenBSD personal from the OpenBSD server configuration? It would be nice to have a single, minimal setup for servers.

## Setup
1. Generate new SSH keypair and add to Github
2. `doas pkg_add git`
3. `git init .`
4. `git remote add origin git@github.com:benjamindblock/dotfiles-openbsd.git`
5. `git pull origin master`
6. `bin/setup`
7. `vi .vimrc`
8. `:PlugInstall`
9. `mkdir .aws`
10. `touch .aws/credentials`
11. Add any access keys that may be needed. Right now the default is for the `drainpipe-ams-log-uploader` IAM user that uploads `httpd` `access.log` and `error.log` nightly.

## Root user setup
When setting up an OpenBSD system, we should add a minimal set of configs to the `root` user environment. This makes actions such as `doas vim /etc/httpd.conf` much less painful, because we will have a decent Vim setup installed. We don't want to introduce heavily config'd programs here. Instead, we should use the default `ksh` and basic Vim only. We don't want to encourage extended sessions after `login root`, but rather should make sure we limit the interaction to `doas ...` wherever possible.

1. Login as `root`

2. Append the following to `.profile`
```
PS1='$USER:$PWD# '
export PS1

LSCOLORS=fxexcxdxbxegedabagacad
export LSCOLORS

alias ls='colorls -G'
alias ll='colorls -AhltrG'
alias vi='vim'
```

4. Symlink `.vimrc`
```
$ ln -s /home/ben/.vimrc .vimrc
```

5. Symlink `.vim/`
```
$ ln -s /home/ben/.vim/ .vim
```

6. Install plugins
```
$ vi .vimrc
:PlugInstall
```

## Webserver Logging
`httpd` server logs are located at `/var/www/logs/access.log` and `/var/www/logs/error.log`

Backup to S3 happens nightly using `crontab`. To view or edit the jobs: `crontab -e`.

Currently they look like this.
```
0 0 * * * /usr/local/bin/aws s3 cp /var/www/logs/access.log s3://drainpipe-logs/daily.access.log
0 0 * * * /usr/local/bin/aws s3 cp /var/www/logs/error.log s3://drainpipe-logs/daily.error.log
```

For instructions on backups to S3, I followed [this article.](https://rgth.co/blog/backup-to-s3-with-cronjobs/)

On the AWS account (for `benjamindblock@gmail.com`) there is an S3 bucket (`drainpipe-logs`), IAM user (`drainpipe-ams-log-uploader`), and policy (`drainpipe-ams-log-uploader`).

## Webserver Analytics
Analytics for [benjamindblock.com](benjamindblock.com) and [accessoryrecords.com](accessoryrecords.com) are provided by [GoatCounter](https://www.goatcounter.com).

Dashboard for both sites is available at: [https://benjamindblock.goatcounter.com/](https://benjamindblock.goatcounter.com/).

In the future, it could be interesting to explore the self-hosted option.

## Webserver Monitoring
Monitoring is provided by [Prometheus](https://prometheus.io), [node_exporter](https://github.com/prometheus/node_exporter), and [Grafana](https://grafana.com).

Setup was followed from [this helpful blog post](https://findelabs.com/post/grafana-prometheus-monitoring-openbsd/).

To access the Grafana dashboard, navigate to the IP address of the server at port 3000.

For `drainpipe-ams` on OpenBSD Amsterdam this is: [46.23.92.176:3000](46.23.92.176:3000).

NOTE: Prometheus, node_exporter, and Grafana all run as daemons.
`doas rcctl enable prometheus node_exporter grafana`
`doas rcctl start prometheus node_exporter grafana`

Relevant configuration files are located at:
- `/var/etc/prometheus/prometheus.yml`
- `/var/etc/prometheus/targets.json`
- `/etc/rc.d/prometheus`

## Setting up a VPN connection from home via Mullvad
Steps to setup a Wireguard connection to my Mullvad VPN:
1. Use the [Wireguard configuration file generator](https://mullvad.net/en/account/#/wireguard-config) to generate a new key and config file.
2. On the OpenBSD machine: `pkg_add wireguard-tools`
3. Create `/etc/wireguard/wg0.conf`
4. Copy the contents of the config file into `wg0.conf`
5. Initialize the interface: `doas wg-quick up wg0`
6. Verify the new Wireguard connection: `doas wg show`, `ifconfig`
7. Verify IP address is now masked: `curl https://ip.ianix.com`

Ref: Followed the "client" setup instructions from this article: [https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/](https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/)
