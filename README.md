# Upstream

Set up cron jobs to automatically fetch from your upstream remotes.

## Installation

`$ gem install upstream`

## Requirements

You must have a public/private key pair (with no passphrase) called `github_id_rsa` in your `~/.ssh` directory. Create this by running the following command:

```bash
$ ssh-keygen
```

When prompted, enter `/Users/<yourusername>/.ssh/github_id_rsa`.

Then, when asked for a passphrase, just press Return twice.

Finally, `cat /Users/<yourusername>/.ssh/github_id_rsa.pub`, copy the output, and paste it as a new SSH key on GitHub.

## Usage

```bash
$ cd <path-to-your-repository>
$ upstream .
```

## Options

Pull instead of just fetch from your upstream remotes.

```bash
$ upstream . -p
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/upstream/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Built by [@loganhasson](http://twitter.com/loganhasson) in NYC