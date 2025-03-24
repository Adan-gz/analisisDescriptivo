#' Genera un descriptivo para una variable dependiente categórica
#'
#' Esta función genera un resumen descriptivo para una variable dependiente categórica (`var_VDcat`)
#' según los valores de una variable X, que puede ser numérica o categórica. En el caso de que la
#' variable X sea numérica, se utiliza la función `generar_descriptivo_numerico` para generar el descriptivo
#' por grupos. Si la variable X es categórica, se utiliza la función `generar_descriptivo_categorico`.
#'
#' Si se proporciona una variable de peso (`var_peso`), las métricas se ajustan en función de los pesos.
#'
#' @param datos Un data.frame o tibble con los datos.
#' @param var_VDcat El nombre de la variable dependiente categórica.
#' @param var_X El nombre de la variable X (puede ser numérica o categórica).
#' @param var_peso El nombre de la variable de pesos (opcional).
#' @param variable_pivot El nombre de la variable de agrupación para la pivoteo (por defecto "var_grupo").
#' @param estrategia_valoresPerdidos La estrategia para manejar los valores perdidos, por defecto 'A'.
#' @param nivel_confianza El nivel de confianza para los intervalos de confianza (por defecto, 0.95).
#' @param simplificar_output Indica si se debe simplificar el output (por defecto, TRUE).
#'
#' @return Un tibble con los resultados del análisis descriptivo, que incluye las métricas por grupos según el tipo de la variable X.
#'         La tabla tendrá un atributo que indica el tipo de análisis ('categorica') y si la variable X es un grupo.
#'
#' @importFrom dplyr mutate group_by summarise ungroup bind_cols
#' @importFrom rlang sym
#' @importFrom tidyr pivot_wider
#'
#' @examples
#' \dontrun{
#'  library(analisisDescriptivo)
#'  library(dplyr)
#'  temp <- mtcars %>%
#'    mutate('cyl'=as.character(cyl),
#'           'carb'=factor(carb),
#'           'gear' = factor(gear),
#'           'grupo' = sample(c('A','B'),nrow(.),T),
#'           'w'=rlnorm(32),
#'           w_norm = rnorm(32)
#'    )
#'
#'  generar_descriptivo_VDcategorica_varX(
#'    temp,
#'    'gear',
#'    'mpg',
#'    'w'
#'  )
#'  generar_descriptivo_VDcategorica_varX(
#'    temp,
#'    'gear',
#'    'grupo',
#'    'w'
#'  )
#' }
#'
#' @export
generar_descriptivo_VDcategorica_varX <- function(
    datos,
    var_VDcat,
    var_X,
    var_peso = NULL,
    variable_pivot = "var_grupo",
    estrategia_valoresPerdidos = 'A',
    nivel_confianza = 0.95,
    simplificar_output = T
){
  if( !var_VDcat %in% colnames(datos) ){
    stop("La variable dependiente ", var_VDcat ," no se encuentra en la matriz de datos")
  }

  if( !var_X %in% colnames(datos) ){
    stop("La variable independiente ", var_X ," no se encuentra en la matriz de datos")
  }

  # si la X NO es numerica, es decir categorica (factor o chr)
  if( !is.numeric(datos[[var_X]]) ){

    salida <- generar_descriptivo_categorico(
      datos = datos,
      var_categorica = var_VDcat,
      vars_grupo = var_X,
      var_peso = var_peso,
      variable_pivot = variable_pivot,
      nivel_confianza = nivel_confianza,
      estrategia_valoresPerdidos = estrategia_valoresPerdidos,
      simplificar_output = simplificar_output
    )

    attr(salida,'tipo_tabla') <- 'categorica'
    attr(salida,'vars_grupo') <- TRUE

  } else { # si la X es Numerica
    salida <- generar_descriptivo_numerico(
      datos = datos,
      var_numerica = var_X,
      vars_grupo = var_VDcat,
      var_peso = var_peso,
      nivel_confianza = nivel_confianza
    )

    attr(salida,'tipo_tabla') <- 'numerica'
    attr(salida,'vars_grupo') <- TRUE
  }

  salida
}
