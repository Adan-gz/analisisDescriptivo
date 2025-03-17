#' Concatenar múltiples tablas para exportación a Excel (deprecated)
#'
#' Une varias tablas (tibbles o data frames) en una sola, separándolas mediante filas vacías.
#' Esto permite exportar muchas tablas en una única hoja de Excel. Opcionalmente, se puede formatear cada
#' tabla individualmente usando \code{\link{preparar_tabla_excel}}.
#'
#' @param lista_tablas Lista de data frames o tibbles a concatenar. Si se proporciona un único data frame,
#'   se convertirá en una lista de un elemento.
#' @param n_filas_vacias Número de filas vacías que se insertarán entre cada tabla. Por defecto es \code{2}.
#' @param ajustar Lógico. Si es \code{TRUE} (por defecto), se aplicará \code{preparar_tabla_excel} a cada tabla.
#' @param ajustar_proporciones Vector de caracteres con los nombres de las columnas a formatear como proporciones.
#' @param precision Precisión para el formateo de las proporciones. Por defecto es \code{0.1}.
#'
#' @return Data frame resultante de concatenar todas las tablas, listo para exportación a Excel.
#'
#' @details La función itera sobre cada tabla en \code{lista_tablas} y, si \code{ajustar} es \code{TRUE},
#' formatea la tabla mediante \code{preparar_tabla_excel}. Luego, añade filas vacías (según \code{n_filas_vacias})
#' para separar visualmente cada tabla. Finalmente, concatena todas las tablas en un único data frame.
#'
#' @examples
#' \dontrun{
#'   tabla1 <- tibble(a = 1:3, b = 4:6)
#'   tabla2 <- tibble(a = 7:9, b = 10:12)
#'   resultado <- concatenar_tablas_excel(list(tabla1, tabla2), n_filas_vacias = 2, ajustar = TRUE)
#' }
#' @importFrom dplyr bind_rows
#' @importFrom tibble as_tibble
#'
#' @note **Deprecated**  Esta función está obsoleta y será eliminada en futuras actualizaciones. Utiliza las funciones `crear_Excel_*()` en su lugar.
#' @export
concatenar_tablas_excel <- function(lista_tablas,
                                    n_filas_vacias = 2,
                                    ajustar = TRUE,
                                    ajustar_proporciones = NULL,
                                    precision = 0.1) {
  .Deprecated(new = 'crear_Excel_*')

  # Si se pasa un único data frame, lo encapsula en una lista
  if (is.data.frame(lista_tablas)) {
    lista_tablas <- list(lista_tablas)
  }

  # Inicializar data frame vacío para la salida final
  salida <- data.frame()

  # Iterar sobre cada tabla de la lista
  for (tabla in lista_tablas) {
    # Aplicar el formateo si se solicita
    if (ajustar) {
      tabla <- preparar_tabla_excel(datos = tabla,
                                    ajustar_proporciones = ajustar_proporciones,
                                    precision = precision)
    }

    # Agregar filas vacías para separar tablas, si se especifica
    if (n_filas_vacias > 0) {
      empty <- as.data.frame(matrix(rep(NA, ncol(tabla) * n_filas_vacias), ncol = ncol(tabla)))
      if (is.null(colnames(tabla))) {
        colnames(empty) <- NULL
      } else {
        colnames(empty) <- colnames(tabla)
      }
      tabla <- bind_rows(
        as_tibble(tabla, .name_repair = "minimal"),
        as_tibble(empty, .name_repair = "minimal")
      )
    }

    # Concatenar la tabla actual a la salida final
    salida <- bind_rows(
      as_tibble(salida, .name_repair = "minimal"),
      as_tibble(tabla, .name_repair = "minimal")
    )

    # Asegurarse de que la salida sea siempre un data frame
    salida <- as.data.frame(salida)
  }

  # Eliminar nombres de columnas para que Excel los interprete correctamente
  colnames(salida) <- NULL

  # Si se desea eliminar la fila de encabezados (que contiene "col1" en la primera columna),
  # se puede descomentar la siguiente línea:
  # salida <- salida[-which(salida[[1]] == "col1"), ]

  return(salida)
}
