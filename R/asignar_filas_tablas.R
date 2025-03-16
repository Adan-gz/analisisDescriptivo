#' Asigna filas para la exportación de tablas a Excel
#'
#' Esta función determina la posición (filas) en la que se colocarán cada tabla y su título en un archivo Excel.
#' La primera tabla se escribe a partir de la fila 4 y las siguientes se separan por 3 filas adicionales.
#'
#' @param list_tablas Lista de data.frames que se exportarán.
#'
#' @return Un tibble con las siguientes columnas:
#' \describe{
#'   \item{Tablas}{Nombre asignado a cada tabla.}
#'   \item{Nfilas}{Número de filas de cada tabla.}
#'   \item{primeraFila}{Fila de inicio para cada tabla en el Excel.}
#'   \item{tituloFila}{Fila en la que se colocará el título de la tabla (generalmente una fila antes de la tabla).}
#' }
#'
#' @examples
#' \dontrun{
#' list_temp <- list(head(mtcars,5),head(mtcars,5),head(mtcars,5))
#' asignar_filas_tablas( list_temp )
#' }
#' @importFrom purrr map_dbl
#'
#'
#' @export
asignar_filas_tablas <- function(list_tablas) {

  if( is.data.frame(list_tablas) ){
    salida <-   data.frame(
      Tablas = 'Tabla_1',
      Nfilas = nrow(list_tablas),
      primeraFila = 4,
      tituloFila = 3
    )
    return(salida)
  }

  n_tablas <- length(list_tablas)

  if( n_tablas == 1 ){
    salida <-   data.frame(
      Tablas = 'Tabla_1',
      Nfilas = nrow(list_tablas[[1]]),
      primeraFila = 4,
      tituloFila = 3
    )
    return(salida)
  }

  # título principal va en la fila 1, en la 3 va el título de la tabla, y en la 4 la tabla.
  # Cada tabla va separada por 3 espacios, porque en la fila intermedia va el título.
  n_filas_tablas <- purrr::map_dbl(list_tablas, \(t.i) nrow(t.i) )

  primera_fila_tablas <- c(4, rep(NA, n_tablas - 1))

  for (i in 2:length(primera_fila_tablas)) {
    # primera_fila_tablas[i] <- primera_fila_tablas[i - 1] + n_filas_tablas[i] + 3
    primera_fila_tablas[i] <- primera_fila_tablas[i - 1] + n_filas_tablas[i - 1] + 3

  }
  # Nota: Se asume que se desea que la fila del título de la tabla sea una fila antes
  # de la fila de inicio de la tabla.
  data.frame(
    Tablas = paste0("Tabla_", 1:n_tablas),
    Nfilas = n_filas_tablas,
    primeraFila = primera_fila_tablas,
    tituloFila = primera_fila_tablas - 1
  )
}
