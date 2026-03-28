*** Settings ***
Resource    ../resources/api_config.resource
Resource    ../resources/dog_api_keywords.resource

Suite Setup    Inicializar Sessao API
Suite Teardown   Encerrar Sessoes API

*** Test Cases ***

CT04 - Imagens de raça válida são retornadas com sucesso
    [Documentation]    Dado que a raça válida é informada
    ...                Quando requiro as imagens dessa raça
    ...                Então devo receber status 200 e lista de URLs não vazia
    [Tags]    api    imagens    regressao    positivo    allure.label:epic=Dog API
    ...       allure.label:feature=Images    allure.label:story=Listar imagens por raça    allure.label:severity=high
    ${response}=    GET Breed Images    ${RACA_VALIDA}
    Validar Status Code E Status Field    ${response}    200
    Validar Lista De Imagens Nao Vazia    ${response}

CT05 - Raça inexistente retorna erro com contrato correto
    [Documentation]    Dado que informo uma raça que não existe
    ...                Quando requiro suas imagens
    ...                Então a API deve retornar um erro com o contrato esperado
    [Tags]    api    imagens    regressao    negativo    allure.label:epic=Dog API
    ...       allure.label:feature=Images    allure.label:story=Erro para raça inexistente    allure.label:severity=critical
    ${response}=    GET Breed Images    ${RACA_INEXISTENTE}
    Validar Status Code E Status Field    ${response}    404
    Validar Response De Erro Completo    ${response}    404

CT06 - Nome de raça com caractere inválido é rejeitado pela API
    [Documentation]    Dado que envio o nome da raça com caractere inválido
    ...                Quando requiro suas imagens
    ...                Então a API deve retornar 404 indicando que o recurso não foi encontrado
    [Tags]    api    imagens    regressao    negativo    allure.label:epic=Dog API
    ...       allure.label:feature=Images    allure.label:story=Erro para nome inválido    allure.label:severity=high
    ${response}=    GET Breed Images    ${RACA_COM_CARACTERE_INVALIDO}
    Validar Status Code E Status Field    ${response}    404
    Validar Response De Erro Completo    ${response}    404

CT07 - Response de erro contém todos os campos obrigatórios
    [Documentation]    Dado que uma requisição inválida é feita
    ...                Quando a API responde com erro
    ...                Então o body deve conter 'status', 'message' e 'code'
    [Tags]    api    imagens    regressao    negativo    allure.label:epic=Dog API
    ...       allure.label:feature=Images    allure.label:story=Contrato de erro    allure.label:severity=high
    ${response}=    GET Breed Images    ${RACA_INEXISTENTE}
    Validar Response De Erro Completo    ${response}    404

CT08 - Imagem aleatória é retornada com URL válida
    [Documentation]    Dado que solicito uma imagem aleatória
    ...                Quando a API responde
    ...                Então o campo 'message' deve ser uma URL começando com 'https://'
    [Tags]    api    imagens    smoke    positivo    allure.label:epic=Dog API
    ...       allure.label:feature=Images    allure.label:story=Imagem aleatória válida    allure.label:severity=critical
    ${response}=    GET Random Image
    Validar Status Code E Status Field    ${response}    200
    Validar URL De Imagem    ${response}

CT09 - URL da imagem aleatória segue o padrão oficial da API
    [Documentation]    Dado que solicito uma imagem aleatória
    ...                Quando a API responde
    ...                Então a URL deve conter o domínio oficial 'dog.ceo'
    [Tags]    api    imagens    regressao    positivo    allure.label:epic=Dog API
    ...       allure.label:feature=Images    allure.label:story=Domínio oficial da imagem    allure.label:severity=medium
    ${response}=    GET Random Image
    Validar Status Code E Status Field    ${response}    200
    Validar URL Segue Padrao    ${response}
