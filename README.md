
<!-- README.md is generated from README.Rmd. Please edit that file -->

# analisisDescriptivo

<!-- badges: start -->
<!-- badges: end -->

`analisisDescriptivo` es un paquete de R diseñado para facilitar la
generación de estadísticas descriptivas para variables numéricas y
categóricas. Proporciona funciones para análisis univariado, análisis
agrupado (bivariado) y herramientas para formatear los resultados para
su exportación, por ejemplo, a Excel. Además, calcula los intervalos de
confianza de las medias y proporciones (con y sin variable de
ponderación), calcula si las diferencias de medias son significativas
entre grupos (a través de OLS) y si hay diferencia significativa entre
dos variables categóricas (mediante chi cuadrado).

## Advertencia

Actualmente, una parte de este documento así como la mayor parte de
documentación de las funciones está elaborado principalmente a través
del modelo 03-mini de ChatGPT, por lo que puede haber algún error.
Tampoco se explica, por ahora, con todo detalle las funcionalidades del
paquete. Esta tarea está pendiente de llevarse a cabo.

## Objetivo

El objetivo o razón de ser de este paquete es automatizar la tarea de
explotación de datos habitual:

- Descriptivos univariados

- Descriptivos agrupados por una variabel categórica clave: Tratamiento
  vs Control; Territorio; u cualquier otra variable categórica. Además,
  identifica si existen diferencias significativas.

Por ahora **no se recogen funcionalidades para analizar la relación
entre variables numéricas**. El análisis bivariado se realiza entre:

- Variable Categórica y Variables Categóricas

- Variable Categórica y Variables Numéricas

En futuras actualizaciones se incorporará el análisis entre numéricas

## Características

- **Análisis descriptivo univariado para variables categóricas:**
  Calcula frecuencias, porcentajes y sus intervalos de confianza (usando
  el método de Wilson) para variables categóricas (con o sin ponderar).

<!-- -->

- **Análisis descriptivo univariado para variables numéricas:** Obtén
  estadísticas básicas (media, mediana, cuartiles, desviación estándar,
  histograma ) de variables numéricas (con o sin ponderar)..

<!-- -->

- **Análisis descriptivo agrupado:** Genera de forma sencilla
  descriptivos numéricos y categóricos agrupando por las categorías de
  una variable categórica.

<!-- -->

- **Exportación a Excel:** Exporta a Excel los resultados ya formateadas
  en una o varias hojas.

## Instalación

Puedes instalar la versión de desarrollo de `analisisDescriptivo` desde
GitHub con:

``` r
# install.packages("remotes")
remotes::install_github("Adan-gz/analisisDescriptivo")
```

## Dependencias

Para utilizar el paquete es necesario instalar estos paquetes: dplyr,
emmeans, magrittr, openxlsx, purrr, rlang, scales, skimr, stringr,
tibble, tidyr. Para hacerlo se puede utilizar la función
`install.packages`.

## Uso Rápido

Las funciones principales del paquete son 3:

1.  `generar_descriptivos_univariados`: generar los descriptivos
    univariados de variables categóricas y numéricas. Si no se indican
    cuáles se seleccionan de manera automática.
2.  `generar_descriptivos_agrupados`: calcula estadísticis descriptivos
    de variables categóricas y numéricas según las categorías de la
    variable categórica indicada.
3.  `crear_Excel`: genera un workbook a través de `openxlsx` y exporta
    el archivo Excel ya formateado.

**Ahora mismo las funciones no están diseñadas para poder pasar más de 1
variable de agrupación**. Podría funcionar, pero el comportamiento es
imprevisto. Si se quiere agrupar por más de 1 variable la estrategia más
sencilla es: crear una nueva variable uniendo los valores de cada fila
de ambas y pasarle a la función esta nueva variable.

A continuación, se muestra un ejemplo básico que ilustra cómo generar
estadísticas descriptivas utilizando el paquete:

``` r

library(analisisDescriptivo)
library(dplyr)
# creamos un tibble temporal a partir de los datos mtcars que vienen por defecto en R
temp <- mtcars %>%
  mutate('cyl'   = as.character(cyl),
         'carb'  = factor(carb),
         'gear'  = factor(gear),
         # una variable para agrupar
         'grupo' = sample(c('Tratamiento','Control'),nrow(.),T),
         # añadimos un vector de pesos
         'pesos'     = rlnorm(32)
         )

# Análisis descriptivo univariado (tanto numérico como categórico)
resultados_univ <- generar_descriptivos_univariados( 
  datos     = temp,
  selecc_vars_auto = TRUE, # dejamos que seleccione las variables automáticamente
  var_peso  = "pesos", # vector para ponderar
  num_unificar_1tabla = TRUE # por defecto devuelve una lista, donde cada elemento son los descriptivos de cada variable. Con este argumento en TRUE devuelve un dataframe con todas las variables juntas
)
```

El output obtenido se ve de esta forma en la consola de R:

``` r
print(resultados_univ)
#> $Numericas
#> # A tibble: 9 × 15
#>   Variable     N Missing   Media Media_w Media_w_Min_95 Media_w_Max_95     Min
#>   <chr>    <int>   <int>   <dbl>   <dbl>          <dbl>          <dbl>   <dbl>
#> 1 mpg         32       0  20.1    17.1           15.0           19.2   10.4   
#> 2 disp        32       0 231.    289.           242.           336.    71.1   
#> 3 hp          32       0 147.    164.           141.           188.    52     
#> 4 drat        32       0   3.60    3.33           3.14           3.52   2.76  
#> 5 wt          32       0   3.22    3.73           3.34           4.12   1.51  
#> 6 qsec        32       0  17.8    17.7           17.2           18.2   14.5   
#> 7 vs          32       0   0.438   0.315          0.145          0.486  0     
#> 8 am          32       0   0.406   0.272          0.109          0.435  0     
#> 9 pesos       32       0   1.17    2.79           1.95           3.64   0.0935
#> # ℹ 7 more variables: Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>,
#> #   sd_w <dbl>, hist <chr>
#> 
#> $Categoricas
#> $Categoricas$cyl
#>   cyl    n         p      p_Min     p_Max         sd N_eff n_sinW  p_sinW
#> 1   8 24.1 0.6451121 0.38434606 0.8410933 0.13086892  13.4     14 0.43750
#> 2   4  8.1 0.2165658 0.07519825 0.4844714 0.11265993  13.4     11 0.34375
#> 3   6  5.2 0.1383222 0.03705734 0.4010567 0.09442602  13.4      7 0.21875
#> 
#> $Categoricas$gear
#>   gear    n          p      p_Min     p_Max         sd N_eff n_sinW  p_sinW
#> 1    3 25.0 0.67084080 0.40743872 0.8579717 0.12852454  13.4     15 0.46875
#> 2    4  9.4 0.25283573 0.09537485 0.5206422 0.11887775  13.4     12 0.37500
#> 3    5  2.8 0.07632347 0.01379553 0.3280002 0.07262102  13.4      5 0.15625
#> 
#> $Categoricas$carb
#>   carb    n           p        p_Min     p_Max         sd N_eff n_sinW  p_sinW
#> 1    1  7.2 0.193518402 6.313918e-02 0.4607252 0.10805172  13.4      7 0.21875
#> 2    2 10.4 0.279462692 1.110396e-01 0.5463438 0.12273360  13.4     10 0.31250
#> 3    3  3.9 0.103476690 2.304364e-02 0.3609361 0.08330583  13.4      3 0.09375
#> 4    4 14.5 0.387786011 1.812697e-01 0.6443999 0.13326651  13.4     10 0.31250
#> 5    6  0.2 0.004506343 6.853678e-05 0.2301554 0.01831912  13.4      1 0.03125
#> 6    8  1.2 0.031249862 2.820456e-03 0.2689510 0.04758864  13.4      1 0.03125
#> 
#> $Categoricas$grupo
#>         grupo    n         p     p_Min     p_Max       sd N_eff n_sinW  p_sinW
#> 1     Control 18.7 0.5000291 0.2637901 0.7362550 0.136755  13.4     19 0.59375
#> 2 Tratamiento 18.7 0.4999709 0.2637450 0.7362099 0.136755  13.4     13 0.40625
#> 
#> 
#> attr(,"peso")
#> [1] TRUE
```

Y se puede exportar a Excel de esta forma:

``` r
workbook <- crear_Excel(
  list_list_tablas    = resultados_univ, 
  unificar_misma_hoja = TRUE,
  titulos_principales = 'DESCRIPTIVOS UNIVARIADOS', 
  exportar            = TRUE,
  nombre_archivo      = 'Descriptivos_Univariados' 
)
```

Así se vería:

![](img/Imagen1.png)

Si queremos obtener los descriptivos agrupads por `grupo` bastaría con:

``` r
# Análisis descriptivo univariado (tanto numérico como categórico)
resultados_agrupados <- generar_descriptivos_agrupados( 
  datos      = temp,
  # podriamos indicar las variables de intereres con 'vars_categoricas' y 'vars_numericas', pero dejamos que seleccione las variables automáticamente
  vars_grupo = 'grupo',
  var_peso   = "pesos", # vector para ponderar
  num_unificar_1tabla = FALSE # en este caso no queremos que unifique
)
```

Y así podríamos añadirlo al workbook existente y exportar un nuevo
excel:

``` r
crear_Excel(
  workbook            = workbook,
  list_list_tablas    = resultados_agrupados,
  unificar_misma_hoja = TRUE, # unificamos 
  nombres_hojas       = 'Hoja_Agrupada', # ponemos nombre a la hoja
  titulos_principales = 'DESCRIPTIVOS AGRUPADOS', 
  exportar            = TRUE,
  nombre_archivo      = 'Descriptivos_Univariados_y_Agrupados' 
)
#> A Workbook object.
#>  
#> Worksheets:
#>  Sheet 1: "Hoja 1"
#>  
#> 
#>  Sheet 2: "Hoja_Agrupada"
#>  
#> 
#>  
#>  Worksheet write order: 1, 2
#>  Active Sheet 1: "Hoja 1" 
#>  Position: 1
```

Y este sería el output (se muestra sólo la segunda hoja):

![](img/Imagen2.png)

Únicamente es necesario crear el workbook (`workbook <- crear_Excel()`)
la primera vez. Las siguientes al llamar la función `crear_Excel()` ya
se actualiza el objeto creado de forma automática.

## Uso específico

El paquete incluye funciones para personalizar el análisis:

- **`generar_descriptivo_categorico`**: Genera estadísticas descriptivas
  para una variable categórica.

- **`generar_descriptivo_numerico`**: Genera estadísticas descriptivas
  para una variable numérica.

- **`preparar_tabla_excel`**: Prepara una tabla para su exportación a
  Excel, incluyendo encabezados y formateo.

- **`concatenar_tablas_excel`**: Concatena múltiples tablas (tibbles) en
  un único data frame, separadas por filas vacías.

Consulta la documentación de cada función (por ejemplo,
`?generar_descriptivo_categorico`) para obtener más detalles.

## Contribución

¡Las contribuciones, informes de errores y solicitudes de nuevas
funcionalidades son bienvenidos!  
Por favor, abre un issue o envía un pull request en
[GitHub](https://github.com/Adan-gz/analisisDescriptivo).

## Licencia

Este paquete está disponible bajo la Licencia MIT.
