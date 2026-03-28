*** Settings ***
Resource         ../resources/busca/busca_keywords.resource
Test Setup       Abrir Blog
Test Teardown    Run Keywords    Capture Screenshot On Failure    AND    Fechar Browser

*** Test Cases ***

CT01 - Busca com termo válido retorna artigos relevantes
    [Documentation]    Valida que a busca exibe artigos quando o termo pesquisado possui publicações relacionadas.
    ...                Dado que o usuário acessa o blog
    ...                Quando ele realiza busca por termo do domínio com publicações (investimento)
    ...                Então ao menos um artigo deve ser exibido na listagem
    [Tags]    web    busca    regressao    positivo    allure.label:epic=Blog
    ...       allure.label:feature=Busca    allure.label:story=Busca válida    allure.label:severity=critical
    Realizar Busca              investimento
    Verificar Resultados Encontrados

CT02 - Busca com termo inexistente exibe mensagem de sem resultados
    [Documentation]    Valida que a aplicação informa ausência de resultados para um termo sem publicações relacionadas.
    ...                Dado que o usuário acessa o blog
    ...                Quando ele realiza busca por termo que não possui publicações (xyzabc123qwerty)
    ...                Então deve ser exibida mensagem informando ausência de resultados
    [Tags]    web    busca    regressao    negativo    allure.label:epic=Blog
    ...       allure.label:feature=Busca    allure.label:story=Busca sem resultados    allure.label:severity=high
    Realizar Busca              xyzabc123qwerty
    Verificar Sem Resultados

CT03 - Busca por CDB abre o primeiro artigo listado
    [Documentation]    Valida que o usuário consegue abrir um artigo a partir da lista de resultados da busca.
    ...                Dado que o usuário pesquisa por 'CDB'
    ...                Quando ele abre o primeiro resultado da lista
    ...                Então a página do artigo deve ser carregada com título não vazio
    [Tags]    web    busca    smoke    regressao    positivo    allure.label:epic=Blog
    ...       allure.label:feature=Busca    allure.label:story=Abrir primeiro resultado    allure.label:severity=high
    Realizar Busca              CDB
    Abrir Primeiro Resultado
    Wait For Elements State    css=article h1    visible    timeout=10s
    ${title}=    Get Text    css=article h1
    Should Not Be Empty    ${title}    msg=Título vazio na página do artigo

CT04 - Busca com acentuação e caracteres especiais não quebra a aplicação
    [Documentation]    Valida que a busca trata caracteres especiais sem apresentar erro de aplicação.
    ...                Dado que o usuário acessa o blog
    ...                Quando ele realiza busca com acentuação e caracteres especiais (café & crédito)
    ...                Então a aplicação deve responder sem erro — com ou sem resultados
    [Tags]    web    busca    robustez    negativo    regressao    allure.label:epic=Blog
    ...       allure.label:feature=Busca    allure.label:story=Busca caracteres especiais    allure.label:severity=high
    Realizar Busca              sugestão econômica & crédito
    ${body}=    Get Text    css=body
    Should Not Contain    ${body}    500    msg=Aplicação retornou erro 500 para termo com caracteres especiais
    Should Not Contain    ${body}    Internal Server Error    msg=Aplicação exibiu erro interno para termo com caracteres especiais
