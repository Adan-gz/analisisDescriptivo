
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

- Descriptivos cuando la variable dependiente o de interés es una
  variable numérica: se extraen estadístics de relación con las otras
  variables numéricas y, si son categóricas, se utiliza la función
  anterior.

Estas son las relaciones bivariadas que pueden analizarse:

- Variable Categórica frente a Variables Categóricas o Variables
  Numéricas

- Variable Numérica frente a Variables Categóricas o Variables Numéricas

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

- **Análisis descriptivo para una variable numérica (variable
  dependiente o de interés):** Genera de forma sencilla descriptivos de
  relación respecto a las variables numéricas explicativas y
  estadísticos agrupando por las categorías de una variable categórica.

<!-- -->

- **Análisis descriptivo para una variable categórica (variable
  dependiente o de interés):** Genera de forma sencilla descriptivos de
  relación respecto a las variables numéricas explicativas y
  estadísticos agrupando por las categorías de una variable categórica.
  La principal diferencia respecto al análisis agrupado es que en el
  análisis con las variables categórica se calculan los porcentajes
  agrupando por la variable categórica, en vez de la variable de
  interés.

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
3.  `generar_descriptivos_VDnumerica`: calcula estadísticos de relación
    entre 2 variables numéricas y estadísticis descriptivos de la
    variable numérica según las categorías de las variables categóricas.
4.  `crear_Excel`: genera un workbook a través de `openxlsx` y exporta
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
#> 1 mpg         32       0  20.1    21.2           19.2           23.3   10.4   
#> 2 disp        32       0 231.    216.           175.           257.    71.1   
#> 3 hp          32       0 147.    134.           110.           157.    52     
#> 4 drat        32       0   3.60    3.66           3.47           3.85   2.76  
#> 5 wt          32       0   3.22    3.07           2.76           3.37   1.51  
#> 6 qsec        32       0  17.8    17.8           17.2           18.4   14.5   
#> 7 vs          32       0   0.438   0.475          0.292          0.658  0     
#> 8 am          32       0   0.406   0.493          0.310          0.676  0     
#> 9 pesos       32       0   0.973   1.57           1.28           1.87   0.0654
#> # ℹ 7 more variables: Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>,
#> #   sd_w <dbl>, hist <chr>
#> 
#> $Categoricas
#> $Categoricas$cyl
#>   cyl    n         p     p_Min     p_Max        sd N_eff n_sinW  p_sinW
#> 1   4 11.1 0.3575564 0.1861477 0.5752410 0.1076894  19.8     11 0.34375
#> 2   8 10.6 0.3418079 0.1746198 0.5603880 0.1065739  19.8     14 0.43750
#> 3   6  9.4 0.3006357 0.1453991 0.5206399 0.1030280  19.8      7 0.21875
#> 
#> $Categoricas$gear
#>   gear    n         p      p_Min     p_Max         sd N_eff n_sinW  p_sinW
#> 1    3 12.3 0.3943610 0.21380702 0.6092340 0.10980881  19.8     15 0.46875
#> 2    4 13.1 0.4197362 0.23344399 0.6321038 0.11088793  19.8     12 0.37500
#> 3    5  5.8 0.1859028 0.07203987 0.4018069 0.08741067  19.8      5 0.15625
#> 
#> $Categoricas$carb
#>   carb   n          p       p_Min     p_Max         sd N_eff n_sinW  p_sinW
#> 1    1 9.6 0.30820215 0.150666494 0.5280474 0.10375063  19.8      7 0.21875
#> 2    2 9.7 0.31035056 0.152170711 0.5301420 0.10394983  19.8     10 0.31250
#> 3    3 1.5 0.04961016 0.008703893 0.2368351 0.04878873  19.8      3 0.09375
#> 4    4 9.2 0.29578394 0.142046766 0.5158650 0.10254714  19.8     10 0.31250
#> 5    6 0.5 0.01671262 0.001236512 0.1891948 0.02880354  19.8      1 0.03125
#> 6    8 0.6 0.01934057 0.001621522 0.1932120 0.03094404  19.8      1 0.03125
#> 
#> $Categoricas$grupo
#>         grupo    n         p     p_Min     p_Max        sd N_eff n_sinW p_sinW
#> 1 Tratamiento 16.8 0.5385464 0.3312708 0.7332994 0.1120105  19.8     18 0.5625
#> 2     Control 14.4 0.4614536 0.2667006 0.6687292 0.1120105  19.8     14 0.4375
#> 
#> 
#> attr(,"peso")
#> [1] TRUE
```

Y se puede exportar a Excel de esta forma. Así se ha generado en R el
objeto workbook y además se ha exportado el Excel.

``` r
workbook <- crear_Excel( 
  resultados_univ, 
  unificar_misma_hoja = TRUE, 
  titulos_principales = 'DESCRIPTIVOS UNIVARIADOS', 
  exportar            = TRUE, 
  nombre_archivo      = 'Descriptivos_Univariados'
)
```

Así se vería:

![](img/Imagen1.png)

Si queremos obtener los descriptivos agrupados por la variable `grupo`
bastaría con utilizar la función `generar_descriptivos_agrupados`.

En el caso de las variables numéricas, se realiza una regresión OLS y se
incluyen los coeficientes (`Dif_categoriaReferencia`) y el `p.valor`. Si
se ha especificado pesos las regresiones se calculan aplicando la
ponderación. Pero la distribución y cuartiles se calculan sin ponderar.

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
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    mpg         14       0  21.1    20.7                  NA     NA    
#> 2 Tratamien… mpg         18       0  19.3    21.7                   1.09   0.598
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$disp
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    disp        14       0  212.    222.                   NA    NA    
#> 2 Tratamien… disp        18       0  245.    210.                  -11.8   0.776
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$hp
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    hp          14       0  139.    140.                   NA    NA    
#> 2 Tratamien… hp          18       0  153.    128.                  -12.5   0.601
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$drat
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    drat        14       0  3.76    3.82                 NA      NA    
#> 2 Tratamien… drat        18       0  3.47    3.53                 -0.287   0.130
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$wt
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    wt          14       0  2.86    2.91                 NA      NA    
#> 2 Tratamien… wt          18       0  3.49    3.20                  0.286   0.353
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$qsec
#> # A tibble: 2 × 18
#>   grupo     Variable     N Missing Media Media_w Dif_categoriaReferen…¹  p_value
#>   <chr>     <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>    <dbl>
#> 1 Control   qsec        14       0  17.3    17.0                  NA    NA      
#> 2 Tratamie… qsec        18       0  18.3    18.6                   1.62  0.00351
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$vs
#> # A tibble: 2 × 18
#>   grupo     Variable     N Missing Media Media_w Dif_categoriaReferen…¹  p_value
#>   <chr>     <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>    <dbl>
#> 1 Control   vs          14       0 0.357   0.206                 NA     NA      
#> 2 Tratamie… vs          18       0 0.5     0.706                  0.500  0.00362
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$am
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    am          14       0 0.5     0.579                 NA      NA    
#> 2 Tratamien… am          18       0 0.333   0.419                 -0.160   0.382
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> 
#> $Categoricas
#> $Categoricas$cyl
#> # A tibble: 3 × 10
#>   cyl   grupo_Control_p grupo_Tratamiento_p Control_n Tratamiento_n
#>   <chr>           <dbl>               <dbl>     <dbl>         <dbl>
#> 1 8               0.398               0.294       5.7           4.9
#> 2 4               0.323               0.387       4.6           6.5
#> 3 6               0.279               0.319       4             5.4
#> # ℹ 5 more variables: Control_p_sinW <dbl>, Tratamiento_p_sinW <dbl>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> $Categoricas$gear
#> # A tibble: 3 × 10
#>   gear  grupo_Control_p grupo_Tratamiento_p Control_n Tratamiento_n
#>   <fct>           <dbl>               <dbl>     <dbl>         <dbl>
#> 1 3               0.275              0.496        4             8.3
#> 2 4               0.364              0.468        5.2           7.8
#> 3 5               0.361              0.0359       5.2           0.6
#> # ℹ 5 more variables: Control_p_sinW <dbl>, Tratamiento_p_sinW <dbl>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> $Categoricas$carb
#> # A tibble: 6 × 10
#>   carb  grupo_Control_p grupo_Tratamiento_p Control_n Tratamiento_n
#>   <fct>           <dbl>               <dbl>     <dbl>         <dbl>
#> 1 1              0.0161              0.558        0.2           9.4
#> 2 2              0.551               0.104        7.9           1.7
#> 3 3             NA                   0.0921      NA             1.5
#> 4 4              0.397               0.209        5.7           3.5
#> 5 6              0.0362             NA            0.5          NA  
#> 6 8             NA                   0.0359      NA             0.6
#> # ℹ 5 more variables: Control_p_sinW <dbl>, Tratamiento_p_sinW <dbl>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> 
#> attr(,"vars_grupo")
#> [1] TRUE
#> attr(,"peso")
#> [1] TRUE
```

Y así podríamos añadirlo al workbook existente:

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

Por último, podrías estar interesados en estudiar como variable
dependiente `mpg`. En este caso se calcula:

- Variable independiente numérica: coeficiente de correlación,
  coeficiente de una regresión lineal y su p.valor (aplicando pesos si
  corresponde), y se trocea la X numérica en cuartiles y se calcula la
  media de la VD para indicar por algún posible patrón no lineal.

- Variable independiente categórica: produce el mismo output que el
  visualizado en la imagen superior.

``` r
resultados_VD_mpg <- generar_descriptivos_VDnumerica(
  temp,
  var_VDnum = 'mpg',
  var_peso  = 'pesos', 
  selecc_vars_auto = TRUE,
  num_unificar_1tabla = T
)
print(resultados_VD_mpg)
#> $Numericas
#> # A tibble: 7 × 12
#>   Var_VD var_X     R2   R2_w OLS_coef OLS_p_value OLS_coef_w OLS_p_value_w
#>   <chr>  <chr>  <dbl>  <dbl>    <dbl>       <dbl>      <dbl>         <dbl>
#> 1 mpg    disp  -0.848 -0.814  -0.0412    9.38e-10    -0.0419 0.00000000165
#> 2 mpg    hp    -0.776 -0.752  -0.0682    1.79e- 7    -0.0675 0.000000174  
#> 3 mpg    drat   0.681  0.560   7.68      1.78e- 5     6.23   0.000524     
#> 4 mpg    wt    -0.868 -0.796  -5.34      1.29e-10    -5.51   0.00000000778
#> 5 mpg    qsec   0.419  0.455   1.41      1.71e- 2     1.64   0.00659      
#> 6 mpg    vs     0.664  0.545   7.94      3.42e- 5     6.34   0.000796     
#> 7 mpg    am     0.600  0.531   7.24      2.85e- 4     6.17   0.00114      
#> # ℹ 4 more variables: Cuartil_1_Media <dbl>, Cuartil_2_Media <dbl>,
#> #   Cuartil_3_Media <dbl>, Cuartil_4_Media <dbl>
#> 
#> $Categoricas
#> $Categoricas$cyl
#> # A tibble: 3 × 18
#>   cyl   Variable     N Missing Media Media_w Dif_categoriaReferencia   p_value
#>   <chr> <chr>    <int>   <int> <dbl>   <dbl>                   <dbl>     <dbl>
#> 1 4     mpg         11       0  26.7    27.4                   NA    NA       
#> 2 6     mpg          7       0  19.7    20.2                   -7.26  2.10e- 6
#> 3 8     mpg         14       0  15.1    15.7                  -11.7   9.40e-11
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Categoricas$gear
#> # A tibble: 3 × 18
#>   gear  Variable     N Missing Media Media_w Dif_categoriaReferencia   p_value
#>   <chr> <chr>    <int>   <int> <dbl>   <dbl>                   <dbl>     <dbl>
#> 1 3     mpg         15       0  16.1    17.4                   NA    NA       
#> 2 4     mpg         12       0  24.5    25.0                    7.62  0.000258
#> 3 5     mpg          5       0  21.4    21.1                    3.70  0.123   
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Categoricas$carb
#> # A tibble: 6 × 18
#>   carb  Variable     N Missing Media Media_w Dif_categoriaReferencia   p_value
#>   <chr> <chr>    <int>   <int> <dbl>   <dbl>                   <dbl>     <dbl>
#> 1 1     mpg          7       0  25.3    25.8                   NA    NA       
#> 2 2     mpg         10       0  22.4    21.7                   -4.10  0.0694  
#> 3 3     mpg          3       0  16.3    16.5                   -9.32  0.0322  
#> 4 4     mpg         10       0  15.8    17.4                   -8.42  0.000698
#> 5 6     mpg          1       0  19.7    19.7                   -6.08  0.377   
#> 6 8     mpg          1       0  15      15                    -10.8   0.0994  
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Categoricas$grupo
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    mpg         14       0  21.1    20.7                  NA     NA    
#> 2 Tratamien… mpg         18       0  19.3    21.7                   1.09   0.598
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
```

Estos resultados podrían añadirse al workbook e imprimirse
sobreescribiendo el actual:

``` r
crear_Excel(
  workbook            = workbook,
  list_list_tablas    = resultados_VD_mpg,
  unificar_misma_hoja = TRUE, # unificamos 
  nombres_hojas       = 'Hoja_MPG', # ponemos nombre a la hoja
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
#>  Sheet 3: "Hoja_MPG"
#>  
#> 
#>  
#>  Worksheet write order: 1, 2, 3
#>  Active Sheet 1: "Hoja 1" 
#>  Position: 1
```

Así se visualizaría:

![](img/Imagen3.png)

Finalmente, si se tuviera interés en analizar una variable dependiente
categórica, el código sería muy similar.

``` r
resultados_VD_cyl <- generar_descriptivos_VDcategorica(
  temp,
  var_VDcat = 'cyl',
  var_peso  = 'pesos',
  estrategia_valoresPerdidos = 'A',
  selecc_vars_auto = TRUE,
)
print(resultados_VD_cyl)
#> $Numericas
#> # A tibble: 24 × 18
#>    cyl   Variable     N Missing  Media Media_w Dif_categoriaReferencia   p_value
#>    <chr> <chr>    <int>   <int>  <dbl>   <dbl>                   <dbl>     <dbl>
#>  1 4     mpg         11       0  26.7    27.4                    NA    NA       
#>  2 6     mpg          7       0  19.7    20.2                    -7.26  2.10e- 6
#>  3 8     mpg         14       0  15.1    15.7                   -11.7   9.40e-11
#>  4 4     disp        11       0 105.    103.                     NA    NA       
#>  5 6     disp         7       0 183.    198.                     95.5   5.15e- 5
#>  6 8     disp        14       0 353.    350.                    247.    2.23e-13
#>  7 4     hp          11       0  82.6    77.5                    NA    NA       
#>  8 6     hp           7       0 122.    116.                     38.2   1.69e- 2
#>  9 8     hp          14       0 209.    208.                    130.    7.38e-10
#> 10 4     drat        11       0   4.07    4.11                   NA    NA       
#> # ℹ 14 more rows
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Categoricas
#> $Categoricas$gear
#> # A tibble: 3 × 13
#>   cyl   gear_3_p gear_4_p gear_5_p `3_n` `4_n` `5_n` `3_p_sinW` `4_p_sinW`
#>   <chr>    <dbl>    <dbl>    <dbl> <dbl> <dbl> <dbl>      <dbl>      <dbl>
#> 1 8       0.656    NA       0.447    8.1  NA     2.6     0.8        NA    
#> 2 4       0.0188    0.629   0.463    0.2   8.2   2.7     0.0667      0.667
#> 3 6       0.325     0.371   0.0899   4     4.8   0.5     0.133       0.333
#> # ℹ 4 more variables: `5_p_sinW` <dbl>, Chi2 <dbl>, p_value <dbl>,
#> #   VCramer <dbl>
#> 
#> $Categoricas$carb
#> # A tibble: 3 × 22
#>   cyl   carb_3_p carb_6_p carb_8_p carb_1_p carb_2_p carb_4_p `3_n` `6_n` `8_n`
#>   <chr>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl> <dbl> <dbl> <dbl>
#> 1 8            1       NA        1   NA        0.428    0.474   1.5  NA     0.6
#> 2 6           NA        1       NA    0.416   NA        0.526  NA     0.5  NA  
#> 3 4           NA       NA       NA    0.584    0.572   NA      NA    NA    NA  
#> # ℹ 12 more variables: `1_n` <dbl>, `2_n` <dbl>, `4_n` <dbl>, `3_p_sinW` <dbl>,
#> #   `6_p_sinW` <dbl>, `8_p_sinW` <dbl>, `1_p_sinW` <dbl>, `2_p_sinW` <dbl>,
#> #   `4_p_sinW` <dbl>, Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> $Categoricas$grupo
#> # A tibble: 3 × 10
#>   cyl   grupo_Control_p grupo_Tratamiento_p Control_n Tratamiento_n
#>   <chr>           <dbl>               <dbl>     <dbl>         <dbl>
#> 1 8               0.398               0.294       5.7           4.9
#> 2 4               0.323               0.387       4.6           6.5
#> 3 6               0.279               0.319       4             5.4
#> # ℹ 5 more variables: Control_p_sinW <dbl>, Tratamiento_p_sinW <dbl>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
```

El output se incluiría en el Excel de la misma forma que en los
anteriores casos.

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
