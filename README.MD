# Desafio SouthSystem

[![API Tests](https://github.com/renatosantanaoliveira/desafio-southsystem/actions/workflows/api-tests.yml/badge.svg)](https://github.com/renatosantanaoliveira/desafio-southsystem/actions/workflows/api-tests.yml)
[![Web Tests](https://github.com/renatosantanaoliveira/desafio-southsystem/actions/workflows/web-tests.yml/badge.svg)](https://github.com/renatosantanaoliveira/desafio-southsystem/actions/workflows/web-tests.yml)

Projeto de automação de testes com duas camadas independentes:

- Web: testes end-to-end do fluxo de busca no blog
- API: testes de contrato e comportamento sobre a Dog API

O objetivo da estrutura é demonstrar organização por domínio, execução local simples, integração com Allure Report e pipelines dedicados no GitHub Actions.

## Visão Geral

### Camada Web
- Tecnologia: Robot Framework + Browser Library (Playwright)
- Objetivo: validar o comportamento da busca do usuário final
- Escopo atual:
  - busca com termo válido
  - busca com termo inexistente
  - abertura do primeiro artigo retornado
  - robustez com acentuação e caracteres especiais

### Camada API
- Tecnologia: Robot Framework + RequestsLibrary
- Objetivo: validar endpoints públicos da Dog API
- Escopo atual:
  - listagem de raças
  - validação de sub-raças
  - consulta de imagens por raça
  - contrato de erro
  - imagem aleatória

## Estrutura Do Projeto

```text
.
├── api-tests/
│   ├── resources/
│   │   ├── config/
│   │   ├── api_config.resource
│   │   └── dog_api_keywords.resource
│   └── tests/
│       ├── breeds_test.robot
│       └── images_test.robot
├── web-tests/
│   ├── resources/
│   │   ├── busca/
│   │   └── config/
│   └── tests/
│       └── busca.robot
├── .github/workflows/
│   ├── api-tests.yml
│   └── web-tests.yml
└── requirements.txt
```

## Decisões De Arquitetura

- Separação por camada de teste: web e API possuem suites, resources e pipelines próprios.
- Separação por domínio funcional:
  - API dividida em `breeds` e `images`
  - Web organizada por funcionalidade de busca
- Configuração externa por ambiente:
  - Web usa arquivos em `web-tests/resources/config/`
  - API usa arquivos em `api-tests/resources/config/`
- Relatórios em dois níveis:
  - Robot Framework para evidência operacional
  - Allure Report para visualização executiva dos resultados

## Pré-Requisitos

- Python 3.11+
- pip
- Allure CLI

Instalação das dependências Python:

```bash
python3 -m pip install -r requirements.txt
```

Para a suíte web, inicialize os navegadores da Browser Library:

```bash
rfbrowser init chromium
```

## Configuração De Ambiente

### Web

A suíte web suporta seleção de ambiente por variável `ENV`.

- `ENV=dev` é o padrão
- arquivos disponíveis:
  - `web-tests/resources/config/dev.yaml`
  - `web-tests/resources/config/qa.yaml`
  - `web-tests/resources/config/prod.yaml`

Variáveis de execução:

- `ENV`: seleciona o arquivo de configuração
- `BROWSER`: `chromium`, `firefox` ou `webkit`
- `HEADLESS`: `True` ou `False`

### API

A suíte de API também suporta seleção de ambiente por variável `ENV`.

- `ENV=dev` é o padrão
- arquivos disponíveis:
  - `api-tests/resources/config/dev.yaml`
  - `api-tests/resources/config/qa.yaml`
  - `api-tests/resources/config/prod.yaml`

Variáveis de execução:

- `ENV`: seleciona o arquivo de configuração da API

## Execução Local

### Testes Web

Executar a suíte completa:

```bash
robot --listener allure_robotframework:allure-results --outputdir results web-tests/tests/
```

Executar por tag:

```bash
robot --listener allure_robotframework:allure-results --include regressao --outputdir results web-tests/tests/
```

Executar sem headless:

```bash
robot --variable HEADLESS:False --listener allure_robotframework:allure-results --outputdir results web-tests/tests/
```

Executar em ambiente específico:

```bash
robot --variable ENV:qa --listener allure_robotframework:allure-results --outputdir results web-tests/tests/
```

### Testes De API

Executar a suíte completa:

```bash
robot --listener allure_robotframework:allure-results --outputdir results api-tests/tests/
```

Executar por tag:

```bash
robot --listener allure_robotframework:allure-results --include smoke --outputdir results api-tests/tests/
```

Executar em ambiente específico:

```bash
robot --variable ENV:qa --listener allure_robotframework:allure-results --outputdir results api-tests/tests/
```

## Relatórios

Após a execução com listener do Allure:

- Robot Framework gera:
  - `results/log.html`
  - `results/report.html`
  - `results/output.xml`
- Allure gera:
  - `allure-results/`

Abrir rapidamente no Allure:

```bash
allure serve allure-results
```

Gerar relatório persistente:

```bash
allure generate allure-results -o allure-report --clean
allure open allure-report
```

## Integração Contínua

O projeto possui pipelines separados por camada:

- Web: [`.github/workflows/web-tests.yml`](./.github/workflows/web-tests.yml)
- API: [`.github/workflows/api-tests.yml`](./.github/workflows/api-tests.yml)

### O que cada pipeline faz

1. Instala dependências Python
2. Executa a suíte Robot Framework
3. Publica artefatos do Robot
4. Gera o Allure Report
5. Publica artefatos do Allure

Na suíte web, o pipeline também inicializa o Browser Library com Playwright.

## Cobertura Atual

### Web
- Busca com retorno positivo
- Busca sem resultados
- Navegação para artigo a partir da busca
- Robustez para entrada com caracteres especiais

### API
- Contrato básico de sucesso
- Estrutura de listagem de raças
- Presença de sub-raças conhecidas
- Raça sem sub-raças
- Lista de imagens por raça
- Contrato de erro para entradas inválidas
- Validação de URL de imagem aleatória
