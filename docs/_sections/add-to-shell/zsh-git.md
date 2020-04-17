Source the `asdf.sh` script in your shell config:

```shell
echo -e "\n. $HOME/.asdf/asdf.sh" >> ~/.zshrc
```

or use a framework plugin like [asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) which will source this init script and setup completions.

ZSH Completions:

asdf ships with ZSH completions which will need to be setup if you're not using a ZSH framework plugin that does this for you. Add the following to your `.zshrc`:

```shell
# append completions to fpath
echo -e "\nfpath=(${ASDF_DIR}/completions $fpath)" >> ~/.zshrc
# initialise completions with ZSH's compinit
echo -e "\nautoload -Uz compinit && compinit" >> ~/.zshrc
```

- if you are using a custom `compinit` setup, ensure `compinit` is below your sourcing of `asdf.sh`
- if you are using a custom `compinit` setup with a ZSH framework, ensure `compinit` is below your sourcing of the framework
- if you are using a ZSH framework with an asdf plugin, then you shouldn't need to manually add `fpath`, the plugin may need to be updated to use the new ZSH completions properly
