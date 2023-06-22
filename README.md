
# Pacote de Paineis Públicos

Este repositório contém um pacote R chamado "PaineisPublicos" que fornece funções para acessar e tratar dados do DATASUS (Departamento de Informática do Sistema Único de Saúde) e atualizar os modelos de painéis do Power BI correspondentes, tudo de forma automatizada.

## Visão Geral

O pacote "PaineisPublicos" foi criado para simplificar e agilizar o processo de obtenção de dados do DATASUS, tratamento desses dados e atualização dos modelos de painéis do Power BI. Com o uso deste pacote, os usuários podem automatizar essas tarefas e economizar tempo precioso.

Para acessar o painel, acesse pelo link ou QR code
<p align="center">
  <a href="https://aka.ms/AAlagzv">Painel do Sistema de Informações de Óbito</a>
</p>

<p align="center">
  <img src="inst/Arquivos_externos/[Modelo]Painel.jpg" alt="Imagem">
</p>

## Funcionalidades

O pacote "PaineisPublicos" possui as seguintes funcionalidades principais:

1. Acesso aos dados do DATASUS: O pacote permite que os usuários acessem diretamente os dados do DATASUS por meio de funções específicas. Essas funções facilitam a consulta e extração dos dados necessários para a atualização dos painéis.

2. Tratamento de dados: Uma vez que os dados são obtidos do DATASUS, o pacote fornece funções para tratar esses dados. Isso inclui limpeza, transformação e organização dos dados, garantindo que eles estejam prontos para serem utilizados nos modelos de painéis do Power BI.

3. Atualização dos modelos de painéis do Power BI: O pacote automatiza o processo de atualização dos modelos de painéis do Power BI. Ele se integra perfeitamente com o Power BI e permite que os usuários atualizem os dados e os gráficos dos painéis com apenas alguns comandos.

## Como usar o pacote

Para começar a utilizar o pacote "PaineisPublicos", siga as etapas abaixo:

1. Instale o pacote: 

``` r
install.packages("remotes")
remotes::install_github("SwagNoirE/PaineisPublicos")
```
2. Carregue o pacote: Utilize o comando `library(PaineisPublicos)` para carregar o pacote em seu ambiente R.

3. Acesse os dados do DATASUS: Utilize as funções fornecidas pelo pacote para acessar e extrair os dados do DATASUS que você deseja utilizar em seus painéis do Power BI.

4. Compile a função com as informações de parâmetros desejados: As funções do pacote Baixam os dados do Sistema de Informação solicitada, trata os dados, realizando limpezas, transformações e organização conforme necessário para a base estar legível para se transformar em informações úteis no painel.

5. Atualize os modelos de painéis do Power BI: As funções abrirão automaticante o executável do PowerBI, onde você precisará apenas atualizar o painel, pois o modelo está pronto para visualização.

## Exemplo

``` r
library(PaineisPublicos)
download_SIM(uf = "CE", periodo = (2019:2021))
```

## Contribuindo

Se você quiser contribuir para o desenvolvimento do pacote "PaineisPublicos", fique à vontade para fazer um fork deste repositório e enviar pull requests com suas melhorias. Sua contribuição será muito apreciada!

## Problemas e Feedback

Se você encontrar algum problema ao utilizar o pacote "PaineisPublicos" ou tiver alguma sugestão de melhoria, por favor, abra uma issue neste repositório. Faremos o possível para resolver os problemas e atender às suas necessidades.

## Aviso Legal



Este pacote "PaineisPublicos" é fornecido sem garantia de qualquer tipo. Utilize por sua própria conta e risco.

## Licença

O pacote "PaineisPublicos" é distribuído sob a licença MIT. Consulte o arquivo `LICENSE` para obter mais informações.

## Contato

Para mais informações ou perguntas relacionadas a este pacote, entre em contato com o desenvolvedor:

Nome: [Estela Ferreira LOpes]
Email: [estelalopes2002@gmail.com]
