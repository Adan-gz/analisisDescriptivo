#' Formatear números con separadores
#'
#' Convierte un vector numérico a una representación en formato numérico legible, utilizando la función \code{scales::number}.
#'
#' @param x Vector numérico.
#' @param accuracy Precisión para el formateo del número. Por defecto es \code{0.1}.
#' @param ... Argumentos adicionales que se pasan a \code{scales::number}.
#'
#' @return Vector de caracteres con los números formateados.
#'
#' @examples
#' formatear_numero(c(1234.56, 7890.12))
#'
#' @importFrom scales number
#'
#' @export
formatear_numero <- function(x, accuracy = .1, ...) {
  # Convertir número usando separador de miles y decimal definidos
  scales::number(x = x, accuracy = accuracy, big.mark = '.', decimal.mark = ',', ...)
}
