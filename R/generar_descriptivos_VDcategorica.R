#' Genera descriptivos para una variable dependiente categórica por múltiples variables X
#'
#' Esta función genera un resumen descriptivo para una variable dependiente categórica (`var_VDcat`)
#' con respecto a varias variables X. Las variables X pueden ser tanto numéricas como categóricas.
#' Los resultados se calculan utilizando la función `generar_descriptivo_VDcategorica_varX` para cada variable X.
#' Además, si se proporciona una variable de peso (`var_peso`), los análisis se realizarán ponderados.
#'
#' Si no se proporciona la lista de variables X, la función automáticamente seleccionará todas las variables
#' en `datos` que no sean `var_VDcat` ni `var_peso` y las tratará como posibles variables X.
#'
#' @param datos Un data.frame o tibble con los datos.
#' @param var_VDcat El nombre de la variable dependiente categórica.
#' @param vars_X Una lista de nombres de variables X, que pueden ser numéricas o categóricas. Si es NULL, se seleccionan automáticamente las demás columnas.
#' @param var_peso El nombre de la variable de pesos (opcional).
#' @param variable_pivot El nombre de la variable de agrupación para el pivoteo (por defecto "var_grupo").
#' @param num_unificar_1tabla Un valor lógico que indica si los resultados numéricos deben unificarse en una sola tabla (por defecto TRUE).
#' @param nivel_confianza El nivel de confianza para los intervalos de confianza (por defecto, 0.95).
#' @param selecc_vars_auto Un valor lógico que indica si se deben seleccionar automáticamente las variables X si no se especifican (por defecto TRUE).
#' @param estrategia_valoresPerdidos La estrategia para manejar los valores perdidos (por defecto 'A').
#' @param simplificar_output Indica si se debe simplificar el output (por defecto, TRUE).
#'
#' @return Una lista con los resultados del análisis descriptivo, que incluye tanto los descriptivos para las variables X numéricas como categóricas.
#'         Los resultados están organizados en una lista con dos elementos: 'Numericas' y 'Categoricas', con los resultados correspondientes.
#'
#' @importFrom dplyr select any_of all_of bind_rows
#' @importFrom purrr map compact
#' @importFrom rlang sym
#'
#' @examples
#' library(analisisDescriptivo)
#' temp <- mtcars %>%
#'   mutate('cyl'=as.character(cyl),
#'          'carb'=factor(carb),
#'          'gear' = factor(gear),
#'          'grupo' = sample(c('A','B'),nrow(.),T),
#'          'w'=rlnorm(32),
#'          w_norm = rnorm(32)
#'   )
#'  generar_descriptivos_VDcategorica(
#'    datos = temp,
#'    var_VDcat = 'carb',
#'  )
#' @export
generar_descriptivos_VDcategorica <- function(
    datos,
    var_VDcat,
    vars_X = NULL,
    var_peso = NULL,
    variable_pivot = "var_grupo",
    estrategia_valoresPerdidos = 'A',
    nivel_confianza = 0.95,
    simplificar_output = T,
    selecc_vars_auto = T,
    num_unificar_1tabla = T
){
  if( is.null(vars_X) & selecc_vars_auto ){
    vars_X <- datos %>% select( -any_of(c(var_VDcat,var_peso)) ) %>% colnames()
  }

  datos_X <- datos %>% select( all_of(vars_X) )
  vars_X_num <- datos_X %>% select( all_of(vars_X) ) %>% select_if(is.numeric) %>% colnames()
  vars_X_fac <- datos_X %>% select( -all_of(vars_X_num) ) %>% colnames()

  descriptivos_num <- NULL
  descriptivos_cat <- NULL

  if( length(vars_X_num) > 0 ){
    descriptivos_num <- purrr::map(
      vars_X_num,
      function(x.i){
        generar_descriptivo_VDcategorica_varX(
          datos        = datos,
          var_VDcat   = var_VDcat,
          var_X = x.i,
          var_peso     = var_peso,
          nivel_confianza = nivel_confianza
        )
      } )  %>%
      set_names(vars_X_num)
    if(num_unificar_1tabla) descriptivos_num <- bind_rows( descriptivos_num )

  }
  if( length(vars_X_fac) > 0 ){

    descriptivos_cat <- purrr::map(
      vars_X_fac,
      \(x.i) generar_descriptivo_VDcategorica_varX(
        datos = datos,  var_VDcat = var_VDcat, var_X =  x.i, var_peso = var_peso,
        variable_pivot = variable_pivot, nivel_confianza = nivel_confianza,
        estrategia_valoresPerdidos = estrategia_valoresPerdidos,
        simplificar_output = simplificar_output
      )
    ) %>%
      set_names( vars_X_fac )

  }

  purrr::compact(  list('Numericas'=descriptivos_num,'Categoricas'=descriptivos_cat) )

}
