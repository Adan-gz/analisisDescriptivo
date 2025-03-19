#' Calcula la covarianza ponderada
#'
#' Esta función calcula la covarianza ponderada entre dos vectores numéricos, considerando un vector
#' de pesos. Los valores de los vectores de entrada que son NA se eliminan automáticamente.
#'
#' @param x Un vector numérico.
#' @param y Un vector numérico.
#' @param pesos Un vector numérico de pesos.
#'
#' @return Un valor numérico que representa la covarianza ponderada.
#'
#' @importFrom stats weighted.mean
#'
#' @examples
#' \dontrun{
#' temp <- mtcars
#' temp$w <- rlnorm(nrow(temp))
#' covarianza_ponderada( temp$mpg, temp$disp, pesos = temp$w  )
#' cov( temp$mpg, temp$disp  )
#' }
#'
#' @export
covarianza_ponderada <- function(x,y,pesos){

  indice_missings <- which( is.na(x) | is.na(y) | is.na(pesos) )
  if( length(indice_missings) > 0  ){
    x <- x[-indice_missings]
    y <- y[-indice_missings]
    pesos <- pesos[-indice_missings]
  }

  sum_pesos <- sum(pesos)
  media_x_pond  <- weighted.mean( x = x, w = pesos )
  media_y_pond  <- weighted.mean( x = y, w = pesos )

  sum( pesos*(x - media_x_pond)*(y-media_y_pond) ) / sum_pesos

}
