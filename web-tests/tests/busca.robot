*** Settings ***
Resource         ../resources/busca/busca_keywords.resource
Test Setup       Abrir Blog
Test Teardown    Run Keywords    Capture Screenshot On Failure    AND    Fechar Browser

*** Test Cases ***

CT01 - [EP-válida] Busca com termo válido retorna artigos relevantes
    [Documentation]    Técnica: EP classe válida.
    ...                Dado que o usuário acessa o blog
    ...                Quando ele realiza busca por termo do domínio com publicações (investimento)
    ...                Então ao menos um artigo deve ser exibido na listagem
    [Tags]    web    busca    ep    positivo    regressao    allure.label:epic=Blog
    ...       allure.label:feature=Busca    allure.label:story=Busca válida    allure.label:severity=critical
    Realizar Busca              investimento
    Verificar Resultados Encontrados

CT02 - [EP-inválida] Busca com termo inexistente exibe mensagem de sem resultados
    [Documentation]    Técnica: EP classe inválida.
    ...                Dado que o usuário acessa o blog
    ...                Quando ele realiza busca por termo que não possui publicações (xyzabc123qwerty)
    ...                Então deve ser exibida mensagem informando ausência de resultados
    [Tags]    web    busca    ep    negativo    regressao    allure.label:epic=Blog
    ...       allure.label:feature=Busca    allure.label:story=Busca sem resultados    allure.label:severity=high
    Realizar Busca              xyzabc123qwerty
    Verificar Sem Resultados

CT03 - [EP-válida] Busca por CDB abre o primeiro artigo listado
    [Documentation]    Técnica: EP classe válida.
    ...                Dado que o usuário pesquisa por 'CDB'
    ...                Quando ele abre o primeiro resultado da lista
    ...                Então a página do artigo deve ser carregada com título não vazio
    [Tags]    web    busca    ep    positivo    regressao    allure.label:epic=Blog
    ...       allure.label:feature=Busca    allure.label:story=Abrir primeiro resultado    allure.label:severity=high
    Realizar Busca              CDB
    Abrir Primeiro Resultado
    Wait For Elements State    css=article h1    visible    timeout=10s
    ${title}=    Get Text    css=article h1
    Should Not Be Empty    ${title}    msg=Título vazio na página do artigo

CT04 - [BVA] Busca com acentuação e caracteres especiais não quebra a aplicação
    [Documentation]    Técnica: BVA / Classe especial.
    ...                Dado que o usuário acessa o blog
    ...                Quando ele realiza busca com acentuação e caracteres especiais (café & crédito)
    ...                Então a aplicação deve responder sem erro — com ou sem resultados
    [Tags]    web    busca    bva    negativo    regressao    allure.label:epic=Blog
    ...       allure.label:feature=Busca    allure.label:story=Busca caracteres especiais    allure.label:severity=high
    Realizar Busca              sugestão econômica & crédito
    ${body}=    Get Text    css=body
    Should Not Contain    ${body}    500    msg=Aplicação retornou erro 500 para termo com caracteres especiais
    Should Not Contain    ${body}    Internal Server Error    msg=Aplicação exibiu erro interno para termo com caracteres especiais
