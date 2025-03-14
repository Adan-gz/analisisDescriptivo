#' Calcular límite del intervalo de confianza para proporciones usando el método de Wilson
#'
#' Calcula el límite inferior o superior del intervalo de confianza para proporciones utilizando el método de Wilson.
#'
#' @param p Vector de proporciones (valores entre 0 y 1).
#' @param N Vector con el tamaño de muestra correspondiente a cada proporción.
#' @param nivel_confianza Nivel de confianza. Por defecto es \code{0.95}.
#' @param limite Cadena que indica si se desea el límite inferior (\code{"inferior"}) o superior (\code{"superior"}) del intervalo.
#'
#' @return Vector numérico con el límite inferior o superior del intervalo de confianza para cada par de \code{p} y \code{N}.
#'
#' @details Se utiliza la función \code{qnorm} para obtener el valor crítico de la distribución normal y
#' se calcula el intervalo de confianza siguiendo la fórmula de Wilson.
#'
#' @examples
#' intervalo_confianza_pWilson(c(0.1, 0.5), c(100, 200), nivel_confianza = 0.95, limite = "superior")
#'
#' @importFrom purrr map2_dbl
#'
#' @export
intervalo_confianza_pWilson <- function(p, N, nivel_confianza = 0.95, limite = c('inferior', 'superior')) {
  # Se utiliza sólo el primer valor de 'limite' en caso de que se hayan pasado ambos
  limite <- match.arg(limite)

  # Obtener el valor crítico de la distribución normal para el nivel de confianza
  z <- qnorm(1 - (1 - nivel_confianza) / 2)

  # Calcular el límite del intervalo de confianza usando la fórmula de Wilson
  purrr::map2_dbl(
    p,
    N,
    function(p.i, N.i) {
      denominador <- 1 + (z^2 / N.i)
      numerador_1 <- p.i + (z^2 / (2 * N.i))
      numerador_2 <- z * sqrt((p.i * (1 - p.i) / N.i) + (z^2 / (4 * N.i^2)))
      if (limite == 'inferior') {
        (numerador_1 - numerador_2) / denominador
      } else {
        (numerador_1 + numerador_2) / denominador
      }
    }
  )
}
