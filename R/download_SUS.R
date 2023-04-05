#' Baixar arquivos da base de dados do Sistema Único de Saúde (SUS)
#'
#' Esta função baixa arquivos .dbc da página de microdados do Sistema Único de Saúde (SUS).
#'
#' @param uf Uma string indicando a Unidade Federativa (estado) de interesse, utilizando a abreviatura de duas letras (exemplo: "SP").
#' @param periodo Uma lista com duas opções: "inicio" e "fim". "inicio" é uma string indicando o ano e mês do início do intervalo das publicações requeridas no formato "AAAAmm". "fim" é uma string indicando o ano e mês do fim do intervalo das publicações requeridas no formato "AAAAmm" (opcional).
#' @param informacao Uma string indicando o Sistema de Informação desejado (exemplo: "SINAN").
#' @param tipo Uma string indicando o tipo de dado selecionado ("PA", "RD","RJ","ER","SP").
#' @param dir Uma string indicando o diretório de saída em que os arquivos serão armazenados (o padrão é o diretório de trabalho atual).
#' @param filename Uma string indicando o nome do arquivo para o arquivo baixado (o padrão é construído com base nos parâmetros de entrada).
#'
#' @return Uma lista de strings indicando o caminho para cada arquivo baixado.
#' @export
#'
download_SUS <- function(uf, periodo, informacao, tipo, dir = ".", filename = NULL) {

  # Carrega pacotes necessários
  pacotes <- c("read.dbc", "stringr", "dplyr", "httr")
  for(pacote in pacotes){
    if (!requireNamespace(pacote, quietly = TRUE)) {
      install.packages(pacote)
      library(pacote, character.only = TRUE)
    }
  }

    # Verifica o formato do período
    if (is.character(periodo)) {
      periodo <- strsplit(periodo, ":")
      periodo <- periodo[[1]]
      if (length(periodo) == 1) {
        periodo <- c(periodo, periodo)
      }
    } else if (is.list(periodo)) {
      if (!all(c("inicio", "fim") %in% names(periodo))) {
        stop("O período deve ser uma lista com duas opções: 'inicio' e 'fim'.")
      }
      periodo <- as.character(unlist(periodo))
    } else if (length(periodo) == 1) {
      periodo <- c(periodo, periodo, periodo)
    } else if (length(periodo) != 2) {
      stop("O período deve ser uma lista com duas opções: 'inicio' e 'fim'.")
    }

    # Constrói as datas iniciais e finais
    inicio <- periodo[1]
    fim <- periodo[2]
    datas <- seq(as.Date(paste0(inicio, "01"), format = "%Y%m%d"), as.Date(paste0(fim, "01"), format = "%Y%m%d"), by = "month")
    periodos <- format(datas, "%Y%m")

      # Constrói a URL base para o site do DATASUS
      base_url <- "ftp://ftp.datasus.gov.br/dissemin/publicos/"

      # Verifica se o parâmetro informacao é válido e constrói o caminho da URL
      caminho <- switch(informacao,
                        "ANS" = "ANS/",
                        "CIH" = "CIH/",
                        "CIHA" = "CIHA/",
                        "CMD" = "CMD/",
                        "CNES" = "CNES/",
                        "CPI" = "CPI/",
                        "EXTR ESP" = "EXTR%20ESP/",
                        "IBGE" = "IBGE/",
                        "painel oncologia" = "painel oncologia/",
                        "PCE" = "PCE/",
                        "Pesquisas" = "Pesquisas/",
                        "PNI" = "PNI/",
                        "RESP" = "RESP/",
                        "SIASUS" = "SIASUS/",
                        "SIHSUS" = "SIHSUS/",
                        "SIM" = "SIM/",
                        "SINAN" = "SINAN/",
                        "SINASC" = "SINASC/",
                        "siscan" = "siscan/",
                        "SISPRENATAL" = "SISPRENATAL/")

      # Constrói a URL para cada arquivo solicitado
      padrao_url <- "%s%s%s_%s.dbc"
      periodo <- as.character(unlist(periodo))
      urls <- sprintf(padrao_url, base_url, caminho, tipo, periodo)

      # Verifica se o caminho da URL contém "DADOS/", "2008/DADOS/", "2008_01/DADOS/" ou "DADOS/FINAIS/" após o parâmetro informacao ser igual ao do caminho no site
      caminhos_permitidos <- c("200801_201012/Dados/", "200801_201012/dados2/",
                               "201101_/Dados",
                               "Dados/", "DadosSISAB/", "201701_/Dados/",
                               "200508_/Dados/",
                               "199407_200712/Dados/", "200801_/Dados/",
                               "199201_200712/Dados/", "200801_/Dados/", "Arquivos_MTBR/", "MHJ_14_16/",
                               "DOFET/", "DORES/", "DOIGN/", "PRELIM/DOFET/", "PRELIM/DORES/", "PRELIM19/DOFET/", "PRELIM19/DORES/", "PRELIM20/DOFET/", "PRELIM20/DORES/", "PRELIM2017/DOFET/", "PRELIM2017/DORES/", "PRELIM2018/DOFET/", "PRELIM2018/DORES/",
                               "DADOS/FINAIS/", "PRELIM/",
                               "1994_1995/Dados/DNIGN/", "1994_1995/Dados/DNRES/", "1996_/Dados/DNRES/", "ANT/DNIGN/", "ANT/DNRES/", "NOV/DNRES/", "PRELIM/DNRES/", "PRELIM19/DNRES/", "PRELIM20/DNRES/", "PRELIM2017/DNRES/",
                               "SISCOLO4/DADOS/", "SISMAMA/DADOS/",
                               "201201_/Dados/",
                               "DADOS/", "2008/DADOS/", "2008_01/DADOS/", "DADOS/FINAIS/")
      if(!any(sapply(caminhos_permitidos, function(caminho) str_detect(urls[1], sprintf("/%s%s_", informacao, caminho))))) {
        stop("A URL informada não contém um caminho válido.")
      }

      # Realiza o download dos arquivos .dbc
      for(url in urls) {
        filename <- basename(url)
        download.file(url, destfile = filename, mode = "wb")
      }
}
