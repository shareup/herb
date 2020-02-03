# Herb

**Execute `.exs` scripts with the ability to depend on other mix projects (including hex packages) without setting up a project yourself.**

Elixir is a great scripting language, except that it's not possible to write a sophisticated script as a single file. Herb makes this possible.

Use `herb` instead of `elixir` to run your scripts or include `herb` into your shebang [like the example](test/example.exs):

```elixir
#!/usr/bin/env herb

Herb.package(:jason, "1.1.2")

IO.inspect(Jason.decode!("{}"))
```

You can also `import Herb` and then call `package/1` directly.

## Installation

For now, installation is manual:

```sh
$ git clone https://github.com/shareup/herb.git
$ cd herb
$ mix escript.install
```

