# pvm

`pvm` is a small PHP version manager for development machines using PHP builds from Homebrew.

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
curl -fsSL https://raw.githubusercontent.com/thiagolepidus/pvm/main/install.sh | bash
```

The remote installer installs Homebrew when it is missing, configures the `shivammathur/php` and
`shivammathur/extensions` taps, installs `pvm`, and adds Homebrew plus `pvm` to your shell profile.

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

Supported versions are `5.6`, `7.0` to `7.4`, and `8.0` to `8.6`.

Install PHP with extensions:

```sh
pvm install 7.4 --with-extensions xdebug redis imagick
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

- Homebrew.
- The `shivammathur/php` tap for PHP versions.
- The `shivammathur/extensions` tap for optional external extensions.

`pvm install` taps the required repositories automatically:

```sh
brew tap shivammathur/php
brew tap shivammathur/extensions
```

PHP formulas use the `php@<version>` naming convention, for example:

```sh
shivammathur/php/php@7.4
shivammathur/php/php@8.2
```

External extension formulas use the `<extension>@<version>` naming convention, for example:

```sh
shivammathur/extensions/xdebug@8.2
```
