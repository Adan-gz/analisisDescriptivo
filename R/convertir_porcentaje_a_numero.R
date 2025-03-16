#' Convertir porcentaje en formato texto a numérico
#'
#' Elimina el símbolo de porcentaje y reemplaza la coma decimal por un punto, para finalmente convertir la cadena en numérico.
#'
#' @param x Vector de caracteres representando porcentajes (ejemplo: "12,5%").
#'
#' @return Vector numérico.
#'
#' @examples
#' \dontrun{
#' convertir_porcentaje_a_numero(c("12,5%", "100,0%"))
#' }
#' @export
convertir_porcentaje_a_numero <- function(x) {
  # Eliminar el símbolo de porcentaje
  out <- gsub('%', '', x)
  # Reemplazar la coma por punto para adecuar el formato decimal
  out <- gsub(',', '.', out)
  # Convertir la cadena resultante a numérico
  as.numeric(out)
}
