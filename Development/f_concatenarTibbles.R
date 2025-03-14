

# CONCATENAR TIBBLES EN 1 TIBBLE PARA EXPORTAR ------------------------------

ajustar_tibble <- function(df,
                           ajustarProporciones = NULL, # character con nombre de la variable proporcion
                           digits=.1
){
  if(!is.null(ajustarProporciones)){
    df <- df %>% 
      mutate( across( all_of(ajustarProporciones), \(x) percent(x,accuracy = digits) ) )
  }
  
  df <- df %>% mutate(across(everything(),as.character))
  df <- as.data.frame(df)
  filaNombreCols <- colnames(df)
  colnames(df) <- paste0('Col',1:ncol(df))
  names(filaNombreCols) <- colnames(df)
  
  out <- as.data.frame( bind_rows( as_tibble(as.list(filaNombreCols)), df ) )
  
  ## aqui añado un ajuste en caso de detectar el titulo y la nota, que lo ponga 1 linea por debajo y por encima
  
  out
}


concatenar_tibbles <- function(list_df, nEmptyRows = 2, ajustar=T,
                               ajustarProporciones = NULL, # character con nombre de la variable proporcion
                               digits=.1
){
  
  if( is.data.frame(list_df) ){
    list_df <- list(list_df)
  }
  
  out <- data.frame()
  
  for (out.i in list_df) {
    
    if(ajustar){  out.i <- ajustar_tibble(df = out.i, ajustarProporciones=ajustarProporciones) }
    
    if( nEmptyRows > 0 ){
      empty <- as.data.frame( matrix( rep(NA, ncol(out.i)*nEmptyRows ), ncol = ncol(out.i) ) )
      
      if( is.null(colnames(out.i)) ){ colnames(empty) <- NULL }
      else { colnames(empty) <- colnames(out.i) }
      
      out.i <- bind_rows(
        as_tibble(out.i,.name_repair = 'minimal'),
        as_tibble(empty,.name_repair = 'minimal')
      )
    }
    
    out <- bind_rows(
      as_tibble(out,.name_repair = 'minimal'),
      as_tibble(out.i,.name_repair = 'minimal')
    ) 
    out <- as.data.frame(out)
  }
  
  colnames(out) <- NULL
  return(out)
  return(out[-which(out[[1]] == 'Col1'), ])
}



# list_df <- list(mtcars[1:10,1:3], iris[1:10,1:3],mtcars[1:10,1:3])
# concatenar_tibbles( list_df )
# concatenar_tibbles(mtcars)
# concatenar_tibbles(mtcars, nEmptyRows = 0)


