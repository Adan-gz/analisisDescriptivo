
library(dplyr)
library(purrr)

temp <- mtcars %>% 
  mutate('cyl'=as.character(cyl),
         'carb'=factor(carb),
         'gear' = factor(gear),
         'w'=rlnorm(32))

source('f_auxiliares.R')
source('f_descriptivoS.R')
source('f_concatenarTibbles.R')



# Bivariados global -------------------------------------------------------

temp_biv <- generar_descriptivos_agrupados(data = temp,  vars_grupo = 'cyl', conf_level = 0.99, pivot_var = 'var_fac')
temp_biv2 <- generar_descriptivos_agrupados(data = temp,  vars_grupo = 'cyl', conf_level = 0.99, pivot_var = 'var_grupo')
temp_biv3 <- generar_descriptivos_agrupados(data = temp, 
                                            var_peso = 'w',
                                            vars_grupo = 'cyl', conf_level = 0.99, pivot_var = 'var_grupo')

temp_biv$Categoricas$carb
temp_biv2$Categoricas$carb
temp_biv3

temp_biv_simple<-generar_descriptivos_agrupados(
  data = temp,  
  # vars_fac = c('vs','am'),
  vars_grupo = 'cyl',vars_num = 'mpg', vars_fac = "vs", var_peso = 'w'
)

generar_hojaExcel_descriptivos(temp_biv_simple)


generar_DescCat(
  data = temp,
  var_fac = 'vs',
  vars_grupo = 'cyl',
  pivot_var = 'var_fac'
)

# Univariados global ------------------------------------------------------


temp_univariados <- generar_descriptivos_univariados(data = temp, conf_level = 0.99,var_peso = 'w')
temp_univariados$Categoricas

generar_hojaExcel_descriptivos(temp_univariados)

# Previo ------------------------------------------------------------------


temp_univariados <- generar_descriptivos_univariados(data = temp)


generar_descriptivos_univariados(
  data = temp,
  var_peso = 'w'
  )
generar_descriptivos_univariados(
  data = temp %>% group_by(cyl),
  var_peso = 'w'
)

generar_descriptivos_categoricos(temp)
generar_descriptivos_categoricos(temp, vars_grupo = 'cyl')
generar_descriptivos_numericos(temp, return_df = T)


temp_NA <- temp %>% mutate('char_NA'= c(NA,NA,NA, rep('A',29)) )
generar_descriptivos_categoricos(temp_NA, vars_grupo = 'cyl',)
generar_descriptivos_categoricos(temp_NA, vars_grupo = 'cyl',estrategia_missings = 'A')

# concatenar_listas_de_tibbles(
#   generar_descriptivos_univariados(data = temp)
# )

## en numerica las funciones de bajo nivel pueden pasar el tibble agrupado
# o sin agrupar, y con pesos, faltaria integrarlo en la funcion generica
temp_num <- generar_descriptivos_numericos(data = temp, return_df = T)
temp_num_w <-  generar_descriptivos_numericos(data = temp, var_peso = 'w', return_df = T)

generar_DescNum(
  data = temp %>% group_by(cyl),
  var_num = 'mpg'
)
generar_descriptivos_numericos(
  data = temp,
  vars_num = c('mpg','disp'),
  var_peso= 'w',
  vars_grupo = 'cyl',
  return_df = T
)
## pruebas en Categoricas
generar_DescCat(
  data = temp %>% group_by(cyl),
  var_fac = 'vs',
  pivot = F
)
generar_DescCat(
  data = temp %>% group_by(cyl),
  var_fac = 'vs',
)
generar_DescCat(
  data = temp %>% group_by(cyl),
  var_fac = 'vs',
  pivot_var = 'var_fac'
)
generar_DescCat(
  data = temp %>% group_by(cyl),
  var_fac = 'vs',
  pivot_var = 'var_fac'
)
generar_DescCat(
  data = temp,
  var_fac = 'vs',
  vars_grupo = 'cyl',
  pivot_var = 'var_fac'
)
generar_DescCat(
  data = temp,
  var_fac = 'vs',
  vars_grupo = c('cyl','am'),
  pivot_var = 'var_fac'
)
generar_DescCat(
  data = temp,
  var_fac = 'vs',
  vars_grupo = c('cyl','am'),
  pivot = T,
  pivot_var = 'var_grup'
)
generar_DescCat(
  data = temp,
  var_fac = 'vs',
  vars_grupo = c('cyl','am'),
  # var_peso= 'w',
  pivot = F
)
generar_DescCat(
  data = temp,
  var_fac = 'vs',
  vars_grupo = c('cyl','am'), 
  var_peso= 'w',
  pivot = F
)

generar_descriptivos_categoricos(
  data = temp,
  vars_fac = c('vs','am'),
  vars_grupo = 'cyl',
  # var_peso= 'w',
)



generar_DescCat(
  data = temp %>% group_by(cyl),
  var_fac = 'vs',
  pivot_var = 'var_fac'
)

generar_descriptivos_categoricos(
  data = temp,
  vars_fac = c('am','vs'),
  vars_grupo = 'cyl',
  var_peso =
)


# AGRUPADOS ---------------------------------------------------------------


