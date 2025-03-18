
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

## Dependencias

Para utilizar este paquete es necesario tener instalados los siguientes
paquetes: `dplyr`, `emmeans`, `magrittr`, `openxlsx`, `purrr`, `rlang`,
`scales`, `skimr`, `stringr`, `tibble`, `tidyr`.

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
#>   Variable     N Missing   Media Media_w Media_w_Min_95 Media_w_Max_95    Min
#>   <chr>    <int>   <int>   <dbl>   <dbl>          <dbl>          <dbl>  <dbl>
#> 1 mpg         32       0  20.1    18.9           16.7           21.1   10.4  
#> 2 disp        32       0 231.    261.           213.           309.    71.1  
#> 3 hp          32       0 147.    156.           130.           182.    52    
#> 4 drat        32       0   3.60    3.48           3.30           3.65   2.76 
#> 5 wt          32       0   3.22    3.59           3.20           3.98   1.51 
#> 6 qsec        32       0  17.8    18.0           17.4           18.6   14.5  
#> 7 vs          32       0   0.438   0.402          0.223          0.582  0    
#> 8 am          32       0   0.406   0.292          0.126          0.459  0    
#> 9 pesos       32       0   1.16    1.88           1.47           2.29   0.101
#> # ℹ 7 more variables: Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>,
#> #   sd_w <dbl>, hist <chr>
#> 
#> $Categoricas
#> $Categoricas$cyl
#>   cyl    n         p      p_Min     p_Max         sd N_eff n_sinW  p_sinW
#> 1   8 20.4 0.5488134 0.33985675 0.7418655 0.11200346  19.7     14 0.43750
#> 2   4 12.4 0.3331264 0.16813960 0.5524843 0.10608825  19.7     11 0.34375
#> 3   6  4.4 0.1180602 0.03594178 0.3246228 0.07262936  19.7      7 0.21875
#> 
#> $Categoricas$gear
#>   gear    n         p      p_Min     p_Max         sd N_eff n_sinW  p_sinW
#> 1    3 20.0 0.5399006 0.33212796 0.7346728 0.11218214  19.7     15 0.46875
#> 2    4 12.5 0.3381962 0.17179314 0.5573185 0.10648538  19.7     12 0.37500
#> 3    5  4.5 0.1219031 0.03778544 0.3292129 0.07364099  19.7      5 0.15625
#> 
#> $Categoricas$carb
#>   carb    n          p       p_Min     p_Max         sd N_eff n_sinW  p_sinW
#> 1    1  5.8 0.15510507 0.054748119 0.3678362 0.08148081  19.7      7 0.21875
#> 2    2 11.6 0.31393900 0.154495982 0.5340047 0.10445879  19.7     10 0.31250
#> 3    3  6.0 0.16266202 0.058844230 0.3763918 0.08306814  19.7      3 0.09375
#> 4    4 11.4 0.30626472 0.149122172 0.5265304 0.10374959  19.7     10 0.31250
#> 5    6  0.9 0.02431833 0.002460882 0.2011632 0.03467065  19.7      1 0.03125
#> 6    8  1.4 0.03771085 0.005395103 0.2206504 0.04287725  19.7      1 0.03125
#> 
#> $Categoricas$grupo
#>         grupo    n         p     p_Min     p_Max      sd N_eff n_sinW p_sinW
#> 1     Control 25.6 0.6902045 0.4700249 0.8484115 0.10408  19.7     20  0.625
#> 2 Tratamiento 11.5 0.3097955 0.1515885 0.5299751 0.10408  19.7     12  0.375
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

## Detalles

Para conocer mejor los parámetros de las funciones puede consultar la
documentación de cada una, (por ejemplo,
`?generar_descriptivos_categoricos`) para obtener más detalles.

## Contribución

¡Las contribuciones, informes de errores y solicitudes de nuevas
funcionalidades son bienvenidos!  
Por favor, abre un issue o envía un pull request en
[GitHub](https://github.com/Adan-gz/analisisDescriptivo).

## Licencia

Este paquete está disponible bajo la Licencia MIT.
