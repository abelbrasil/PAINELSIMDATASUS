#' Connect to Github and Power BI
#'
#' Function to establish connection between Github, R, and Power BI
#'
#' @param github_username Github username
#' @param github_password Github password
#' @param github_repository Github repository name
#' @param powerbi_username Power BI username
#' @param powerbi_password Power BI password
#' @param show_powerbi_info Whether to show Power BI connection info (default: TRUE)
#'
#' @return A list with Github token and Power BI info
#' @export
connectrgb <- function(github_username, github_password, github_repository, powerbi_username, powerbi_password, show_powerbi_info = TRUE) {

  # Check if required packages are installed and load them if not
  if (!requireNamespace("httr", quietly = TRUE)) {
    install.packages("httr")
    library(httr)
  }

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite")
    library(jsonlite)
  }

  # Connection to Github
  github_base_url <- "https://api.github.com"
  response <- httr::POST(paste0(github_base_url, "/authorizations"),
                         httr::authenticate(github_username, github_password),
                         body = list(scopes = c("public_repo", "repo")))

  if (response$status_code != 201) {
    stop("Error authenticating with Github.")
  }

  token <- jsonlite::fromJSON(content(response, as = "text"))$token

  # Set Git configuration with Github token
  config <- git2r::config()
  config$set_string("github.token", token)
  git2r::set_config(config)

  # Check if Github repository exists and clone it
  if (!dir.exists(github_repository)) {
    repo_url <- paste0("https://github.com/", github_username, "/", github_repository)
    git2r::clone(repo_url, github_repository)
  }

  # Connection to Power BI
  if (show_powerbi_info) {
    cat("Power BI connection info:\n")
    cat("Portal URL: https://app.powerbi.com/\n")
    cat("Username: ", powerbi_username, "\n", sep = "")
  }

  # Return Github token and Power BI info
  list(github_token = token,
       powerbi_info = list(url = "https://app.powerbi.com/",
                           username = powerbi_username))
}
