#' Criar base de dados do Sistema de Informação de Mortalidade (SIM) do Sistema Único de Saúde (SUS)
#'
#' Esta função baixa arquivos .dbc do Sistema de Informação de Mortalidade da página de microdados do Sistema Único de Saúde.
#'
#' @param uf Uma string indicando a Unidade Federativa (estado) de interesse, utilizando a abreviatura de duas letras (exemplo: "SP").
#' @param periodo Um vetor com dois ou um valor(es): São string indicando o periodo do início do intervalo das publicações requeridas no formato "AAAA".
#' @param dir Uma string indicando o diretório de saída em que os arquivos serão armazenados (o padrão é o diretório criado dentro da pasta Documentos do Usuário).
#' @param filename Uma string indicando o nome do arquivo para o arquivo baixado (o padrão é construído com base nos parâmetros de entrada do diretório da pasta Documentos do usuário).
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
  
  # Carrega pacotes +++++++++++++++++++++++++++++++++++++++++++++++++
  # Carrega o pacote pacman
  if (!require(pacman)) {
    install.packages("pacman")
    library(pacman)
  }
  
  pacman::p_load(furrr, fs, curl, httr, read.dbc, foreign, data.table, tibble, stringi, stringr, progressr, writexl, dplyr, openxlsx)
  
  # Transformacao dos parametros ++++++++++++++++++++++++++++++++++++
  
  # Transforma a entrada de uf em um vetor, se necessário
  if(!is.vector(uf)) uf <- as.vector(uf)
  
  # Transforma a entrada de periodo em um vetor, se necessário
  if(!is.vector(periodo)) periodo <- as.vector(periodo)
  
  # Diretorio e arquivos ++++++++++++++++++++++++++++++++++++++++++++
  
  # Define o diretório de destino dos arquivos baixados
  dir_destino <- file.path(dir, "SIM")
  
  # Cria o diretório de destino, se necessário
  if (!dir.exists(dir_destino)) dir.create(dir_destino, recursive = T)
  
  # Informa o diretório de saída ao usuário
  cat(paste0("Os arquivos serão salvos em: ", dir_destino, "\n"))
  
  # URL base para o site do DATASUS
  base_url <- "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DORES/"
  
  # Baixa arquivo(os) +++++++++++++++++++++++++++++++++++++++++++++++
  
  # Cria um data.table vazio para armazenar os dados
  SIM <- data.table()
  
  # Loop pelos valores de uf e periodo para baixar os arquivos correspondentes
  for(i in 1:length(uf)){
    for(j in 1:length(periodo)){
      
      # Verifica se a extensão está como .dbc ou .DBC na URL
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
      
      # Cria conexão com a URL e baixa o arquivo
      url <- stri_paste(base_url, file_name)
      file_name_local <- stri_replace_last_fixed(file_name, ".dbc", ".DBC")
      curl_download(url, file.path(dir_destino, file_name_local))
      
      # Leitura e salvamento ++++++++++++++++++++++++++++++++++++++++++
      
      # Lê o arquivo e salva em um dataframe
      cat(paste0("Lendo o arquivo ", file_name, "\n"))
      file_path <- file.path(dir_destino, file_name)
      file_ext <- tools::file_ext(file_path)
      if (file_ext == "dbf") {
        file_df <- foreign::read.dbf(gzfile(file_path))
      } else if (file_ext == "dbc" | file_ext == "DBC") {
        file_df <- read.dbc(file_path)
      } else {
        stop(paste0("O arquivo ", file_name, " não está no formato DBC ou DBF."))
      }
      
      # Define o nome do dataframe como referente ao período
      df_name <- stri_c(uf[i], "_", periodo[j])
      assign(df_name, file_df)
      
      # Salva o dataframe em um arquivo Excel
      cat(paste0("Salvando o arquivo ", df_name, ".xlsx\n"))
      excel_path <- file.path(dir_destino, stri_c(df_name, ".xlsx"))
      openxlsx::write.xlsx(file_df, file = excel_path, sheetName = "Sheet1")
    }
    
    
    # Verifica se o dataframe existe
    if (!exists(df_name)) {
      stop(paste0("O dataframe ", df_name, " não existe."))
    }
    
    # Adiciona as colunas de UF e periodo
    file_df$UF <- uf[i]
    file_df$ANO <- periodo[j]
    
    # Remove o arquivo .dbc baixado
    file.remove(file.path(dir_destino, file_name_local))
    
  }
  
  
  #Juntar os bancos de dados em um só
  SIM <- as.data.frame(t((do.call(rbind, file_df))))
  
  # Retorna o data.table final
  assign("SIM", SIM, envir = .GlobalEnv)
  invisible(SIM)
  
  # adicionando coluna para contar a quantidade de óbitos
  
  SIM = 
    SIM %>%
    mutate(`Óbitos` = 1)
  
  # Importar os arquivos XLSX para juntar ao SIM
  # Identifica o caminho do pacote
  caminho_pacote <- system.file(package = "PaineisPublicos")
  # Adiciona a pasta de arquivos que contém CBO, CID e Municipios
  caminho_pasta <- stringi::stri_c(caminho_pacote, "/Arquivos_externos")
  
  # Obtém a lista de arquivos na pasta
  arquivos <- list.files(caminho_pasta)
  
  # Criar uma lista para armazenar os dados dos arquivos XLSX
  dados_xlsx <- list()
  
  # Itera sobre cada arquivo e realiza a leitura
  for (arquivo in arquivos) {
    caminho_arquivo <- file.path(caminho_pasta, arquivo)
    
    # Realiza a leitura do arquivo
    dados_xlsx[[arquivo]] <- read.xlsx(caminho_arquivo)
  }
  
  # Realizar o left join com o dataframe SIM
  for (nome_arquivo in names(dados_xlsx)) {
    if (nome_arquivo == "municipio") {
      # Realize o left join
      SIM <- merge(SIM, dados_xlsx[[nome_arquivo]], by.x = c("CODMUNRES", "CODMUNNATU", "CODMUNOCOR"), by.y = c("codigo_ibge", "codigo_ibge", "codigo_ibge"), all.x = TRUE)
    } else if (nome_arquivo == "CBO") {
      # Realize o left join
      SIM <- merge(SIM, dados_xlsx[[nome_arquivo]], by.x = c("OCUP", "OCUPMAE"), by.y = c("COD_OCUPACAO", "COD_OCUPACAO"), all.x = TRUE)
    } else if (nome_arquivo == "CID") {
      # Realize o left join
      SIM <- merge(SIM, dados_xlsx[[nome_arquivo]], by.x = c("ATESTADO", "CAUSAMAT", "CB_PRE", "CAUSABAS_O", "CAUSABAS", "LINHAA", "LINHAB", "LINHAC", "LINHAD", "LINHAAII"), by.y = c("CID", "CID", "CID", "CID", "CID", "CID", "CID", "CID", "CID", "CID"), all.x = TRUE)
    } else {
      warning(paste("As colunas de junção não estão presentes em", nome_arquivo))
    }
  }
  
  # Exemplo de uso do dataframe SIM após o left join
  print(SIM)
  
  # Salvar como .RData
  caminho_arquivo <- paste(dir_destino, "SIM.Rdata", sep = "/")
  save.image(dir_destino)
  
}