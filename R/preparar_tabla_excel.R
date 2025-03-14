#' Formatear tabla para exportación a Excel
#'
#' Prepara una tabla (tibble o data frame) para exportarla a una única hoja de Excel.
#' La función formatea las columnas indicadas como proporciones (si se especifica) usando la función
#' \code{percent} y convierte todas las columnas a caracteres. Además, conserva los nombres originales
#' de las columnas en la primera fila, mientras renombra internamente las columnas a un formato genérico.
#'
#' @param datos Data frame o tibble que se desea formatear.
#' @param ajustar_proporciones Vector de caracteres con el nombre de las columnas que representan proporciones.
#'   Si es \code{NULL} (por defecto), no se aplica ajuste.
#' @param precision Precisión para el formateo de las proporciones. Por defecto es \code{0.1}.
#'
#' @return Data frame formateado, en el cual la primera fila contiene los nombres originales de las columnas,
#'   y las columnas han sido convertidas a caracteres.
#'
#' @details La función realiza los siguientes pasos:
#' \enumerate{
#'   \item Si se especifica \code{ajustar_proporciones}, se aplica la función \code{percent} a esas columnas.
#'   \item Se convierten todas las columnas a caracteres.
#'   \item Se extraen los nombres originales de las columnas y se guardan en un vector.
#'   \item Se renombran las columnas a "col1", "col2", ..., para luego insertar la fila de encabezado.
#'   \item Se une la fila con los nombres originales y la tabla formateada.
#' }
#'
#' @examples
#' \dontrun{
#'   library(dplyr)
#'   library(tibble)
#'   datos <- tibble(a = c(0.1, 0.2, 0.3), b = c(1, 2, 3))
#'   tabla_formateada <- preparar_tabla_excel(datos, ajustar_proporciones = "a", precision = 1)
#' }
#'
#' @export
preparar_tabla_excel <- function(datos,
                                 ajustar_proporciones = NULL,
                                 precision = 0.1) {
  # Si se especifica alguna columna para ajustar como proporción, se formatea
  if (!is.null(ajustar_proporciones)) {
    datos <- datos %>%
      mutate(across(all_of(ajustar_proporciones), \(x) percent(x, accuracy = precision)))
  }

  # Convertir todas las columnas a caracteres para evitar problemas de formato al exportar
  datos <- datos %>% mutate(across(everything(), as.character))
  datos <- as.data.frame(datos)

  # Guardar los nombres originales de las columnas
  fila_nombre_cols <- colnames(datos)
  # Renombrar las columnas a un formato genérico: col1, col2, ...
  colnames(datos) <- paste0("col", 1:ncol(datos))
  # Asignar los nuevos nombres como nombres del vector que contiene los encabezados originales
  names(fila_nombre_cols) <- colnames(datos)

  # Unir la fila de encabezados originales y la tabla modificada
  salida <- as.data.frame(bind_rows(as_tibble(as.list(fila_nombre_cols)), datos))

  ## Nota: Se puede ampliar aquí la funcionalidad para detectar atributos como 'titulo' o 'nota'
  ## y añadir filas vacías arriba/abajo en caso de ser necesario.

  salida
}
