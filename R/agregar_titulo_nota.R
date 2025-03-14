#' Agregar título y nota a un data frame o tibble
#'
#' Esta función agrega una columna denominada "Titulo" al inicio del objeto \code{t}
#' si se especifica un título, y añade una fila con la nota al final si se proporciona una.
#'
#' @param t Data frame o tibble sobre el que se añadirá el título y/o la nota.
#' @param titulo Cadena de texto que representa el título. Por defecto, cadena vacía.
#' @param nota Cadena de texto que representa la nota. Por defecto, cadena vacía.
#'
#' @return Data frame o tibble modificado que contiene la columna y/o fila con título y nota.
#'
#' @details La función desagrupa el objeto \code{t} para evitar problemas de agrupación. Si se
#' provee un título, se crea una nueva columna llamada "Titulo" que se inserta al inicio del data frame;
#' si se provee una nota, se agrega como una fila adicional al final. Se asignan atributos al objeto
#' resultante para conservar estos valores.
#'
#' @examples
#' \dontrun{
#'   library(dplyr)
#'   library(tibble)
#'   t <- tibble(x = 1:5, y = 6:10)
#'   t_mod <- agregar_titulo_nota(t, titulo = "Datos", nota = "Fuente: encuesta")
#' }
#'
#' @export
agregar_titulo_nota <- function(tabla, titulo = '', nota = '') {
  # Asegurarse de que t no esté agrupado para evitar problemas posteriores
  tabla <- ungroup(tabla)

  # Validar que 't' sea un data frame o tibble
  if (!inherits(tabla, "data.frame")) {
    stop("El argumento 'tabla' debe ser un data frame o tibble.")
  }

  # Si se provee un título, se añade una columna "Titulo" al inicio
  if (titulo != '') {
    # Crear un vector de la misma longitud que t, con NA
    z <- rep(NA, nrow(tabla))
    # Asignar el título a la primera posición
    z[1] <- titulo

    # Insertar la nueva columna "Titulo" antes de la primera columna
    tabla <- tabla %>% mutate(Titulo = z, .before = 1)

    # Guardar el título como atributo del objeto
    attr(tabla, 'Titulo') <- titulo
  }

  # Si se provee una nota, se añade una fila al final
  if (nota != '') {
    # Prepara la nota concatenando "Nota: " al inicio si es necesario
    nota <- ifelse(nota == '', nota, paste0('Nota: ', nota))

    # Agregar una nueva fila con la nota en la columna "Titulo"
    tabla <- tabla %>% bind_rows(tibble(Titulo = nota))

    # Guardar la nota como atributo del objeto
    attr(tabla, 'Nota') <- nota
  }

  # Retornar el data frame modificado
  tabla
}
