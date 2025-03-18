
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
`scales`, `skimr`, `stringr`, `tibble`, `tidyr`. Para hacerlo se puede
utilizar la función `install.packages`.

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
  num_unificar_1tabla = TRUE # por defecto devuelve una lista, donde cada elemento son los descriptivos de cada variable. Con este argumento en TRUE devuelve un dataframe con todas las variables juntas, pero sólo para los descriptivos numéricos
)
```

El output obtenido se ve de esta forma en la consola de R:

``` r
print(resultados_univ)
#> $Numericas
#> # A tibble: 9 × 15
#>   Variable     N Missing   Media Media_w Media_w_Min_95 Media_w_Max_95     Min
#>   <chr>    <int>   <int>   <dbl>   <dbl>          <dbl>          <dbl>   <dbl>
#> 1 mpg         32       0  20.1    21.3           18.7           23.9   10.4   
#> 2 disp        32       0 231.    212.           166.           259.    71.1   
#> 3 hp          32       0 147.    150.           120.           179.    52     
#> 4 drat        32       0   3.60    3.69           3.50           3.88   2.76  
#> 5 wt          32       0   3.22    3.05           2.64           3.45   1.51  
#> 6 qsec        32       0  17.8    17.7           17.1           18.4   14.5   
#> 7 vs          32       0   0.438   0.482          0.299          0.665  0     
#> 8 am          32       0   0.406   0.550          0.367          0.732  0     
#> 9 pesos       32       0   1.61    3.02           2.42           3.62   0.0532
#> # ℹ 7 more variables: Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>,
#> #   sd_w <dbl>, hist <chr>
#> 
#> $Categoricas
#> $Categoricas$cyl
#>   cyl    n         p      p_Min     p_Max        sd N_eff n_sinW  p_sinW
#> 1   4 21.2 0.4103265 0.21555566 0.6379610 0.1188737  17.1     11 0.34375
#> 2   8 19.9 0.3852223 0.19687796 0.6156304 0.1176061  17.1     14 0.43750
#> 3   6 10.6 0.2044512 0.07767364 0.4395416 0.0974638  17.1      7 0.21875
#> 
#> $Categoricas$gear
#>   gear    n         p     p_Min     p_Max        sd N_eff n_sinW  p_sinW
#> 1    3 18.8 0.3630165 0.1807489 0.5954859 0.1162097  17.1     15 0.46875
#> 2    4 19.5 0.3771261 0.1909541 0.6083290 0.1171274  17.1     12 0.37500
#> 3    5 13.4 0.2598574 0.1110421 0.4966803 0.1059840  17.1      5 0.15625
#> 
#> $Categoricas$carb
#>   carb    n          p       p_Min     p_Max         sd N_eff n_sinW  p_sinW
#> 1    1 12.3 0.23768746 0.097307266 0.4742001 0.10286907  17.1      7 0.21875
#> 2    2 14.2 0.27580180 0.121212632 0.5125552 0.10800464  17.1     10 0.31250
#> 3    3  3.4 0.06532754 0.012566068 0.2773880 0.05971632  17.1      3 0.09375
#> 4    4 15.7 0.30479894 0.140299384 0.5408359 0.11124412  17.1     10 0.31250
#> 5    6  0.8 0.01633605 0.001043488 0.2088820 0.03063459  17.1      1 0.03125
#> 6    8  5.2 0.10004821 0.025451361 0.3212196 0.07251526  17.1      1 0.03125
#> 
#> $Categoricas$grupo
#>         grupo    n        p     p_Min     p_Max        sd N_eff n_sinW p_sinW
#> 1 Tratamiento 28.7 0.555557 0.3324258 0.7583277 0.1200846  17.1     18 0.5625
#> 2     Control 23.0 0.444443 0.2416723 0.6675742 0.1200846  17.1     14 0.4375
#> 
#> 
#> attr(,"peso")
#> [1] TRUE
```

Y se puede exportar a Excel de esta forma. Así se ha generado en R el
objeto workbook y además se ha exportado el Excel.

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

Si queremos obtener los descriptivos agrupados por la variable `grupo`
bastaría con utilizar la función `generar_descriptivos_agrupados`:

``` r
# Análisis descriptivo agrupado (tanto numérico como categórico)
resultados_agrupados <- generar_descriptivos_agrupados( 
  datos      = temp,
  # podriamos indicar las variables de intereres con 'vars_categoricas' y 'vars_numericas', pero dejamos que seleccione las variables automáticamente
  vars_grupo = 'grupo',
  var_peso   = "pesos", # vector para ponderar
  num_unificar_1tabla = FALSE # en este caso no queremos que unifique los descriptivos numéricos en 1 tabla
)
print(resultados_agrupados)
#> $Numericas
#> $Numericas$mpg
#> # A tibble: 2 × 18
#>   grupo       Variable     N Missing Media Media_w    Dif p_value Media_w_Min_95
#>   <chr>       <chr>    <int>   <int> <dbl>   <dbl>  <dbl>   <dbl>          <dbl>
#> 1 Control     mpg         14       0  19.4    21.5 NA      NA               17.6
#> 2 Tratamiento mpg         18       0  20.6    21.1 -0.403   0.878           17.6
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>, hist <chr>
#> 
#> $Numericas$disp
#> # A tibble: 2 × 18
#>   grupo       Variable     N Missing Media Media_w   Dif p_value Media_w_Min_95
#>   <chr>       <chr>    <int>   <int> <dbl>   <dbl> <dbl>   <dbl>          <dbl>
#> 1 Control     disp        14       0  238.    206.  NA    NA               134.
#> 2 Tratamiento disp        18       0  225.    218.  11.8   0.803           154.
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>, hist <chr>
#> 
#> $Numericas$hp
#> # A tibble: 2 × 18
#>   grupo       Variable     N Missing Media Media_w   Dif p_value Media_w_Min_95
#>   <chr>       <chr>    <int>   <int> <dbl>   <dbl> <dbl>   <dbl>          <dbl>
#> 1 Control     hp          14       0  165.    169.  NA    NA              125. 
#> 2 Tratamiento hp          18       0  133.    134. -35.6   0.228           94.4
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>, hist <chr>
#> 
#> $Numericas$drat
#> # A tibble: 2 × 18
#>   grupo       Variable     N Missing Media Media_w    Dif p_value Media_w_Min_95
#>   <chr>       <chr>    <int>   <int> <dbl>   <dbl>  <dbl>   <dbl>          <dbl>
#> 1 Control     drat        14       0  3.66    3.78 NA      NA               3.49
#> 2 Tratamiento drat        18       0  3.55    3.61 -0.165   0.386           3.36
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>, hist <chr>
#> 
#> $Numericas$wt
#> # A tibble: 2 × 18
#>   grupo       Variable     N Missing Media Media_w    Dif p_value Media_w_Min_95
#>   <chr>       <chr>    <int>   <int> <dbl>   <dbl>  <dbl>   <dbl>          <dbl>
#> 1 Control     wt          14       0  3.23    2.97 NA      NA               2.36
#> 2 Tratamiento wt          18       0  3.21    3.11  0.132   0.747           2.55
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>, hist <chr>
#> 
#> $Numericas$qsec
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w     Dif p_value Media_w_Min_95
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>   <dbl>   <dbl>          <dbl>
#> 1 Control    qsec        14       0  17.5    17.7 NA       NA               16.8
#> 2 Tratamien… qsec        18       0  18.1    17.8  0.0253   0.968           16.9
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>, hist <chr>
#> 
#> $Numericas$vs
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w     Dif p_value Media_w_Min_95
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>   <dbl>   <dbl>          <dbl>
#> 1 Control    vs          14       0 0.357   0.488 NA       NA              0.209
#> 2 Tratamien… vs          18       0 0.5     0.478 -0.0102   0.956          0.228
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>, hist <chr>
#> 
#> $Numericas$am
#> # A tibble: 2 × 18
#>   grupo       Variable     N Missing Media Media_w    Dif p_value Media_w_Min_95
#>   <chr>       <chr>    <int>   <int> <dbl>   <dbl>  <dbl>   <dbl>          <dbl>
#> 1 Control     am          14       0 0.429   0.642 NA      NA              0.368
#> 2 Tratamiento am          18       0 0.389   0.476 -0.166   0.363          0.230
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>, hist <chr>
#> 
#> 
#> $Categoricas
#> $Categoricas$cyl
#> # A tibble: 3 × 10
#>   cyl   grupo_Control_p grupo_Tratamiento_p Control_n Tratamiento_n
#>   <chr>           <dbl>               <dbl>     <dbl>         <dbl>
#> 1 4               0.552               0.297      12.7           8.5
#> 2 8               0.448               0.335      10.3           9.6
#> 3 6              NA                   0.368      NA            10.6
#> # ℹ 5 more variables: Control_p_sinW <dbl>, Tratamiento_p_sinW <dbl>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> $Categoricas$gear
#> # A tibble: 3 × 10
#>   gear  grupo_Control_p grupo_Tratamiento_p Control_n Tratamiento_n
#>   <fct>           <dbl>               <dbl>     <dbl>         <dbl>
#> 1 3               0.338               0.383       7.7          11  
#> 2 4               0.318               0.425       7.3          12.2
#> 3 5               0.345               0.192       7.9           5.5
#> # ℹ 5 more variables: Control_p_sinW <dbl>, Tratamiento_p_sinW <dbl>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> $Categoricas$carb
#> # A tibble: 6 × 10
#>   carb  grupo_Control_p grupo_Tratamiento_p Control_n Tratamiento_n
#>   <fct>           <dbl>               <dbl>     <dbl>         <dbl>
#> 1 1              0.408               0.101        9.4           2.9
#> 2 2              0.151               0.375        3.5          10.8
#> 3 3              0.0607              0.0690       1.4           2  
#> 4 4              0.155               0.425        3.6          12.2
#> 5 6             NA                   0.0294      NA             0.8
#> 6 8              0.225              NA            5.2          NA  
#> # ℹ 5 more variables: Control_p_sinW <dbl>, Tratamiento_p_sinW <dbl>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> 
#> attr(,"vars_grupo")
#> [1] TRUE
#> attr(,"peso")
#> [1] TRUE
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
documentación de cada una, por ejemplo,
`?generar_descriptivos_categoricos`).

## Contribución

¡Las contribuciones, informes de errores y solicitudes de nuevas
funcionalidades son bienvenidos!  
Por favor, abre un issue o envía un pull request en
[GitHub](https://github.com/Adan-gz/analisisDescriptivo).

## Licencia

Este paquete está disponible bajo la Licencia MIT.
