## Desenvolvimento

Para desenvolver o projeto basta executar `git clone` na branch master.

Se você quiser testar suas mudanças sem alterar sua instalação original do `asdf`, você pode definir a variável `$ASDF_DIR` para o caminho onde você clonou o repositório, e prefixar temporariamente os diretórios `bin` e `shims` para o diretório do seu caminho.

Ferramentas que utilizamos:

- [bats](https://github.com/sstephenson/bats) para testes. Certifique-se de que `bats test/` está passando depois que fizer suas alterações.
- [Shellcheck](https://github.com/koalaman/shellcheck) para análise estática dos nossos scripts shell.

## Imagens do Docker

Os projetos [asdf-alpine][asdf-alpine] e [asdf-ubuntu][asdf-ubuntu] são um esforço contínuo para fornecer imagens dockerizadas de algumas ferramentas do asdf. Você pode usar essas imagens do docker como base para seus servidores de desenvolvimento, or para executar seus aplicativos em produção.

[asdf-alpine]: https://github.com/vic/asdf-alpine
[asdf-ubuntu]: https://github.com/vic/asdf-ubuntu