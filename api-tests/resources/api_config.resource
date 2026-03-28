*** Settings ***
# Arquivo exclusivo para configuração e variáveis da API Dog (sem Libraries nem Keywords)

*** Variables ***
${ENV}                  dev

# Raças usadas nos testes — valores garantidos pela documentação oficial (README da API)
# válida e possui sub-raças
${RACA_VALIDA}          hound

# formato inválido para path de raça
${RACA_COM_CARACTERE_INVALIDO}    hound@

# nunca existirá
${RACA_INEXISTENTE}     racaficticiaxyz

# raça que possui array vazio de sub-raças
${RACA_SEM_SUBRACA}     affenpinscher

# possui sub-raças: boston, english, french
${RACA_COM_SUBRACA}     bulldog
