#' Generar descriptivo para una variable numérica
#'
#' Calcula medidas descriptivas básicas para una variable numérica, incluyendo conteos, estadísticos (media, mediana, cuantiles, etc.),
#' desviación estándar y un histograma inline. Además, calcula intervalos de confianza para la media y, si se especifica una variable de pesos,
#' se calculan estadísticas ponderadas. Internamente se utiliza \code{lm} y \code{emmeans} para obtener los intervalos, especialmente relevante
#' en el caso de agrupar.
#'
#' @param datos Data frame o tibble que contiene la variable numérica a analizar.
#' @param var_numerica Nombre (carácter) de la variable numérica a analizar.
#' @param vars_grupo Vector de nombres de variables para agrupar. Si es \code{NULL} (por defecto), no se realiza agrupamiento.
#' @param var_peso Nombre (carácter) de la variable de peso. Si es \code{NULL} (por defecto), se calculan estadísticas sin ponderar.
#' @param nivel_confianza Nivel de confianza para el cálculo de intervalos (por defecto \code{0.95}).
#' @param estrategia_valoresPerdidos_grupo Estrategia para el manejo de valores faltantes en la variable de agrupación. Se debe elegir
#'   \code{"E"} para eliminar o \code{"A"} para agrupar (NS/NC). Por defecto es \code{c("A", "E")}, de modo que se selecciona
#'   \code{"E"}.
#'
#' @return Data frame con las estadísticas descriptivas calculadas. Entre las variables se incluyen:
#' \itemize{
#'   \item \code{Variable}: Nombre de la variable.
#'   \item \code{N}: Número de observaciones completas.
#'   \item \code{Missing}: Número de observaciones faltantes.
#'   \item \code{Media}: Promedio de la variable.
#'   \item \code{Min}: Valor mínimo.
#'   \item \code{Q25}: Primer cuartil.
#'   \item \code{Mediana}: Mediana.
#'   \item \code{Q75}: Tercer cuartil.
#'   \item \code{Max}: Valor máximo.
#'   \item \code{sd}: Desviación estándar.
#'   \item \code{hist}: Histograma inline.
#'   \item \code{Media_Min} y \code{Media_Max} (o \code{Media_w_Min} y \code{Media_w_Max} en caso de ponderación): Límites inferior y superior del intervalo de confianza.
#' }
#'
#' @details
#' La función realiza los siguientes pasos:
#' \enumerate{
#'   \item Se asegura que la variable sea de tipo \code{numeric}.
#'   \item Si se especifican variables de agrupación, se agrupa el data frame.
#'   \item Se calculan medidas descriptivas básicas utilizando \code{dplyr::summarise} y funciones de \code{skimr}.
#'   \item Si no se especifica una variable de peso, se calcula el intervalo de confianza para la media basándose en
#'         el conteo (\code{N}) y la desviación estándar (\code{sd}) mediante la función \code{margenError_num}.
#'   \item Si se especifica la variable de peso, se calculan la media y desviación estándar ponderadas, además del
#'         tamaño muestral efectivo (\code{N_eff}), y se computan los intervalos correspondientes.
#'   \item Se renombrarán las columnas de intervalos, añadiéndoles un sufijo que indica el nivel de confianza.
#' }
#'
#' @examples
#' \dontrun{
#'   # Ejemplo sin ponderación:
#'   resumen <- generar_descriptivo_numerico(
#'                datos = mtcars,
#'                var_numerica = "mpg",
#'                nivel_confianza = 0.95
#'              )
#'
#'   # Ejemplo con ponderación (suponiendo que 'wt' es la variable de peso):
#'   resumen_ponderado <- generar_descriptivo_numerico(
#'                           datos = mtcars,
#'                           var_numerica = "mpg",
#'                           var_peso = "wt",
#'                           nivel_confianza = 0.95
#'                         )
#' }
#'
#' @importFrom dplyr group_by summarise mutate left_join full_join bind_cols filter relocate ends_with `%>%`
#' @importFrom tibble as_tibble
#' @importFrom skimr n_complete n_missing inline_hist
#' @importFrom rlang sym syms
#' @importFrom stringr str_split_i
#' @importFrom emmeans emmeans
#' @importFrom forcats fct_na_level_to_value
#'
#' @export
generar_descriptivo_numerico <- function(
    datos,
    var_numerica,
    vars_grupo = NULL,
    var_peso = NULL,
    nivel_confianza = 0.95,
    estrategia_valoresPerdidos_grupo = c('A','E')
) {
  # Asegurarse de que la variable es de tipo numeric
  if( !var_numerica %in% colnames(datos) ){
    stop("La variable numérica ", var_numerica ," no se encuentra en la matriz de datos")
  }

  if ( !is.numeric(datos[[var_numerica]]) ) {
    datos[[var_numerica]] <- as.numeric(datos[[var_numerica]])
  }

  if ( !is.null(var_peso)  ) {

    if( !var_peso %in% colnames(datos) ){
      stop("La variable de ponderación ", var_peso ," no se encuentra en la matriz de datos")
    }

    if( !is.numeric(datos[[var_peso]]) )  datos[[var_peso]] <- as.numeric(datos[[var_peso]])
  }

  if( is.grouped_df(datos) ){
    vars_grupo <- group_vars(  datos)
  }

  if ( !is.null(vars_grupo) ) {

    if( !vars_grupo %in% colnames(datos) ){
      stop("La variable de agrupación ", vars_grupo, " no se encuentra en la matriz de datos")
    }

    if( !is.factor(datos[[vars_grupo]]) ) datos[[vars_grupo]] <- factor(datos[[vars_grupo]])

    # Manejo de valores faltantes
    if (any(is.na(datos[[vars_grupo]]))) {
      estrategia_valoresPerdidos_grupo <- match.arg(estrategia_valoresPerdidos_grupo)
      if (estrategia_valoresPerdidos_grupo == "E") {
        # Eliminar faltantes para el cálculo de recuentos porcentajes
        datos <- datos %>% filter(!is.na(!!sym(vars_grupo)))

      } else if (estrategia_valoresPerdidos_grupo == "A") {
        # Agrupar faltantes bajo la categoría "NS/NC"
        datos[[vars_grupo]] <- forcats::fct_na_value_to_level( datos[[vars_grupo]],"NS/NC")

      }
    }

    # Si se especifican variables de agrupación, agrupar el data frame
    datos <- datos %>% group_by(!!!syms(vars_grupo))

  }

  # Si se especifica la variable de peso, crear símbolo para evaluación tidy
  # if (!is.null(var_peso)) {
  #   w_sym <- sym(var_peso)
  # }


  # Crear símbolo para la variable numérica
  var_sym <- sym(var_numerica)

  # Calcular medidas descriptivas básicas usando funciones de skimr y dplyr
  salida <- datos %>%
    dplyr::summarise(
      Variable = var_numerica,
      N = skimr::n_complete(!!var_sym),
      Missing = skimr::n_missing(!!var_sym),
      Media = mean(!!var_sym, na.rm = TRUE),
      Min = min(!!var_sym, na.rm = TRUE),
      Q25 = quantile(!!var_sym, 0.25, na.rm = TRUE),
      Mediana = median(!!var_sym, na.rm = TRUE),
      Q75 = quantile(!!var_sym, 0.75, na.rm = TRUE),
      Max = max(!!var_sym, na.rm = TRUE),
      sd = sd(!!var_sym, na.rm = TRUE),
      hist = skimr::inline_hist(!!var_sym),
      .groups = "drop"
    )

  if( !is.null(var_peso) ){
    # de caro a los modelos utilizo una variable con nombre conocido para que lm() pueda evaluarla correctamente
    datos <- datos %>% mutate( 'pesos_mod' = !!sym(var_peso)  )

  }

  # Calculamos los intervalos de confianza, ajustamos codigo segun si esta agrupado o no
  if (is.grouped_df(datos)) {
    if( is.null( var_peso ) ){

      model_lm <- tryCatch(
        lm( obtener_formula( VD = var_numerica, Xs = vars_grupo ), data = datos ),
        error = function(e){
          message( 'No ha sido posible realizar la regresión OLS entre ', var_numerica, ' ~ ',vars_grupo  )
          NULL
        }
      )

      if( !is.null(model_lm) ){

        IC_media_grupos <- model_lm %>%
          emmeans::emmeans( specs = vars_grupo, level = nivel_confianza ) %>%
          as_tibble() %>%
          select(1, 'Media_Min'=lower.CL, 'Media_Max'=upper.CL)

        salida <- IC_media_grupos %>%
          full_join(salida) %>%
          relocate(Media_Min, Media_Max, .after = Media)

        # Añadir diferencia de medias
        dif_medias <- obtener_diferencia_medias( model_lm, var_grupo =  vars_grupo )

        salida <- salida %>%
          left_join(dif_medias) %>%
          relocate( Dif_categoriaReferencia, p_value, .after= Media )

      }

    } else { # CON PESOS
      model_lm <- tryCatch(
        lm( obtener_formula( VD = var_numerica, Xs = vars_grupo ), data = datos, weights = pesos_mod ),
        error = function(e){
          message( 'No ha sido posible realizar la regresión OLS ponderada entre ', var_numerica, ' ~ ',vars_grupo  )
          NULL
        }
      )
      if( !is.null(model_lm) ){

        IC_media_grupos <- model_lm %>%
          emmeans::emmeans( specs = vars_grupo, level = nivel_confianza ) %>%
          as_tibble() %>%
          select(1, 'Media_w' = emmean, 'Media_w_Min'=lower.CL, 'Media_w_Max'=upper.CL)

        salida <- IC_media_grupos %>%
          full_join(salida) %>%
          relocate(Media_w, Media_w_Min, Media_w_Max, .after = Media)

        dif_medias <- obtener_diferencia_medias( model_lm, var_grupo =  vars_grupo )

        salida <- salida %>%
          left_join(dif_medias) %>%
          relocate( Dif_categoriaReferencia, p_value, .after= Media_w )
      }

      # añado la desviacion estandar ponderada
      salida <- salida %>%
        left_join(
          datos %>%
            dplyr::summarise(
              'sd.w' = desviacion_estandar_ponderada(!!var_sym, pesos = pesos_mod )
            )
        ) %>%
        relocate(sd.w, .after = sd)


    }

    # Si no esta agrupado ajustamos las formulas de de lm y usamos emmeans
  } else {
    if( is.null( var_peso ) ){
      ## IC para media sin ponderacion
      IC_media <-  lm( obtener_formula( VD = var_numerica, Xs = 1 ), data = datos  ) %>%
        emmeans::emmeans( specs = ~1, level = nivel_confianza ) %>%
        as_tibble() %>%
        select( 'Media_Min'=lower.CL, 'Media_Max'=upper.CL)

      salida <- IC_media %>%
        bind_cols(salida) %>%
        relocate(Media_Min, Media_Max, .after = Media)

    } else {
      ## IC para media con ponderacion
      IC_media <-  lm( obtener_formula( VD = var_numerica, Xs = 1 ), data = datos, weights = pesos_mod  ) %>%
        emmeans::emmeans( specs = ~1, level = nivel_confianza ) %>%
        as_tibble() %>%
        select('Media_w' = emmean, 'Media_w_Min'=lower.CL, 'Media_w_Max'=upper.CL)

      salida <- IC_media %>%
        bind_cols(salida) %>%
        relocate(Media_w, Media_w_Min, Media_w_Max, .after = Media)

      # añado la desviacion estandar ponderada
      salida <- salida %>%
        bind_cols(
          datos %>%
            dplyr::summarise(
              'sd_w' = desviacion_estandar_ponderada(!!var_sym, pesos = pesos_mod )
            )
        ) %>%
        relocate(sd_w, .after = sd)
    }
  }


  # Renombrar columnas de intervalos añadiendo un sufijo que indica el nivel de confianza
  if( any( grepl('_Min',colnames(salida)) ) & any( grepl('_Max',colnames(salida)) )   ){
    salida <- salida %>%
      rename_with(
        .cols = ends_with(c("_Min", "_Max")),
        .fn = function(x){ paste0(x, "_", as.character(stringr::str_split_i(as.character(nivel_confianza), "\\.", 2))) }
      )
  }

  attr(salida,'tipo_tabla') <- 'numerica'
  attr(salida,'vars_grupo') <- !is.null(vars_grupo)

  salida
}

