source('pop.functions.r')
n.traits <- 10
pop.path <- "output/burn_in"
burnin.plots <- PlotPop(pop.path, n.traits)

sel.strengths  <- c(seq(1,19)/10000, seq(20, 200, 30)/10000)
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

drift.pop.number  <- 0:150
drift.folders = paste("Drift-", drift.pop.number, sep='')
drift.plots = vector('list', length(drift.pop.number))
for (i in 1:length(drift.pop.number)){
    pop.folder = paste("output/", drift.folders[i], sep = '')
    print(pop.folder)
    drift.plots[[i]]  <- PlotPop(pop.folder, n.traits)
}
names(drift.plots) = drift.folders

PlotPngManyPops  (corridor.plots, "selective/corridor")
PlotPngManyPops  (div.plots, "selective/divergent")
PlotPngSinglePop (burnin.plots, "burnin/burnin")
for (i in 0:150){
    plot.name = paste("drift/drift-", i, sep = '')
    PlotPngSinglePop (drift.plots[[i+1]], plot.name)
}


file.name = "p.corr.dat"
multi.sel.plot = CorrOmegaMultiPlot (file.name, pattern = "DivSel-Rep", n.traits, Label=F)
