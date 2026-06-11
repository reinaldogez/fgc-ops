# fcg-ops

> README provisório — cobre apenas o token de build do fluxo `--build`.
> A documentação completa do sistema entra numa etapa posterior.

## Build local (`docker compose up --build`) — token do GHCR

O fluxo `--build` compila o `fcg-identity` a partir do repositório irmão (`../fcg-identity`).
Esse build faz `dotnet restore` do pacote `Fcg.Contracts` no feed NuGet do GitHub Packages,
que **exige autenticação mesmo para pacote público**. O compose injeta o token no build via a
variável de ambiente `GH_TOKEN` (um PAT com escopo `read:packages`).

> O fluxo de demonstração (`docker compose up`, sem `--build`) **puxa a imagem publicada do
> GHCR e não precisa de token nenhum**. O `GH_TOKEN` só é necessário para compilar localmente.

### Persistir o `GH_TOKEN` no ambiente do usuário

Para não redigitar o token a cada terminal, grave-o uma vez no escopo **User** do Windows:

```powershell
[Environment]::SetEnvironmentVariable("GH_TOKEN", "ghp_seuTokenReal", "User")
```

- `"GH_TOKEN"` — nome fixo que o compose procura; não altere.
- `"ghp_seuTokenReal"` — substitua pelo seu PAT com `read:packages` (exemplo, não é um token real).
- `"User"` — escopo fixo: persiste a variável só para a sua conta de usuário e passa a valer
  em **todo terminal novo**, sobrevivendo a reinícios. (`"Machine"` valeria para todos os
  usuários e exigiria admin; `"Process"` valeria só na sessão atual, igual a `$env:GH_TOKEN=`.)

O efeito só aparece em terminais **abertos depois** do comando — o terminal atual mantém o
valor antigo. Confira com:

```powershell
[Environment]::GetEnvironmentVariable("GH_TOKEN", "User")
```

O token **nunca** é versionado: vive apenas no ambiente do usuário (ou num arquivo local
ignorado pelo Git). Nenhum arquivo do repositório carrega o valor real.
