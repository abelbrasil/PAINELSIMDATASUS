
#' PainéisPúblicos
#'

# Configurar o git (apenas 1 vez por computador)

#usethis::use_git_config(user.name = "SwagNoirE", # Seu nome
#                        user.email = "estelaflopes2020@alu.ufc.br") # Seu email
# Configure no git

#$ git config --global user.name "SwagNoirE"

#$ git config --global user.email estelaflopes2020@alu.ufc.br

# Configurando github+rstudio

#create_github_token()
#edit_r_environ() #Abra o arquivo .Renviron

#Crie uma nova linha na forma GITHUB_PAT=SEU_TOKEN, adicione o token, pule uma linha e salve o arquivo

#Reinicie o RStudio: CTRL + SHIFT + F10

# Agora é só clonar um repositório do github
#No RStudio, crie um novo projeto: File > New Project
#Na aba "Create Project", selecione a opção Version Control.
#Na aba "Create Project from Version Control", selecione a opção Git.
#Repository URL: Cole o link para o repositório
#Project directory name: Após inserir o repository URL, esse campo será preenchido automaticamente.
#Create project as subdirectory of: Selecione o diretório onde você deseja manter sua cópia local do repositório.
#O RStudio irá fazer o clone do repositório, e abrirá um RProj para ele (caso não exista um ainda, será criado).

# Ou criando um repositório novo diretamente do RStudio
#Vamos usar a função create_project()
#Cria um projeto .Rproj
#Argumento importante: path = É o "caminho" para o diretório (pasta). Se o diretório já existe, é utilizado. Se não existe, é criado.
#Cuidado com o nome do projeto, pois será o mesmo nome que será utilizado no repositório. Você não deve usar o nome de algum repositório já existente no seu GitHub.

# Criando um projeto

#create_project("PATH")








# Pactes principais para criar um pacote do R

library(devtools)
library(httr)
library(rlang)
library(jsonlite)

# Criar o escopo para o pacote

#create_package("X:/PATH/PaineisPublicos")

# Criação da primeira função

use_r("connectrgb")

use_r("download_SUS")

use_r("connectrg")

use_r("teste")


# Utilizando o git para submissão
use_git()
use_github()
#O arquivo README é a página inicial do pacote no GitHub
#use_readme_rmd()
#build_readme()
# Para divulgar as alterações feitas
#use_news_md()
# Numeração e atualização dela no arquivo desription
#use_version()
#major –> 1.0.0 - incrementa o primeiro número
#minor –> 0.1.0 - incrementa o segundo número
#patch –> 0.0.1 - incrementa o terceiro número
#dev –> 0.0.0.9001 - incrementa o quarto número (se houver)
