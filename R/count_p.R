#' Calcular Conteo y Proporciones
#'
#' Esta función realiza un conteo de ocurrencias en un data frame según las variables especificadas y
#' añade una columna con la proporción de cada grupo respecto al total.
#'
#' @param df Data frame. Conjunto de datos en el que se realizará el conteo.
#' @param ... Variables de agrupación o expresiones sobre las cuales se calculará el conteo.
#' @param wt variable del data.frame que representa el vector de ponderación o pesos.
#' @return Un tibble con las columnas resultantes de \code{dplyr::count()} (incluyendo \code{n} para el conteo)
#'   y una columna \code{p} que contiene la proporción de cada grupo calculada como \code{n/sum(n)}.
#'
#' @details
#' La función utiliza \code{dplyr::count()} para obtener los conteos y posteriormente \code{dplyr::mutate()}
#' para calcular la proporción de cada grupo respecto al total. Es una manera práctica de combinar ambos pasos en uno solo.
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' # Ejemplo con un data frame simple:
#' df <- tibble(grupo = c("A", "A", "B", "B", "B"))
#' count_p(df, grupo)
#' }
#' @importFrom dplyr count mutate `%>%`
#' @importFrom rlang enquos
#'
#' @export

count_p <- function (df, ..., wt = NULL) {
  dots <- rlang::enquos(...)
  df %>%
    dplyr::count(..., wt = {{wt}}) %>%
    mutate(p = n / sum(n))
}
