#' Calcula el coeficiente de correlación ponderado
#'
#' Esta función calcula el coeficiente de correlación ponderado entre dos vectores numéricos,
#' utilizando los pesos correspondientes.
#'
#' @param x Un vector numérico.
#' @param y Un vector numérico.
#' @param pesos Un vector numérico de pesos.
#'
#' @return Un valor numérico que representa el coeficiente de correlación ponderado.
#'
#' @importFrom stats weighted.mean
#' @importFrom stats sd
#' @importFrom stats quantile
#' @importFrom dplyr case_when
#'
#' @examples
#' \dontrun{
#' temp <- mtcars
#' temp$w <- rlnorm(nrow(temp))
#' coeficiente_correlacion_ponderado( temp$mpg, temp$disp, pesos = temp$w  )
#' cor( temp$mpg, temp$disp  )
#' }
#'
#' @export
coeficiente_correlacion_ponderado <- function(x,y,pesos){

  indice_missings <- which( is.na(x) | is.na(y) | is.na(pesos) )

  if( length(indice_missings) > 0  ){
    x <- x[-indice_missings]
    y <- y[-indice_missings]
    pesos <- pesos[-indice_missings]
  }

  var_X_pond <- desviacion_estandar_ponderada(x=x,pesos=pesos)^2
  var_y_pond <- desviacion_estandar_ponderada(x=y,pesos=pesos)^2
  covarianza_pond <- covarianza_ponderada( x = x, y = y, pesos = pesos )

  covarianza_pond / sqrt( var_X_pond*var_y_pond )

}
