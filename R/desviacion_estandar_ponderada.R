#' Calcular la desviación estándar ponderada
#'
#' Calcula la desviación estándar de un vector numérico \code{x} utilizando un vector de pesos \code{w}.
#'
#' @param x Vector numérico.
#' @param pesos Vector de pesos del mismo tamaño que \code{x}.
#'
#' @return La desviación estándar ponderada.
#'
#' @details Se eliminan los valores \code{NA} de \code{x} y sus correspondientes pesos en \code{pesos}. La función utiliza
#' la corrección de Bessel (dividiendo por \code{sum(pesos)-1}) para el cálculo de la varianza.
#'
#' @examples
#' \dontrun{
#' temp <- mtcars
#' temp$w <- rlnorm(nrow(temp))
#' desviacion_estandar_ponderada( temp$mpg, pesos = temp$w  )
#' sd( temp$mpg )
#' }
#'
#' @export
desviacion_estandar_ponderada <- function(x, pesos) {
  # Verificar que x y pesos tengan la misma longitud
  if (length(x) != length(pesos)) {
    stop("Los vectores 'x' y 'pesos' deben tener la misma longitud.")
  }

  # Identificar índices de valores NA en x
  indices_na <- which(is.na(x) | is.na(pesos))
  # Eliminar los valores NA y sus correspondientes pesos
  if (length(indices_na) > 0) {
    warning("Para el cálculo de la varianza ponderada se eliminan los valores perdidos")
    x <- x[-indices_na]
    pesos <- pesos[-indices_na]
  }

  # Basada en la implementación de Hmisc::wtd.var

  # Calcular la suma de los pesos
  pesos_sum <- sum(pesos)

  # Calcular la media ponderada
  w_mean <- sum(pesos * x) / pesos_sum

  # Calcular la varianza ponderada utilizando la corrección de Bessel
  var_weighted <- sum(pesos * (x - w_mean)^2) / (pesos_sum - 1)

  # Retornar la desviación estándar (raíz cuadrada de la varianza)
  sqrt(var_weighted)
}
