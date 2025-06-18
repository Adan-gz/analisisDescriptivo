#' Trocea un vector numérico en cuartiles
#'
#' Esta función toma un vector numérico y lo divide en cuatro cuartiles. Cada elemento del vector
#' es asignado a un cuartil dependiendo de su valor.
#'
#' @param x Un vector numérico.
#' @param añadirValor Por defecto FALSE. Si TRUE añade a la etiqueta el valor del cuartil.
#' @param ... Parámetros de la función \code{analisisDescriptivo::formatear_numero}.
#'
#' @return Un vector con las etiquetas de cuartiles ('Cuartil_1', 'Cuartil_2', 'Cuartil_3', 'Cuartil_4')
#'
#' @importFrom dplyr case_when
#' @importFrom stats quantile
#'
#' @examples
#' trocear_por_cuartiles(c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10))
#' trocear_por_cuartiles(mtcars$mpg)
#' trocear_por_cuartiles(mtcars$mpg, añadirValor = T)
trocear_por_cuartiles <- function(x, añadirValor = F,... ){

  cuartiles <- quantile(x,na.rm=T)
  etiquetas <- paste0('Q',1:4)

  if( añadirValor ){

    cuartiles_format <- analisisDescriptivo::formatear_numero(cuartiles,...)

    etiquetas <- paste0(etiquetas,' - ', cuartiles_format)
  }

    case_when(
    x < cuartiles[2] ~ etiquetas[1],
    x >= cuartiles[2] & x < cuartiles[3]  ~ etiquetas[2],
    x >= cuartiles[3] & x < cuartiles[4]  ~ etiquetas[3],
    x >= cuartiles[4] ~ etiquetas[4],
    is.na(x) == T ~ NA
  )
}
