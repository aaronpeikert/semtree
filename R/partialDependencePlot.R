
partialDependencePlot <- function(forest, reference.var, reference.param, support=10, xlab=NULL, ylab=NULL,...)  {
  .Deprecated("partialDependence")
  pd <- partialDependence(forest, reference.var, reference.param, support)
  plot(pd, xlab, ylab, ...)
  return(pd)
}

partialDependence <- function(forest, reference.var, reference.param, support=NULL, cluster=NULL) 
{
  
  result <- list()
  
  if (!reference.var %in% names(forest$data)) {
    stop("Reference variable is not in the dataset")
  }
  
  model <- forest$model
  if (inherits(model,"MxModel") || inherits(model,"MxRAMModel")) {
    model.params <- names(OpenMx::omxGetParameters(forest$model))
  } else if (inherits(model,"lavaan")) {
    #if (!is.numeric(reference.param)) {
    #  stop("Please specify numeric parameter identifier")
    #}
    
    # TODO: ERROR PRONE
    if (is.null(forest$forest[[1]])) {stop("Error! First tree is NULL")}
    model.params <- forest$forest[[1]]$param_names
  } else {
    stop("Not supported!")
  }
  
  if (!reference.param %in% model.params) {
    stop("Reference parameter is not in the model")
  }
  
  param.id <- which(model.params==reference.param)
  
  refVar <- forest$data[, reference.var]
  
  # factors are mapped onto their levels
  isfac <- FALSE
  if (is.factor(refVar)) {
    #refVar <- levels(refVar)
    isfac <- TRUE
  } 
  
  if (isfac) {
    
    xgrid <- levels(refVar) #unique(unclass(refVar))
    xlabs <- levels(refVar)
    
  } else {
    
    if (is.null(support)) {
      support <- 10
    }
    
    start <- min(refVar, na.rm=TRUE)
    end <- max(refVar, na.rm=TRUE)
    
    xgrid <- seq(start, end, length=support)  
    
    xlabs <- xgrid
  }

  
  fd <- partialDependenceDataset(forest$data, reference.var, xgrid)

  
  # traverse
#  for (i in 1:length(forest$forest)) {
  mapreduce <- function(tree) {
    #tree <- forest$forest[[i]]

    leaf.ids <- traverse( tree, fd)
    ret <- vector("list", length(leaf.ids))
    for (j in 1:length(leaf.ids)) {
      node <-getNodeById(tree, leaf.ids[j])
      p.estimate <- node$params[param.id]    
      yvalue <- fd[j, reference.var]
      
      #dict[[as.character(yvalue)]] <- c(dict[[as.character(yvalue)]],p)
      ret[[j]] <- (list(key=as.character(yvalue), value=p.estimate))
    }
    return(ret)
  }
  
  if (is.null(cluster)) {
    mapresult <- lapply(FUN=mapreduce,X=forest$forest)
  } else {
    mapresult <- parallel::parLapply(cl=cluster,fun=mapreduce,X=forest$forest)
  }
  
  #result <- list()
  #for (i in 1:10) {
  #  result <- mapreduce(forest$forest[[i]])
  #}
  
  
  dict <- list()
  dictsq <- list()
  cnt <- list()
  for (elem in xgrid) {
    dict[[as.character(elem)]] <- 0
    dictsq[[as.character(elem)]] <- 0
    cnt[[as.character(elem)]] <- 0
  }
  
  
  for (i in 1:length(mapresult)) {
    mr <- simplify2array(mapresult[[i]])
    for (j in 1:dim(mr)[2]) {
      key <- mr[,j]$key
      val <- mr[,j]$value
      dict[[key]] <- dict[[key]]+ val
      dictsq[[key]] <- dictsq[[key]]+ val**2
      cnt[[key]] <- cnt[[key]]+1
    }
  }
  
  
  
  for (elem in xgrid) {
    dict[[as.character(elem)]] <- dict[[as.character(elem)]] / cnt[[as.character(elem)]]
    dictsq[[as.character(elem)]] <- dictsq[[as.character(elem)]] / cnt[[as.character(elem)]]
  }
  
  result$reference.var <- reference.var
  result$reference.param <- reference.param

  result$dict <- dict
  result$dictsq <- dictsq
  result$xgrid <- xgrid
  result$xlabs <- xlabs
  
  result$is.factor <- isfac
  
  class(result) <- "partialDependence"
  
  return(result)
}


plot.partialDependence <- function(x, type="l",xlab=NULL, ylab=NULL, ...)
{
  #if (!(x inherits ("partialDependence"))) {
  #  stop("Invalid x object not of class partialDependence");
  #}
  
  if (is.null(xlab)) {
    xlab <- x$reference.var
  }
  
  if (is.null(ylab)) {
    ylab <- x$reference.param
  }
  
  # collect
  col1 <- x$xgrid
  col2 <- rep(NA, length(col1))
  for (i in 1: length(col1)) {
#    col2[i] <- mean(x$dict[[as.character(col1[i])]], na.rm=TRUE)
    col2[i] <- x$dict[[as.character(col1[i])]]
    
  }
  
  if (x$is.factor) {
    barplot(col2, names.arg=col1,xlab = xlab,ylab = ylab, ...)
  } else {
    plot(col1, col2, type=type, xlab=xlab,ylab=ylab, ...)
  }
}