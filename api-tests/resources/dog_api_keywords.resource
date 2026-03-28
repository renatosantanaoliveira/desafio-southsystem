*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    BuiltIn
Library    OperatingSystem

*** Variables ***
${API_SESSION_ALIAS}    dog_api

*** Keywords ***
Inicializar Sessao API
    Carregar Configuracao De Ambiente API
    Create Session    ${API_SESSION_ALIAS}    ${BASE_URL}    verify=${True}

Encerrar Sessoes API
    Delete All Sessions

Carregar Configuracao De Ambiente API
    ${env_file}=    Normalize Path    ${CURDIR}/config/${ENV}.yaml
    File Should Exist    ${env_file}
    Import Variables    ${env_file}
    Variable Should Exist    \${BASE_URL}

# Ações: executam a requisição e retornam o response (sem asserção)
GET Breeds List
    [Documentation]    Executa GET /breeds/list/all e retorna o response.
    [Arguments]    ${session_alias}=${API_SESSION_ALIAS}
    ${response}=    GET On Session Com Retry    ${session_alias}    /breeds/list/all
    RETURN    ${response}

GET Breed Images
    [Documentation]    Executa GET /breed/{breed}/images e retorna o response.
    [Arguments]    ${breed}    ${session_alias}=${API_SESSION_ALIAS}
    ${path}=    Catenate    SEPARATOR=    /breed/    ${breed}    /images
    ${response}=    GET On Session Com Retry    ${session_alias}    ${path}
    RETURN    ${response}

GET Random Image
    [Documentation]    Executa GET /breeds/image/random e retorna o response.
    [Arguments]    ${session_alias}=${API_SESSION_ALIAS}
    ${response}=    GET On Session Com Retry    ${session_alias}    /breeds/image/random
    RETURN    ${response}

GET On Session Com Retry
    [Documentation]    Executa GET com pequeno retry apenas para indisponibilidade transitória (503).
    [Arguments]    ${session_alias}    ${path}
    ${response}=    Wait Until Keyword Succeeds    3x    2s    GET On Session Sem 503    ${session_alias}    ${path}
    RETURN    ${response}

GET On Session Sem 503
    [Arguments]    ${session_alias}    ${path}
    ${response}=    GET On Session    ${session_alias}    ${path}    expected_status=any
    IF    ${response.status_code} == 503
        Fail    API indisponivel temporariamente para o endpoint ${path}
    END
    RETURN    ${response}

# Verificações: recebem o response e fazem asserções com mensagens descritivas
Validar Status Code E Status Field
    [Documentation]    Valida que response tem o status code esperado e campo 'status' com 'success' ou 'error'.
    [Arguments]    ${response}    ${esperado}
    Should Be Equal As Integers    ${response.status_code}    ${esperado}
    ${body}=    Set Variable    ${response.json()}
    Run Keyword If    '${esperado}' == '200'
    ...    Should Be Equal    ${body['status']}    success    msg=Campo 'status' esperado 'success', recebido: ${body['status']}
    ...    ELSE
    ...    Should Be Equal    ${body['status']}    error    msg=Campo 'status' esperado 'error', recebido: ${body['status']}

Validar Chaves Basicas No Success
    [Documentation]    Valida que response de sucesso contém chaves básicas 'message' e 'status'.
    [Arguments]    ${response}
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${body}    message    msg=Campo 'message' ausente no response de sucesso
    Dictionary Should Contain Key    ${body}    status     msg=Campo 'status' ausente no response de sucesso

Validar Campo Message Tipo
    [Documentation]    Valida o tipo do campo 'message' no body (list, dict ou str conforme esperado).
    [Arguments]    ${response}    ${tipo_esperado}
    ${body}=    Set Variable    ${response.json()}
    ${msg}=    Set Variable    ${body['message']}
    ${py_type}=    Evaluate    type(${msg}).__name__
    Should Be Equal    ${py_type}    ${tipo_esperado}    msg=Tipo de 'message' esperado ${tipo_esperado}, recebido: ${py_type}

Validar Campo Message Contem
    [Documentation]    Valida que a mensagem contém a chave/valor esperado (útil para listas/dicts).
    [Arguments]    ${response}    ${esperado}
    ${body}=    Set Variable    ${response.json()}
    ${msg}=    Set Variable    ${body['message']}
    ${found}=    Run Keyword And Return    Evaluate    ${esperado} in ${msg}
    Should Be True    ${found}    msg=Esperado encontrar '${esperado}' em 'message', mas não foi encontrado

Validar Lista De SubRacas Vazia
    [Documentation]    Valida que a lista de sub-raças para uma raça é vazia.
    [Arguments]    ${response}    ${breed}
    ${body}=    Set Variable    ${response.json()}
    ${msg}=    Set Variable    ${body['message']}
    ${subracas}=    Get From Dictionary    ${msg}    ${breed}
    Length Should Be    ${subracas}    0    msg=Esperado lista vazia de sub-raças para ${breed}, encontrado: ${subracas}

Validar Lista De SubRacas Contem
    [Documentation]    Valida que a raça possui sub-raças e uma sub-raça conhecida está presente.
    [Arguments]    ${response}    ${breed}    ${sub}
    ${body}=    Set Variable    ${response.json()}
    ${msg}=    Set Variable    ${body['message']}
    ${subracas}=    Get From Dictionary    ${msg}    ${breed}
    List Should Contain Value    ${subracas}    ${sub}    msg=Sub-raça '${sub}' esperada em ${breed}, mas não encontrada: ${subracas}

Validar Lista De Imagens Nao Vazia
    [Documentation]    Valida que a resposta contém lista 'message' com ao menos uma URL.
    [Arguments]    ${response}
    ${body}=    Set Variable    ${response.json()}
    ${msg}=    Set Variable    ${body['message']}
    Should Not Be Empty    ${msg}    msg=Lista de imagens retornada está vazia

Validar Response De Erro Completo
    [Documentation]    Valida que response de erro contém campos 'status','message' e 'code'.
    [Arguments]    ${response}    ${esperado_code}
    ${body}=    Set Variable    ${response.json()}
    Should Be Equal    ${body['status']}    error    msg=Campo 'status' esperado 'error', recebido: ${body['status']}
    Dictionary Should Contain Key    ${body}    message    msg=Campo 'message' ausente no response de erro
    Dictionary Should Contain Key    ${body}    code       msg=Campo 'code' ausente no response de erro
    Should Be Equal As Integers    ${body['code']}    ${esperado_code}    msg=Campo 'code' esperado ${esperado_code}, recebido: ${body['code']}

Validar URL De Imagem
    [Documentation]    Valida que o campo 'message' contém uma URL e começa com 'https://'.
    [Arguments]    ${response}
    ${body}=    Set Variable    ${response.json()}
    ${url}=    Set Variable    ${body['message']}
    Should Start With    ${url}    https://    msg=URL da imagem não começa com 'https://': ${url}

Validar URL Segue Padrao
    [Documentation]    Valida que a URL da imagem aleatória segue o padrão oficial (contém 'dog.ceo').
    [Arguments]    ${response}
    ${body}=    Set Variable    ${response.json()}
    ${url}=    Set Variable    ${body['message']}
    Should Contain    ${url}    dog.ceo    msg=URL da imagem não segue o domínio oficial: ${url}
