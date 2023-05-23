library(openxlsx)
library(fuzzyjoin)
library(dplyr)

# Defina o diretório de trabalho para a pasta que contém os arquivos
setwd("C:/Users/estelalopes.huwc/Downloads")

# Leia o dataframe "PerfilOcupacional.xlsx" separadamente
PerfilOcupacional <- read.xlsx("PerfilOcupacional.xlsx")

# Converter todas as colunas de PerfilOcupacional para caracteres
PerfilOcupacional <- as.data.frame(lapply(PerfilOcupacional, as.character), stringsAsFactors = FALSE)

# Defina a lista de nomes de arquivos
arquivos <- c("Familia.xlsx", "Grande_Grupo.xlsx", "SubGrupo_Principal.xlsx", "Ocupacao.xlsx", "Sinonimo.xlsx", "SubGrupo.xlsx")

# Defina os nomes das colunas-chave correspondentes em cada arquivo
colunas_chave <- list(
  c("COD_FAMILIA", "FAMILIA"),
  c("COD_GRANDE_GRUPO", "GRANDE_GRUPO"),
  c("COD_SUBGRUPO_PRINCIPAL", "SUBGRUPO_PRINCIPAL"),
  c("COD_OCUPACAO", "OCUPACAO"),
  c("COD_OCUPACAO", "SINONIMO"),
  c("COD_SUBGRUPO", "SUBGRUPO")
)

# Carregue os dataframes em uma lista
CBO <- lapply(arquivos, function(arquivo) {
  df <- read.xlsx(arquivo)
  
  # Transforme as colunas double em caracteres
  double_cols <- sapply(df, is.double)
  for (col in names(double_cols)[double_cols]) {
    df[, col] <- as.character(df[, col])
  }
  
  # Atribua os nomes das colunas-chave aos dataframes correspondentes
  colnames(df) <- colunas_chave[[which(arquivos == arquivo)]]
  df
})

# Use a função Reduce() com a função fuzzy_inner_join() para mesclar os dataframes um por um no dataframe "PerfilOcupacional"
for (i in seq_along(CBO)) {
  merged <- fuzzy_inner_join(PerfilOcupacional, CBO[[i]], by = setNames(colunas_chave[[i]][2], colunas_chave[[i]][1]), match_fun = list(`==`, `==`)) %>%
    select(names(PerfilOcupacional), names(CBO[[i]]))
  PerfilOcupacional <- merged
}

# Salve o resultado em um novo arquivo .xlsx
write.xlsx(PerfilOcupacional, "CBO.xlsx", row.names = FALSE)
