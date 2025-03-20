#' Trocea un vector numérico en cuartiles
#'
#' Esta función toma un vector numérico y lo divide en cuatro cuartiles. Cada elemento del vector
#' es asignado a un cuartil dependiendo de su valor.
#'
#' @param x Un vector numérico.
#'
#' @return Un vector con las etiquetas de cuartiles ('Cuartil_1', 'Cuartil_2', 'Cuartil_3', 'Cuartil_4')
#'
#' @importFrom dplyr case_when
#' @importFrom stats quantile
#'
#' @examples
#' trocear_por_cuartiles(c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10))
trocear_por_cuartiles <- function(x){
  cuartiles <- quantile(x,na.rm=T)
  case_when(
    x < cuartiles[2] ~ 'Cuartil_1',
    x >= cuartiles[2] & x < cuartiles[3]  ~ 'Cuartil_2',
    x >= cuartiles[3] & x < cuartiles[4]  ~ 'Cuartil_3',
    x >= cuartiles[4] ~ 'Cuartil_4',
    is.na(x) == T ~ NA
  )
}
