time.series.plot  <-  function(input.file, y.axis, n.traits, selection = T, corr.plot = F){
    require(ggplot2)
    data.init = read.table(input.file)
    if(corr.plot){
        aux.trait = rep(c(1, -2), each = n.traits/2)
        aux.trait = aux.trait%*%t(aux.trait)
        aux.trait = aux.trait[upper.tri(aux.trait)]
        aux.trait[aux.trait==1] = "within module 1"
        aux.trait[aux.trait==4] = "within module 2"
        aux.trait[aux.trait==-2] = "between module"
        n.traits = (n.traits*n.traits-n.traits)/2
    }
    gen.number = data.init[seq(1,length(data.init[,1]),n.traits+1),]
    raw.trait.means = data.init[-seq(1,length(data.init[,1]),n.traits+1),]
    generations = length(gen.number)
    gen.number = rep(gen.number, each = n.traits)
    if(!corr.plot){
        sel.scheme = rep(rep(c("positive", "negative"), each=n.traits/2), generations)
    }
    else{
        sel.scheme = rep(aux.trait, generations)
    }
    trait.name = as.factor(rep(1:n.traits))
    data.clean = data.frame(raw.trait.means, trait.name, gen.number, sel.scheme)
    names(data.clean) = c("main", "trait", "generation", "selection")
    if (selection)
        time.series <- ggplot(data.clean, aes(generation, main, group = trait, color = selection)) + layer (geom = "point") + scale_y_continuous(y.axis)
    else
        time.series <- ggplot(data.clean, aes(generation, main, group = trait, color = trait)) + layer (geom = "point") + scale_y_continuous(y.axis)
    return(time.series)
}
PlotPop  <- function (pop.path, n.traits){
    mean.phenotype.plot  <- time.series.plot (paste(pop.path, "phenotype.dat", sep = '/'), "mean phenotype", 10, T)
    g.var.plot <- time.series.plot (paste(pop.path, "g.var.dat", sep = '/'), "genetic variance", 10, F)
    p.var.plot <- time.series.plot (paste(pop.path, "p.var.dat", sep = '/'), "phenotypic variance", 10, F)
    h.var.plot <- time.series.plot (paste(pop.path, "h.var.dat", sep = '/'), "heritability", 10, F)
    g.corr.plot <- time.series.plot (paste(pop.path, "g.corr.dat", sep = '/'), "genetic correlations", 10, T, T)
    p.corr.plot <- time.series.plot (paste(pop.path, "p.corr.dat", sep = '/'), "phenotypic correlations", 10, T, T)
    plots = list (
          g.var = g.var.plot,
          p.var = p.var.plot,
          h.var = h.var.plot,
          mean.phenotype = mean.phenotype.plot,
          g.corr = g.corr.plot,
          p.corr = p.corr.plot
          )
    return (plots)
}
PlotPng  <-  function(list.plots, file.name){
    require(ggplot2)
    require(gridExtra)
    png(paste("output/images/", file.name, sep = ''), width = 1080, height = 1980)
    dir.create("output/images")
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(3, 2)))
    vplayout <- function(x, y)
        viewport(layout.pos.row = x, layout.pos.col = y)
    print(list.plots[[1]]$p.corr, vp = vplayout(1, 1))
    print(list.plots[[2]]$p.corr, vp = vplayout(1, 2))
    print(list.plots[[3]]$p.corr, vp = vplayout(2, 1))
    print(list.plots[[4]]$p.corr, vp = vplayout(2, 2))
    print(list.plots[[5]]$p.corr, vp = vplayout(3, 1))
    print(list.plots[[6]]$p.corr, vp = vplayout(3, 2))
    dev.off()
}
n.traits <- 10
pop.path <- "output/burn_in"
burnin.plots <- PlotPop(pop.path, n.traits)
sel.strengths  <- seq(20, 200, 30)/10000
div.folders = paste("DivSel-", sel.strengths, sep='')
div.plots = vector('list', length(sel.strengths))
for (i in 1:length(sel.strengths)){
    pop.folder = paste("output/", div.folders[i], sep = '')
    print(pop.folder)
    div.plots[[i]]  <- PlotPop(pop.folder, n.traits)
}
names(div.plots) = div.folders
corridor.folders = paste("CoridorSel-", sel.strengths, sep='')
corridor.plots = vector('list', length(sel.strengths))
for (i in 1:length(sel.strengths)){
    pop.folder = paste("output/", corridor.folders[i], sep = '')
    print(pop.folder)
    corridor.plots[[i]]  <- PlotPop(pop.folder, n.traits)
}
names(corridor.plots) = corridor.folders
PlotPng  (corridor.plots, "corridor.png")
PlotPng  (div.plots, "divergent.png")
