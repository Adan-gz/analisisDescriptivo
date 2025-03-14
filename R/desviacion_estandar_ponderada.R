#' Calcular la desviación estándar ponderada
#'
#' Calcula la desviación estándar de un vector numérico \code{x} utilizando un vector de pesos \code{w}.
#'
#' @param x Vector numérico.
#' @param w Vector de pesos del mismo tamaño que \code{x}.
#'
#' @return La desviación estándar ponderada.
#'
#' @details Se eliminan los valores \code{NA} de \code{x} y sus correspondientes pesos en \code{w}. La función utiliza
#' la corrección de Bessel (dividiendo por \code{sum(w)-1}) para el cálculo de la varianza.
#'
#' @examples
#' sd_pond(c(1,2,3,4,5), c(1,1,1,1,1))
#'
#' @export
sd_pond <- function(x, w) {
  # Verificar que x y w tengan la misma longitud
  if (length(x) != length(w)) {
    stop("Los vectores 'x' y 'w' deben tener la misma longitud.")
  }

  # Identificar índices de valores NA en x
  NA_ind <- which(is.na(x) | is.na(w))
  # Eliminar los valores NA y sus correspondientes pesos
  if (length(NA_ind) > 0) {
    warning("Para el cálculo de la varianza ponderada se eliminan los valores perdidos")
    x <- x[-NA_ind]
    w <- w[-NA_ind]
  }

  # Calcular la suma de los pesos
  w_sum <- sum(w)

  # Calcular la media ponderada
  w_mean <- sum(w * x) / w_sum

  # Calcular la varianza ponderada utilizando la corrección de Bessel
  var_weighted <- sum(w * (x - w_mean)^2) / (w_sum - 1)

  # Retornar la desviación estándar (raíz cuadrada de la varianza)
  sqrt(var_weighted)
}
