#' Generar descriptivos para una variable categórica
#'
#' Calcula las frecuencias, porcentajes y sus intervalos de confianza (Wilson) para una variable categórica,
#' opcionalmente agrupada y ponderada. Además, permite pivotear la tabla resultante a formato ancho si se está
#' trabajando con un tibble agrupado.
#'
#' @param datos Data frame o tibble que contiene la variable a analizar.
#' @param var_categorica Nombre (carácter) de la variable categórica.
#' @param vars_grupo Vector de nombres de variables de agrupación. Si \code{datos} ya está agrupado, se utilizarán
#'   los grupos definidos en el objeto.
#' @param var_peso Nombre (carácter) de la variable de pesos. Si es \code{NULL} (por defecto), se realizan recuentos simples.
#' @param pivot Lógico. Si \code{TRUE} (por defecto) y el data frame está agrupado, se pivota la tabla (wide)
#'   utilizando la variable de agrupación o la variable categórica, según lo definido en \code{variable_pivot}.
#' @param variable_pivot Vector de caracteres que indica la variable a utilizar para pivotear: \code{"var_grupo"} o
#'   \code{"var_categorica"}. Por defecto es \code{c("var_grupo", "var_categorica")}.
#' @param nivel_confianza Nivel de confianza para los intervalos. Por defecto es \code{0.95}.
#' @param estrategia_valoresPerdidos Estrategia para el manejo de valores faltantes en la variable categórica. Se debe elegir
#'   \code{"E"} para eliminar o \code{"A"} para agrupar (NS/NC). Por defecto es \code{c("E", "A")}, de modo que se selecciona
#'   \code{"E"}.
#' @param simplificar_output Por defecto \code{TRUE}. Cuando se calculan descriptivos agrupados reduce la cantidad de información
#' exportada en caso de pivotar.
#'
#' @return Data frame con los descriptivos calculados para la variable categórica, que incluye:
#' \itemize{
#'   \item \code{n}: Frecuencia (ponderada, si se especifica) de cada categoría.
#'   \item \code{n_sinW}: Frecuencia sin ponderar (solo si se especifica la variable de peso).
#'   \item \code{p}: Porcentaje calculado.
#'   \item \code{p_Min} y \code{p_Max}: Límites inferior y superior del intervalo de confianza, ajustados con el nivel de confianza.
#'   \item \code{sd}: Error estándar aproximado de la proporción.
#' }
#'
#' @details
#' La función realiza los siguientes pasos:
#' \enumerate{
#'   \item Se asegura que la variable categórica sea de tipo carácter, incluso si originalmente es numérica.
#'   \item Si \code{datos} está agrupado, se utiliza la(s) variable(s) de agrupación.
#'   \item Se cuentan las ocurrencias (ponderadas, si se especifica) de cada categoría.
#'   \item Se calcula el porcentaje de cada categoría. En caso de tener valores faltantes, se aplica la estrategia seleccionada:
#'         \describe{
#'           \item{\code{"E"}}{Elimina las observaciones faltantes (no se contabilizan en los porcentajes).}
#'           \item{\code{"A"}}{Agrupa los faltantes en la categoría \code{"NS/NC"}.}
#'         }
#'   \item Se ordena el resultado en función de la variable (descendente si es carácter, ascendente si es numérica).
#'   \item Se calculan intervalos de confianza utilizando el método de Wilson (se requiere la función \code{ci_margenError_pWilson}).
#'   \item Si \code{pivot} es \code{TRUE} y el data frame está agrupado, se pivota la tabla a formato ancho.
#'   \item Se añaden sufijos en los nombres de los intervalos de confianza según el nivel de confianza.
#' }
#'
#' @examples
#' \dontrun{
#'   library(dplyr)
#'   # Sin agrupación y sin pesos
#'   mtcars$cyl <- factor(mtcars$cyl)
#'   mtcars$vs <- factor(mtcars$vs)
#'   resultado <- generar_descriptivo_categorico(
#'                  datos = mtcars,
#'                  var_categorica = "cyl",
#'                  nivel_confianza = 0.95,
#'                  estrategia_valoresPerdidos = "E"
#'                )
#'
#'   # Con agrupación y pesos (suponiendo que 'w' es la variable de peso)
#'   mtcars$w <- rlnorm(32) # añadimos pesos
#'   resultado2 <- generar_descriptivo_categorico(
#'    datos = mtcars,
#'    var_categorica = "vs",
#'    vars_grupo = 'gear',
#'    var_peso = "w",
#'    pivot = TRUE,
#'    variable_pivot = "var_grupo",
#'    nivel_confianza = 0.95,
#'    estrategia_valoresPerdidos = "A"
#'   )
#' }
#'
#' generar_descriptivo_categorico( temp, 'cyl' )
#' generar_descriptivo_categorico( temp, 'cyl', 'vs' )
#' generar_descriptivo_categorico( temp, 'cyl', var_peso = 'w' )
#' generar_descriptivo_categorico( temp, 'cyl', 'vs', var_peso = 'w' )
#'
#' @importFrom dplyr is.grouped_df group_vars group_by count mutate left_join filter if_else arrange desc ungroup select relocate all_of any_of rename_with `%>%`
#' @importFrom tidyr pivot_wider
#' @importFrom stringr str_split_i
#' @importFrom rlang sym syms
#'
#' @export
generar_descriptivo_categorico <- function(
    datos,
    var_categorica,
    vars_grupo = NULL,
    var_peso = NULL,
    pivot = TRUE,
    variable_pivot = c("var_grupo", "var_categorica"),
    nivel_confianza = 0.95,
    estrategia_valoresPerdidos = c("E", "A"),
    simplificar_output = TRUE
) {
  # Convertir la variable categórica a carácter si es numérica
  if (is.numeric(datos[[var_categorica]])) {
    datos[[var_categorica]] <- as.character(datos[[var_categorica]])
  }

  if ( !is.null(var_peso) ) {
    if(!is.numeric(datos[[var_peso]])) datos[[var_peso]] <- as.numeric(datos[[var_peso]])
  }

  # Si 'datos' está agrupado, se usan las variables de agrupación definidas en el objeto
  if (is.grouped_df(datos)) {
    vars_grupo <- group_vars(datos)
  }

  # Si se especifican variables de agrupación, agrupar
  if ( !is.null(vars_grupo) ) {
    if( !is.factor(datos[[vars_grupo]]) ) datos[[vars_grupo]] <- factor(datos[[vars_grupo]])

    datos <- datos %>% group_by(!!!syms(vars_grupo))

  }
  # Crear símbolo para la variable categórica (evaluación tidy)
  var_sym <- sym(var_categorica)

  # Manejo de valores faltantes
  if (!any(is.na(datos[[var_categorica]]))) {
    estrategia_valoresPerdidos <- match.arg(estrategia_valoresPerdidos)
    if (estrategia_valoresPerdidos == "E") {
      # Eliminar faltantes para el cálculo de recuentos porcentajes
      datos <- datos %>% filter(!is.na(!!var_sym))

    } else if (estrategia_valoresPerdidos == "A") {
      # Agrupar faltantes bajo la categoría "NS/NC"
      datos[[var_categorica]] <- if_else(is.na(datos[[var_categorica]]),"NS/NC", datos[[var_categorica]])
    }
  }

    # Calcular recuentos: SI NO HAY PONDERACION
  if (is.null(var_peso)) {
    salida <- datos %>%
      count_p(!!var_sym) %>%
      mutate(
        'N_eff' = sum(n),
        'sd' = sqrt(p * (1 - p) / N_eff),
      )

  } else { # SI HAY PONDERACION
    w_sym <- sym(var_peso)
    # calculamos la N y los porcentajes
    salida <- datos %>%
      count_p(!!var_sym, wt = !!w_sym) %>%
      mutate( n = round(n, 1) )

    # pero necesitamos la N efectiva para la desv.est y los intervalos
    n_efectiva <- datos %>% summarise('N_eff' = calcular_Nefectiva(!!w_sym) )
    message("Los intervalos de confianza de las proporciones se calculan mediante la N efectiva")
    # si esta agrupado o no, ajustamos el join
    salida <- if( !is.grouped_df(datos) ){

      salida <- bind_cols( salida, n_efectiva )

    } else { # SI ES AGRUPADO EJECUTAMOS UN JOIN
      salida <- left_join( salida, n_efectiva )

    }
    # calculamos la sd
    salida <- salida %>%
      mutate( 'sd' = sqrt(p * (1 - p) / N_eff) )
    # añadimos la N sin ponderacion
    salida <- salida %>%
      left_join(
        datos %>% count(!!var_sym, name = 'n_sinW') %>% mutate('p_sinW'=n_sinW/sum(n_sinW))
      )
  }

  # Calcular intervalos: se utiliza la función ci_margenError_pWilson (debe estar definida en el paquete)
  salida <- salida %>% mutate(

    p_Min = intervalo_confianza_pWilson(p = p, N = N_eff, nivel_confianza = nivel_confianza, limite = "inferior"),
    p_Max = intervalo_confianza_pWilson(p = p, N = N_eff, nivel_confianza = nivel_confianza, limite = "superior"),
    .after = p
  ) %>%
    # select(-N_eff) %>%
    relocate(sd, .after = p_Max)

  # Ordenar los resultados: descendente si la variable es de tipo carácter, por levels si es factor
  if (is.character(datos[[var_categorica]])) {
    salida <- salida %>% arrange(desc(p))
  } else {
    salida <- salida %>% arrange(!!sym(var_categorica))
  }

  # Pivotear la tabla si se solicita y si 'datos' está agrupado
  if (pivot && is.grouped_df(datos)) {
    # Determinar la variable a utilizar para pivotear
    variable_pivot <- match.arg(variable_pivot)
    if (variable_pivot != "var_grupo") {
      variable_pivot <- var_categorica
    } else {
      variable_pivot <- vars_grupo
    }

    valores_pivot_init <- c("p", "p_Min", "p_Max", "n","sd","p_sinW", "n_sinW", 'N','N_eff')
    # Definir los valores a pivotear
    if( simplificar_output ){

      valores_pivot <- c("p", "n","p_sinW")
      eliminar_variables <- setdiff(valores_pivot_init,valores_pivot)
      salida <- salida %>% select(-any_of(eliminar_variables))

    } else {
      valores_pivot <- valores_pivot_init
    }

    salida <- salida %>%
      ungroup() %>%
      tidyr::pivot_wider(
        names_from  = all_of(variable_pivot),
        values_from = any_of(valores_pivot),
        names_glue = "{.name}_{.value}"
      )

    # Ajustar nombres de columnas eliminando prefijos no deseados
    # return(colnames(salida))
    colnames(salida) <- gsub("^(p_Min_|p_Max_|sd_|p_sinW_|N_eff_|n_sinW_|n_|p_|N_)", "", colnames(salida))

    salida <- salida %>%
      # añado nombre de variable alas primeras columnas para identificar el nombrede la variable
      rename_with(
        .cols = ends_with('_p'),
        .fn = \(x) paste0(variable_pivot,'_',x)
      )
  }

  # AÑADIMOS SI HAY DIFERENCIAS SIGNIFICATIVSA Y LA V DE CRAMER
  if( is.grouped_df(datos) ){
    pesos <- if( !is.null(var_peso) ) datos[[var_peso]] else rep(1,nrow(datos))
    resultado_chi2 <- calcular_chi2( var1 = datos[[var_categorica]], var2 = datos[[vars_grupo]],weight = pesos )
    Vcramer <- calcular_VCramer(resultado_chi2 = resultado_chi2)

    salida <- salida %>%
      mutate(
        'Chi2' = c( resultado_chi2$Chisq, rep(NA, nrow(salida)-1) ),
        'p_value' = c( resultado_chi2$p.value, rep(NA, nrow(salida)-1) ),
        'VCramer' = c( Vcramer, rep(NA, nrow(salida)-1) )
      )
  }

  # Añadir sufijo a los nombres de los intervalos según el nivel de confianza (por ejemplo, 95 para 0.95)
  if( !simplificar_output ){
    # en caso de no haber simplificado
    chr_nivel <- as.character(stringr::str_split_i(as.character(nivel_confianza), "\\.", 2))
    salida <- salida %>%
      rename_with(
        .cols = contains(c("_Min", "_Max")),
        .fn = \(x) paste0(x, "_", chr_nivel)
      )
  }

  attr(salida,'tipo_tabla') <- 'categorica'
  attr(salida,'vars_grupo') <- !is.null(vars_grupo)

  salida
}

