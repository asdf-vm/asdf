## Desenvolvimento

Para desenvolver o projeto, use `git clone` na _master branch_. 

Se você quiser experimentar suas mudanças sem fazer alterações em seu `asdf` instalado, você pode definir a variável `$ ASDF_DIR` para o caminho onde você clonou o repositório, e adicionar temporariamente o diretório `bin` e `shims`.

Ferramentas que usamos:

- [bats](https://github.com/bats-core/bats-core) para testes. Certificar-se de que `bats test /` passa nos testes após você fazer suas alterações.
- [Shellcheck](https://github.com/koalaman/shellcheck) para análise estática dos scripts shell.

## Imagem Docker 

Os projetos [asdf-alpine] [asdf-alpine] e [asdf-ubuntu] [asdf-ubuntu] são um
esforço contínuo para fornecer imagens docker de algumas ferramentas asdf. Você pode usar
essas imagens docker como base para seus servidores de desenvolvimento, ou para executar seu
aplicativos em produção.

[asdf-alpine]: https://github.com/vic/asdf-alpine
[asdf-ubuntu]: https://github.com/vic/asdf-ubuntu
