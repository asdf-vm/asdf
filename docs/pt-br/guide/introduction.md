# Introdução

> Hi, we've recently migrated our docs and added some new pages. If you would like to help translate this page, see the "Edit this page" link at the bottom of the page.

O `asdf` é um gerenciador de versões. Todas as definições de versão das ferramentas estão contidas no arquivo (`.tool-versions`), o qual você pode compartilhar com o seu time no repositório Git de um projeto e garantir que todos estejam usando **exatamente** a mesma versão das ferramentas.

A maneira antiga de trabalhar necessitava diversos gerenciadores de versão, cada um deles com uma documentação, arquivos de configuração diferentes (manipulação do `$PATH`, shims e variáveis de ambiente, por exemplo). O `asdf` provê um único arquivo de configuração e uma única interface para simplificar o fluxo de desenvolvimento, podendo ser ampliado para todas as ferramentas através de um simples plugin.

## Funcionamento

Após instalar e configurar o `asdf` no seu shell, plugins podem ser instalados para gerenciar determinadas ferramentas. Quando uma ferramenta é instalada por um plugin, os executáveis que foram instalados possuem [shims](<https://en.wikipedia.org/wiki/Shim_(computing)>) criados para cada um deles. Quando você roda algum destes executáveis, o shim é executado, permitindo que o `asdf` identifique qual versão da ferramenta está configurada no arquivo `.tool-versions` e execute esta versão.

## Projetos relacionados

### nvm / n / rbenv etc

Ferramentas como o [nvm](https://github.com/nvm-sh/nvm), [n](https://github.com/tj/n) e [rbenv](https://github.com/rbenv/rbenv) são escritas em shell scripts que criam shims para os executáveis instalados para essas ferramentas.

O `asdf` é bem similar e foi criado para competir neste meio de ferramentas de gerenciamento de versão. O grande diferencial do `asdf` é que seu sistema de plugins elimina a necessidade de um gerenciador de versões para cada ferramenta, esta com diferentes comandos e arquivos de configuração.

<!-- ### pyenv

TODO: someone with Python background expand on this

`asdf` has some similarities to `pyenv` but is missing some key features. The `asdf` team is looking at introducing some of these `pyenv` specific features, though no roadmap or timeline is available. -->

### direnv

> Aumenta os shells existentes com a possibilidade de utilizar diferentes variáveis de ambiente com base no diretório atual.

O `asdf` não gerencia variáveis de ambiente, entretanto existe o plugin [`asdf-direnv`](https://github.com/asdf-community/asdf-direnv) para integrar o comportamento do direnv ao asdf.

Veja a [documentação do direnv](https://direnv.net/) para mais detalhes.

### Homebrew

> O gerenciador de pacotes faltante para o macOS (ou Linux)

O Homebrew gerencia seus pacotes e dependências destes pacotes. O `asdf` não gerencia dependencias, não é um gerenciador de pacotes, a escolha do gerenciador de pacotes é reservada ao usuário.

Veja a [documentação do Homebrew](https://brew.sh/) para mais detalhes.

### NixOS

> O Nix é uma ferramenta que relaciona o gerenciamento de pacotes e as configurações de sistema.

O NixOS visa construir ambientes verdadeiramente replicáveis através da gerência das versões exatas dos pacotes e dependências de cada ferramenta, algo que o `asdf` não faz. O NixOS faz isso através da sua própria linguagem de programação, muitas ferramentas da linha de comando e uma coleção de pacotes contendo mais de 60,000 destes.

Novamente, o `asdf` não gerencia dependências/pacotes e não é um gerenciador de pacotes.

Veja a [documentação do NixOS](https://nixos.org/guides/how-nix-works.html) para mais detalhes.

## Por que usar o asdf?

O `asdf` garante que equipes utilizem exatamente a mesma versão de alguma ferramenta, com suporte para **diversas** delas através do sistema de plugins e a _simplicidade e familiaridade_ de ser um único **shell** script que você inclui na configuração do seu shell

::: tip Nota
O `asdf` não foi feito para ser o gerenciador de pacotes do seu sistema, mas sim uma ferramenta para gerenciar versões de outras ferramentas. Não é por que é possível criar um plugin para qualquer ferramenta/linguagem com o `asdf` que esta sempre será a solução mais adequada.
:::
