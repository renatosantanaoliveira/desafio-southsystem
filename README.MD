# Desafio SouthSystem

## Pré-requisitos
- Python 3.11+
- pip
- rfbrowser (Robot Framework Browser)
- Allure CLI (para geração do relatório)

## Instalação
```bash
python3 -m pip install -r requirements.txt
rfbrowser init chromium
```

## Configuração do ambiente
O projeto suporta multiplos ambientes por arquivo de variaveis.

- `ENV` define qual ambiente carregar: `dev`, `qa` ou `prod`
- `HEADLESS` controla execucao visual ou headless
- `BROWSER` define `chromium`, `firefox` ou `webkit`

Arquivos de ambiente:
- `web-tests/resources/config/dev.yaml`
- `web-tests/resources/config/qa.yaml`
- `web-tests/resources/config/prod.yaml`

## Como executar
### Todos os testes
```bash
robot --listener allure_robotframework:allure-results --outputdir results web-tests/tests/
```

### Por criticidade
Filtragem por tags exemplo:
```bash
robot --listener allure_robotframework:allure-results --include regressao --outputdir results web-tests/tests/
```

### Executar sem headless (visual)
```bash
robot --variable HEADLESS:False --listener allure_robotframework:allure-results --outputdir results web-tests/tests/
```

### Executar em ambiente especifico
```bash
robot --variable ENV:qa --listener allure_robotframework:allure-results --outputdir results web-tests/tests/
```

## Estrutura do projeto
- `web-tests/tests/`: suites Robot
- `web-tests/resources/busca/`: keywords e variaveis da funcionalidade
- `web-tests/resources/config/`: configuracoes por ambiente
- `.github/workflows/web-tests.yml`: execucao CI com artefatos Robot e Allure

## Relatórios
- Relatórios Robot: `results/log.html`, `results/report.html`, `results/output.xml`
- Allure: os testes geram `allure-results/`
- Abrir rapidamente: `allure serve allure-results`
- Gerar relatorio persistente: `allure generate allure-results -o allure-report --clean`
- Abrir relatorio gerado: `allure open allure-report`

## Decisões de arquitetura
- Robot Framework + Browser Library (Playwright)
- Page Object via resources em `web-tests/resources/`
- Configuracao externa por ambiente para facilitar execucao local e em pipeline
- Captura de screenshot com thumbnail no `log.html` em caso de falha
