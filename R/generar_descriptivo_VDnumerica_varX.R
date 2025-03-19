#' Genera un descriptivo para una variable dependiente numérica
#'
#' Esta función genera un resumen descriptivo para una variable dependiente numérica (`var_VDnum`)
#' según los valores de una variable X, que puede ser numérica o categórica. En el caso de que la
#' variable X sea numérica, se calcula la media por cuartiles y se ajusta un modelo de regresión lineal
#' (OLS). Si la variable X es categórica, se utiliza la función `generar_descriptivo_numerico` para
#' generar el descriptivo por grupos.
#'
#' Si se proporciona una variable de peso (`var_peso`), se calcula también el modelo de regresión ponderada
#' y se ajustan las métricas correspondientes.
#'
#' @param datos Un data.frame o tibble con los datos.
#' @param var_VDnum El nombre de la variable dependiente numérica.
#' @param var_X El nombre de la variable X (puede ser numérica o categórica).
#' @param var_peso El nombre de la variable de pesos (opcional).
#' @param nivel_confianza El nivel de confianza para los intervalos de confianza (por defecto, 0.95).
#'
#' @return Un tibble con los resultados del análisis descriptivo, que incluye la media por cuartiles (si X es numérica),
#' el coeficiente de la regresión OLS, el valor p de la regresión, y otros detalles de la regresión ponderada si se proporciona `var_peso`.
#'
#' @importFrom dplyr mutate group_by summarise ungroup bind_cols
#' @importFrom tidyr pivot_wider
#' @importFrom rlang sym
#' @importFrom dplyr case_when
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
#'  generar_descriptivo_VDnumerica_varX(
#'    temp,
#'    'mpg',
#'    'disp',
#'    'w'
#'  )
#'  generar_descriptivo_VDnumerica_varX(
#'    temp,
#'    'mpg',
#'    'grupo',
#'    'w'
#'  )
#' }
#'
#' export
generar_descriptivo_VDnumerica_varX <- function(
    datos,
    var_VDnum,
    var_X,
    var_peso = NULL,
    nivel_confianza = 0.95
){

  # si la X es numerica
  if( is.numeric(datos[[var_X]]) ){

    medias_cuartiles <- datos %>%
      mutate( 'x_cuartiles' = trocear_por_cuartiles(!!sym(var_X))) %>%
      group_by(x_cuartiles) %>%
      summarise( 'Media' = mean(!!sym(var_VDnum), na.rm=T ) ) %>%
      ungroup() %>%
      tidyr::pivot_wider(names_from = x_cuartiles, values_from = Media, names_glue = '{.name}_Media')

    OLS_simple <- lm( datos[[var_VDnum]] ~ datos[[var_X]] )

    salida <- tibble(
      'Var_VD' = var_VDnum,
      'var_X' = var_X,
      'R2'    = cor(x = datos[[var_VDnum]], y = datos[[var_X]] ),
      'OLS_coef' = coef( OLS_simple )[2],
      'OLS_p_value'  = summary(OLS_simple)$coefficients[2,4],

    ) %>%
      bind_cols( medias_cuartiles )

    if(!is.null(var_peso)){

      pesos <- datos[[var_peso]]

      OLS_simple_w <- lm( datos[[var_VDnum]] ~ datos[[var_X]], weights = pesos )

      salida <- salida %>%
        mutate(
          'R2_w'  = coeficiente_correlacion_ponderado(x = datos[[var_VDnum]], y = datos[[var_X]], pesos = pesos ),
          .after  = R2
        ) %>%
        mutate(
          'OLS_coef_w' = coef( OLS_simple_w )[2],
          'OLS_p_value_w'  = summary(OLS_simple_w)$coefficients[2,4],
          .after = OLS_p_value
        )

    }

    attr(salida,'tipo_tabla') <- 'numerica'
    attr(salida,'vars_grupo') <- FALSE

  } else { # si la X es categorica
    salida <- generar_descriptivo_numerico(
      datos = datos,
      var_numerica = var_VDnum,
      vars_grupo = var_X,
      var_peso = var_peso,
      nivel_confianza = nivel_confianza)

    attr(salida,'tipo_tabla') <- 'numerica'
    attr(salida,'vars_grupo') <- TRUE
  }

  salida
}
