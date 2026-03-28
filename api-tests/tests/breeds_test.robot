*** Settings ***
Resource    ../resources/api_config.resource
Resource    ../resources/dog_api_keywords.resource

Suite Setup    Inicializar Sessao API
Suite Teardown   Encerrar Sessoes API

*** Test Cases ***

CT01 - Lista de raças retorna estrutura completa e válida
    [Documentation]    Dado que a API está disponível
    ...                Quando requiro a lista completa de raças
    ...                Então o response deve ter status 200, campo 'status' igual a 'success' e 'message' com o mapa de raças
    [Tags]    api    breeds    smoke    positivo    allure.label:epic=Dog API
    ...       allure.label:feature=Breeds    allure.label:story=Listar raças    allure.label:severity=critical
    ${response}=    GET Breeds List
    Validar Status Code E Status Field    ${response}    200
    Validar Chaves Basicas No Success    ${response}
    Validar Campo Message Tipo    ${response}    dict

CT02 - Bulldog aparece na lista com suas sub-raças conhecidas
    [Documentation]    Dado que a lista de raças é obtida
    ...                Quando verifico a presença de sub-raças para 'bulldog'
    ...                Então a sub-raça 'boston' deve estar presente
    [Tags]    api    breeds    regressao    positivo    allure.label:epic=Dog API
    ...       allure.label:feature=Breeds    allure.label:story=Validar sub-raça conhecida    allure.label:severity=high
    ${response}=    GET Breeds List
    Validar Status Code E Status Field    ${response}    200
    Validar Lista De SubRacas Contem    ${response}    ${RACA_COM_SUBRACA}    boston

CT03 - Raça sem sub-raças aparece com lista vazia
    [Documentation]    Dado que a lista de raças é obtida
    ...                Quando verifico a raça que não possui sub-raças
    ...                Então a lista correspondente deve ser vazia
    [Tags]    api    breeds    regressao    positivo    allure.label:epic=Dog API
    ...       allure.label:feature=Breeds    allure.label:story=Validar raça sem sub-raças    allure.label:severity=high
    ${response}=    GET Breeds List
    Validar Status Code E Status Field    ${response}    200
    Validar Lista De SubRacas Vazia    ${response}    ${RACA_SEM_SUBRACA}
