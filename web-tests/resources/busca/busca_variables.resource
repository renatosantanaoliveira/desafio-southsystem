*** Variables ***
${ENV}                dev
${BASE_URL}           https://blogdoagi.com.br
${ENV_NAME}           local
@{SEARCH_ICON_SELECTORS}
...    css=button[aria-label="Pesquisar"]
...    css=button[aria-label="Search"]
...    css=a.slide-search.astra-search-icon
...    css=.search-toggle
...    css=.search-button
${SEARCH_INPUT}       css=input[name="s"]
${RESULTS_CONTAINER}  css=#content
@{FIRST_RESULT_LINK_SELECTORS}
...    css=#content article h2 a
...    css=#content article a[href]
${NO_RESULTS_MSG}     Lamentamos, mas nada foi encontrado para sua pesquisa, tente novamente com outras palavras.
${BROWSER}           chromium
${HEADLESS}          True
