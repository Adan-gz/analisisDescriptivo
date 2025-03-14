#' Convertir valores numéricos a formato porcentual
#'
#' Convierte un vector numérico a formato de porcentaje utilizando la función \code{scales::percent}.
#'
#' @param x Vector numérico.
#' @param accuracy Precisión para el formateo del porcentaje. Por defecto es \code{1}.
#' @param ... Argumentos adicionales que se pasan a \code{scales::percent}.
#'
#' @return Vector de caracteres con los porcentajes formateados.
#'
#' @examples
#' percent(c(0.1, 0.5, 0.99), 0.01)
#'
#' @export
percent <- function(x, accuracy = 1, ...) {
  # Convertir a porcentaje usando separador de miles y decimal definidos
  scales::percent(x = x, accuracy = accuracy, big.mark = '.', decimal.mark = ',', ...)
}
