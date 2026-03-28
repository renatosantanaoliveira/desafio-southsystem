*** Settings ***
Library    Browser
Library    Collections
Library    BuiltIn
Library    OperatingSystem
Library    String
Resource   ../busca/busca_variables.resource

*** Keywords ***
Abrir Blog
    Carregar Configuracao De Ambiente
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Context
    New Page       ${BASE_URL}
    Wait For Load State    networkidle

Carregar Configuracao De Ambiente
    ${env_file}=    Normalize Path    ${CURDIR}/../config/${ENV}.yaml
    File Should Exist    ${env_file}
    Import Variables    ${env_file}
    Variable Should Exist    \${BASE_URL}

Fechar Browser
    Close Browser

Click Search Icon
    FOR    ${sel}    IN    @{SEARCH_ICON_SELECTORS}
        ${clicked}=    Run Keyword And Return Status    Click    ${sel}
        Run Keyword If    ${clicked}    Return From Keyword
    END

Realizar Busca
    [Arguments]    ${termo}
    Click Search Icon
    ${input_visible}=    Run Keyword And Return Status    Wait For Elements State    ${SEARCH_INPUT}    visible    timeout=3s
    Run Keyword If    ${input_visible}    Fill Text    ${SEARCH_INPUT}    ${termo}
    ${encoded_termo}=    Evaluate    urllib.parse.quote($termo, safe='')    modules=urllib.parse
    Go To    ${BASE_URL}/?s=${encoded_termo}
    Wait For Load State    networkidle
    Wait For Elements State    ${RESULTS_CONTAINER}    visible    timeout=10s

Verificar Resultados Encontrados
    Wait For Elements State    ${RESULTS_CONTAINER}    visible    timeout=10s
    ${content}=    Get Text    ${RESULTS_CONTAINER}
    Should Contain    ${content}    Resultados encontrados para

Verificar Sem Resultados
    Wait For Elements State    ${RESULTS_CONTAINER}    visible    timeout=10s
    ${body}=    Get Text    css=body
    Should Contain    ${body}    ${NO_RESULTS_MSG}    ignore_case=True

Abrir Primeiro Resultado
    Wait For Elements State    ${RESULTS_CONTAINER}    visible    timeout=10s
    ${first}=    Obter Primeiro Link De Resultado
    ${target_url}=    Get Attribute    ${first}    href
    Should Not Be Empty    ${target_url}    msg=O primeiro resultado nao possui URL navegavel
    Click    ${first}
    Wait For Load State    networkidle
    Wait Until Keyword Succeeds    10x    1s    Url Atual Deve Representar Artigo

Obter Primeiro Link De Resultado
    FOR    ${selector}    IN    @{FIRST_RESULT_LINK_SELECTORS}
        ${elements}=    Get Elements    ${selector}
        ${has_results}=    Run Keyword And Return Status    Should Not Be Empty    ${elements}
        ${first_element}=    Run Keyword If    ${has_results}    Get From List    ${elements}    0
        Run Keyword If    ${has_results}    Return From Keyword    ${first_element}
    END
    Fail    Nenhum link de artigo encontrado nos resultados para os seletores configurados

Url Atual Deve Representar Artigo
    ${current_url}=    Get Url
    Should Not Contain    ${current_url}    ?s=

Capture Screenshot On Failure
    [Documentation]    Tira screenshot e injeta thumbnail no relatório se o teste falhar.
    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Capture And Log Screenshot

Capture And Log Screenshot
    [Documentation]    Captura screenshot com timestamp e adiciona thumbnail ao log
    ${ts}=    Get Time    %Y%m%d_%H%M%S
    ${safe_name}=    Replace String Using Regexp    ${TEST NAME}    \s+    _
    ${file_name}=    Set Variable    ${safe_name}-${ts}.png
    ${full_path}=    Set Variable    ${OUTPUT DIR}/${file_name}
    Take Screenshot    ${full_path}
    ${img_tag}=    Set Variable    <a href="${file_name}"><img src="${file_name}" style="width:240px;border:1px solid #ddd"/></a>
    Log    ${img_tag}    html=True
