# pvm

`pvm` is a small PHP version manager for Arch Linux development machines using versioned PHP packages from AUR.

It creates a `php` shim and resolves the active version from:

1. `.php-version` in the current directory or a parent directory.
2. The global version in `~/.config/pvm/global`.
3. The default fallback version, `8.2`.

## Install

Clone this repository and add `bin` to your `PATH`:

```sh
export PATH="$HOME/Work/personal/pvm/bin:$HOME/.local/pvm/shims:$PATH"
```

To make it permanent, add that line to your shell profile.

Or install directly from the Git repository:

```sh
curl -fsSL https://raw.githubusercontent.com/lepidus/pvm/main/install.sh | bash
```

If your fork uses a different raw URL, override the source URL:

```sh
curl -fsSL https://raw.githubusercontent.com/USER/pvm/main/install.sh \
  | PVM_SOURCE_URL=https://raw.githubusercontent.com/USER/pvm/main/bin/pvm bash
```

## Usage

Install a PHP version:

```sh
pvm install 8.2
```

Install PHP with extensions:

```sh
pvm install 7.4 --with-extensions mysql intl gd zip mbstring xml
```

Set the global PHP version:

```sh
pvm use 8.2
```

Set the PHP version for the current project:

```sh
pvm use --local 7.4
```

Show the active version:

```sh
pvm current
```

Run PHP normally:

```sh
php -v
php -S 127.0.0.1:8082 -t public
```

## Requirements

- Arch Linux.
- `yay` for `pvm install`.
- Versioned PHP packages such as `php74-cli`, `php80-cli`, and `php82-cli`.
