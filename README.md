# zsh-django
Completion for django manage.py command.

## Installation

### [antigen](https://github.com/zsh-users/antigen)

1. Add the following to your `.zshrc`:

    ```sh
    antigen bundle ikhomutov/zsh-django
    ```

2. Start a new terminal session.

### [oh-my-zsh](http://github.com/robbyrussell/oh-my-zsh)

1. Clone this repository into `$ZSH_CUSTOM/plugins` (by default `~/.oh-my-zsh/custom/plugins`)

    ```sh
    git clone https://github.com/ikhomutov/zsh-django ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-django
    ```

2. Add the plugin to the list of plugins for Oh My Zsh to load (inside `~/.zshrc`):

    ```sh
    plugins=(
      ...
      zsh-django
    )
    ```

3. Start a new terminal session.

### Manual (Git Clone)

1. Clone this repository somewhere on your machine.

    ```sh
    git clone https://github.com/ikhomutov/zsh-django ~/.zsh/zsh-django
    ```

2. Add the following to your `.zshrc`:

    ```sh
    source ~/.zsh/zsh-django/zsh-django.zsh
    ```

3. Start a new terminal session.
