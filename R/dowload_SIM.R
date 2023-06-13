#' Criar base de dados do Sistema de Informa??o de Mortalidade (SIM) do Sistema ?nico de Sa?de (SUS)
#'
#' Esta fun??o baixa arquivos .dbc do Sistema de Informa??o de Mortalidade da p?gina de microdados do Sistema ?nico de Sa?de.
#'
#' @param uf Uma string indicando a Unidade Federativa (estado) de interesse, utilizando a abreviatura de duas letras (exemplo: "SP").
#' @param periodo Um vetor com dois ou um valor(es): S?o string indicando o periodo do in?cio do intervalo das publica??es requeridas no formato "AAAA".
#' @param dir Uma string indicando o diret?rio de sa?da em que os arquivos ser?o armazenados (o padr?o ? o diret?rio criado dentro da pasta Documentos do Usu?rio).
#' @param filename Uma string indicando o nome do arquivo para o arquivo baixado (o padr?o ? constru?do com base nos par?metros de entrada do diret?rio da pasta Documentos do usu?rio).
#'
#' @return Um banco de dados no environment do RStudio
#'
#' @examples
#' \dontrun{
#' download_SIM (uf = "CE", periodo = c(1996, 2021), dir = ".", filename = NULL),
#' download_SIM (uf = c("AL", "BA", "CE", "MA", "PB", "PE", "PI", "RN", "SE"), periodo = 2021, dir = ".", filename = NULL),
#' download_SIM (uf = "CE", periodo = c(1996:2021), dir = ".", filename = NULL)
#' }
#'
#' @export

download_SIM <- function(uf, periodo, dir = ".", filename = NULL) {
  
  # Carrega pacotes ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # Carrega o pacote pacman
  if (!require(pacman)) {
    install.packages("pacman")
    library(pacman)
  }
  
  pacman::p_load(furrr, fs, curl, httr, read.dbc, foreign, data.table, tibble,
                 stringi, stringr, progressr, writexl, dplyr, openxlsx, readxl)
  
  # Transformacao dos parametros ++++++++++++++++++++++++++++++++++++
  
  # Transforma a entrada de uf em um vetor, se necess?rio
  if (!is.vector(uf)) uf <- as.vector(uf)
  
  # Transforma a entrada de periodo em um vetor, se necess?rio
  if (!is.vector(periodo)) periodo <- as.vector(periodo)
  
  # Diretorio e arquivos +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  # Define o diret?rio de destino dos arquivos baixados
  dir_destino <- file.path(dir, "SIM")
  
  # Verifica se o diret?rio de destino existe, caso contr?rio, cria o diret?rio
  if (!dir.exists(dir_destino)) {
    dir.create(dir_destino, recursive = TRUE)
    cat(paste0("O diret?rio ", dir_destino, " foi criado.\n"))
  }
  
  # Informa o diret?rio de sa?da ao usu?rio
  cat(paste0("Os arquivos ser?o salvos em: ", dir_destino, "\n"))
  
  # URL base para o site do DATASUS
  base_url <- "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DORES/"
  
  # Baixa arquivo(os) ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  # Cria uma lista para armazenar os dataframes
  df_list <- list()
  
  # Loop pelos valores de uf e periodo para baixar os arquivos correspondentes
  for (i in 1:length(uf)) {
    for (j in 1:length(periodo)) {
      
      # Verifica se a extens?o est? como .dbc ou .DBC na URL
      file_name <- stri_c("DO", uf[i], periodo[j], ".dbc")
      url <- stri_paste(base_url, file_name)
      if (identical(httr::status_code(httr::GET(url)), 200L)) {
        file_name <- file_name
      } else {
        file_name <- stri_c("DO", uf[i], periodo[j], ".DBC")
        url <- stri_paste(base_url, file_name)
        if (identical(httr::status_code(httr::GET(url)), 200L)) {
          file_name <- file_name
        }
      }
      
      # Cria conex?o com a URL e baixa o arquivo
      url <- stri_paste(base_url, file_name)
      file_name_local <- stri_replace_last_fixed(file_name, ".dbc", ".DBC")
      curl_download(url, file.path(dir_destino, file_name_local))
      
      # Leitura e salvamento +++++++++++++++++++++++++++++++++++++++++++++++++++
      
      # L? o arquivo e salva em um dataframe
      cat(paste0("Lendo o arquivo ", file_name, "\n"))
      file_path <- file.path(dir_destino, file_name)
      file_ext <- tools::file_ext(file_path)
      if (file_ext == "dbf") {
        file_df <- foreign::read.dbf(gzfile(file_path))
      } else if (file_ext == "dbc" | file_ext == "DBC") {
        file_df <- read.dbc(file_path)
      } else {
        stop(paste0("O arquivo ", file_name, " n?o est? no formato DBC ou DBF."))
      }
      
      # Define o nome do dataframe como referente ao per?odo
      df_name <- stri_c("DO", uf[i], periodo[j])
      df_list[[df_name]] <- file_df
      
      # Salva o dataframe em um arquivo Excel
      cat(paste0("Salvando o arquivo ", df_name, ".xlsx\n"))
      excel_path <- file.path(dir_destino, stri_c(df_name, ".xlsx"))
      openxlsx::write.xlsx(file_df, file = excel_path, sheetName = "Sheet1")
      
      # Remove o arquivo .DBC baixado
      file.remove(file.path(dir_destino, file_name_local))
    }
  }
  
  # Juntar os bancos de dados em um s?
  SIM <- data.table::rbindlist(df_list)
  
  # Verifica se o dataframe existe
  if (nrow(SIM) == 0) {
    stop("Nenhum dado encontrado. Verifique os par?metros uf e periodo.")
  }
  
  # Adiciona as colunas de UF e periodo
  SIM$UF <- rep(uf, each = length(periodo))
  SIM$ANO <- rep(periodo, times = length(uf))
  
  # Tratamento dos dados +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  # Removendo coluna contador
  SIM =
    SIM %>%
    select(-CONTADOR)
  
  # Substituir somente o segundo "*" por "|"
  for (coluna in colnames(SIM)) {
    if (grepl("^LINHA", coluna)) {
      SIM[[coluna]] <- gsub("^(.*?\\*.*?\\*)", "\\1|", SIM[[coluna]])
    }
  }
  
  # Substituir o restante dos "*"
  for (coluna in colnames(SIM)) {
    SIM[[coluna]] <- gsub("\\*", "", SIM[[coluna]])
  }
  
  # Inserindo arquivos externos para descodificação ++++++++++++++++++++++++++++
  
  # Importar os arquivos XLSX para juntar ao SIM
  # Identifica o caminho do pacote
  # Adiciona a pasta de arquivos que contém CBO, CID e Municipios
  caminho_pasta <- system.file("Arquivos_externos", package = "PaineisPublicos")
  
  # Obtém a lista de arquivos na pasta
  arquivos <- list.files(caminho_pasta)
  
  # Criar uma lista para armazenar os dados dos arquivos XLSX
  dados_xlsx <- list()
  
  # Instale o pacote readxl, se ainda não estiver instalado
  if (!requireNamespace("readxl", quietly = TRUE)) {
    install.packages("readxl")
  }
  library(readxl)
  
  # Itera sobre cada arquivo e realiza a leitura dos arquivos .xlsx
  for (arquivo in arquivos) {
    caminho_arquivo <- file.path(caminho_pasta, arquivo)
    
    # Verifica se o arquivo possui a extensão .xlsx e não começa com ~$
    
    if (grepl("\\.xlsx$", arquivo, ignore.case = TRUE)) {
      # Realiza a leitura do arquivo usando read_excel
      dados_xlsx[[arquivo]] <- read_excel(caminho_arquivo)
    }
  }
  
  # Os dataframes CBO, CID e municipio serão usados somente no Power BI,
  #já que o merge utiliza mais do que o disponível de memória do R
  CBO = dados_xlsx$CBO.xlsx
  CID = dados_xlsx$CID.xlsx
  Municipio = dados_xlsx$Municipios
  Descricao = dados_xlsx$Descricao.xlsx
  rm(dados_xlsx)
  
  # Convertendo todas as colunas de Descricao para caracteres
  Descricao = dplyr::mutate_all(Descricao, as.character)
  
  # Identificar colunas do SIM e Descricao que n?o possuem prefixo IDADE ou PESO
  colunas_substituir <- colnames(SIM)[!(grepl("^IDADE", colnames(SIM)) | grepl("^PESO", colnames(SIM)))]
  colunas_descricao <- paste0(colunas_substituir, "_DESC")
  
  for (coluna in colunas_substituir) {
    coluna_descricao <- paste0(coluna, "_DESC")
    if (coluna_descricao %in% colnames(Descricao)) {
      if (coluna %in% c("IDADE", "IDADEMAE", "PESO")) {
        next  # Ignorar as colunas IDADE, IDADEMAE e PESO
      } else {
        indices <- tryCatch(
          match(SIM[[coluna]], Descricao[[coluna]]),
          error = function(e) NULL
        )
        
        if (!is.null(indices)) {
          indices <- indices[!is.na(indices) & !is.na(SIM[[coluna]])]  # Remover NA
          
          if (length(indices) > 0) {
            suppressWarnings({
              SIM[[coluna]][!is.na(SIM[[coluna]])] <- Descricao[[coluna_descricao]][indices]
            })
          }
        }
      }
    }
  }
  
  # Transformar as colunas de IDADE, IDADEMAE e PESO de acordo com os intervalos definidos em Descricao
  
  # Substituir os valores de IDADE em SIM pelos intervalos em Descricao
  SIM$IDADE <- cut(as.numeric(SIM$IDADE), c(as.numeric(Descricao$IDADE1), Inf), labels = Descricao$Desc_IDADE, right = FALSE)
  
  # Substituir os valores de IDADEMAE em SIM pelos intervalos em Descricao
  SIM$IDADEMAE <- cut(as.numeric(SIM$IDADEMAE), c(as.numeric(Descricao$IDADEMAE1), Inf), labels = Descricao$IDADEMAE_DESC, right = FALSE)
  
  # Substituir os valores de PESO em SIM pelos intervalos em Descricao
  SIM$PESO <- cut(as.numeric(SIM$PESO), c(as.numeric(Descricao$PESO1), Inf), labels = Descricao$PESO_DESC, right = FALSE)
  
  # adicionando coluna para contar a quantidade de óbitos
  SIM =
    SIM %>%
    mutate(`Óbitos` = 1)
  
  # Identificar e transformar colunas com prefixo DT em formato YYY-mm-dd
  for (coluna in colnames(SIM)) {
    if (grepl("^DT", coluna)) {
      SIM[[coluna]] <- as.Date(SIM[[coluna]], format = "%d%m%Y")
      SIM[[coluna]] <- format(SIM[[coluna]], "%Y-%m-%d")
    }
  }
  
  # Transformar a coluna HORAOBITO em formato HH:MM
  SIM$HORAOBITO <- format(as.POSIXct(SIM$HORAOBITO, format = "%H%M"), "%H:%M")
  
  # Transformar todos os NA do SIM em "Sem Informação", exceto nas linhas em que TIPOBITO for "Óbito fetal"
  SIM = SIM %>%
    mutate(across(everything(), ~ ifelse(is.na(.) & TIPOBITO != "Óbito fetal", "Sem Informação", .)))
  
  # Define o caminho do arquivo
  caminho_arquivo <- file.path("SIM", "SIM.RData")
  
  # Salva o arquivo RData
  save.image(file = caminho_arquivo)
}
