# Perguntas frequentes

Aqui estão algumas perguntas comuns sobre `asdf`.

## Suporte WSL1?

WSL1 ([Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) 1) não é oficialmente suportado. Alguns aspectos do `asdf` podem não funcionar corretamente. Não temos a intenção de adicionar suporte oficial para WSL1.

## Suporte WSL2?

WSL2 ([Subsistema Windows para Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux#WSL_2) 2) deve funcionar usando as instruções de configuração e dependência para a distribuição WSL escolhida.

É importante ressaltar que o WSL2 _apenas_ deve funcionar corretamente quando o diretório de trabalho atual é uma unidade Unix e não uma unidade Windows vinculada.

Pretendemos executar o conjunto de testes no WSL2 quando o suporte ao host runner estiver disponível nas Ações do GitHub; atualmente, esse não parece ser o caso.

## Exectable recém-instalado não está funcionando?

> Acabei de instalar o `npm -g yarn`, mas não consigo executar o `yarn`. O que da?

`asdf` usa [shims](<https://en.wikipedia.org/wiki/Shim_(computing)>) para gerenciar executáveis. Aqueles instalados por plug-ins têm shims criados automaticamente, enquanto a instalação de executáveis ​​por meio de uma ferramenta gerenciada `asdf` exigirá que você notifique o`asdf` sobre a necessidade de criar shims. Neste caso, para criar um shim para [Yarn](https://yarnpkg.com/). Veja a documentação do comando [`asdf reshim`](/ manage / core.md # reshim).

## Shell não detecta shims recém-instalados?

Se `asdf reshim` não está resolvendo seu problema, então é mais provável devido ao sourcing de`asdf.sh` ou `asdf.fish` _não_ estar no ** BOTTOM ** de seu arquivo de configuração Shell (`.bash_profile`, `.zshrc`, `config.fish`, etc). Ele precisa ser fornecido **DEPOIS** de você definir seu `$PATH` e **DEPOIS** de ter fornecido seu framework (oh-meu-zsh etc), se houver.
