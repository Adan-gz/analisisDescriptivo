#' Calcular el margen de error del intervalo de confianza de la media utilizando la distribución t de Student
#'
#' Calcula el margen de error para datos numéricos dado el tamaño de la muestra y la desviación estándar.
#'
#' @param N Vector con el tamaño de muestra.
#' @param sd Vector con la desviación estándar.
#' @param conf_level Nivel de confianza. Por defecto es \code{0.95}.
#'
#' @return Vector numérico con el margen de error correspondiente para cada par de \code{N} y \code{sd}.
#'
#' @details Se utiliza la función \code{qt} para obtener el quantil t para \code{N-1} grados de libertad,
#' y se calcula el margen de error como: \eqn{qt(1 - ((1 - conf_level) / 2), N-1) * sd/sqrt(N)}.
#'
#' @examples
#' margenError_num(c(30, 40), c(2, 3), conf_level = 0.95)
#'
#' @export
margen_error_media <- function(N, sd, conf_level = 0.95) {
  # Verificar que N y sd tengan la misma longitud
  if (length(N) != length(sd)) {
    stop("Los vectores 'N' y 'sd' deben tener la misma longitud.")
  }

  # Calcular el margen de error para cada par de N y sd
  purrr::map2_dbl(
    N,
    sd,
    function(N.i, sd.i) {
      qt(1 - ((1 - conf_level) / 2), N.i - 1) * sd.i / sqrt(N.i)
    }
  )
}
