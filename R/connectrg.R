#' Conectar o R ao Github
#'
#'  Função que conecta o R ao Github para inserir algo no repositório
#'
#' @param username Nome do usuário do Github como character
#'  @param token Token de acesso pessoal do Github como character
#'  @param repo_name Nome do repositório do Github como character
#'
#' @return Uma lista do Github token
#' @export
#'
connectrg <- function(username, token, repo_name) {

  # Carrega pacotes necessários
  pacotes <- c("httr", "git2r")
  for(pacote in pacotes){
    if (!requireNamespace(pacote, quietly = TRUE)) {
      install.packages(pacote)
      library(pacote, character.only = TRUE)
    }
  }

  # Definir o URL do repositório com as credenciais
  repo_url <- paste0("https://", username, ":", token, "@github.com/", username, "/", repo_name)

  # Clonar o repositório para o ambiente de trabalho local
  clone(repo_url)
}

