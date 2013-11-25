library(Morphometrics)
library(ggplot2)
library(reshape2)

ReadMatrices  <- function(input.file, n.traits){
    data.init = read.table(input.file)
    n.corrs = (n.traits*n.traits-n.traits)/2
    gen.number = data.init[seq(1,length(data.init[,1]),n.corrs+1),]
    raw.trait.means = data.init[-seq(1,length(data.init[,1]),n.corrs+1),]
    generations = length(gen.number)
    cor.matrices = vector('list', generations)
    current.mat = matrix(1, n.traits, n.traits)
    for(gen in 1:generations){
        lower = 1+((gen-1)*n.corrs)
        upper = gen*n.corrs
        current.mat[upper.tri(current.mat)] = raw.trait.means[lower:upper]
        current.mat[lower.tri(current.mat)] = t(current.mat)[lower.tri(current.mat)]
        cor.matrices[[gen]] = current.mat
    }
    names(cor.matrices) = gen.number
    return(cor.matrices)
}

ReadVariances  <- function(input.file, n.traits){
    data.init = read.table(input.file)
    gen.number = data.init[seq(1,length(data.init[,1]),n.traits+1),]
    raw.trait.means = data.init[-seq(1,length(data.init[,1]),n.traits+1),]
    generations = length(gen.number)
    var.vectors = vector('list', generations)
    for(gen in 1:generations){
        lower = 1+((gen-1)*n.traits)
        upper = gen*n.traits
         raw.trait.means[lower:upper]
        var.vectors[[gen]] = raw.trait.means[lower:upper]
    }
    names(var.vectors) = gen.number
    return(var.vectors)
}

CalcCovar  <- function(corr, vars){
    num.gens = length(vars)
    covs = vector('list', num.gens)
    for(i in 1:num.gens)
        covs[[i]] = corr[[i]]*outer(vars[[i]], vars[[i]])
    names(covs) = names(vars)
    return(covs)
}

ReadFolder  <- function(input.folder, n.traits = 10, sel.type, direct.sel = T){
    print(input.folder)
    input.folder = paste("./output", input.folder, sep="/")
    input.file = paste(input.folder, "p.corr.dat", sep = '/')
    p.cor = ReadMatrices(input.file, n.traits)
    input.file = paste(input.folder, "g.corr.dat", sep = '/')
    g.cor = ReadMatrices(input.file, n.traits)
    input.file = paste(input.folder, "p.var.dat", sep = '/')
    p.var = ReadVariances(input.file, n.traits)
    input.file = paste(input.folder, "g.var.dat", sep = '/')
    g.var = ReadVariances(input.file, n.traits)
    input.file = paste(input.folder, "h.var.dat", sep = '/')
    h.var = ReadVariances(input.file, n.traits)
    input.file = paste(input.folder, "phenotype.dat", sep = '/')
    phenotype = ReadVariances(input.file, n.traits)

    p.cov = CalcCovar(p.cor, p.var)
    g.cov = CalcCovar(g.cor, g.var)

    if(direct.sel){
        aux.file = paste(input.folder, "pop.parameters.txt", sep="/")
        parameters = scan(aux.file, character(), quiet = TRUE)
        index = which("theta"==parameters)+2
        selection.strength = as.numeric(parameters[index])
    }
    else{
        selection.strength = 0.
    }
    out.list = list(p.cor = p.cor,
                    g.cor = g.cor,
                    p.var = p.var,
                    g.var = g.var,
                    h.var = h.var,
                    p.cov = p.cov,
                    g.cov = g.cov,
                    selection.type = sel.type,
                    selection.strength = selection.strength,
                    generation = as.numeric(names(p.var)))
    return(out.list)
}

CalcIsoStat  <- function(mat.list, Stat){
    betas = rep(c(1, 0), each=dim(mat.list[[1]])[1]/2)
    betas = Normalize(betas)
    out = lapply(mat.list, function(mat) Stat(betas, mat))
    return(unlist(out))
}

CalcMeanStat  <- function(mat.list, Stat, nsk = 1000){
    n.traits = dim(mat.list[[1]])[1]
    beta.mat <- array (rnorm (n.traits * nsk), c(n.traits, nsk))
    beta.mat <- apply (beta.mat, 2, Normalize)
    out = lapply(mat.list, function(mat) { return(mean (apply (beta.mat, 2, Stat, cov.matrix = mat)))})
    return(unlist(out))
}

MapCalcR2  <- function(mat.list){
    r2.list = lapply(mat.list, CalcR2)
    return(unlist(r2.list))
}

MapEffectiveDimension <- function(mat.list){
    nd.list <- lapply(mat.list, function(x){
                      eVals  <-  eigen(x)$values
                      return(sum(eVals)/eVals[1])
                    })
    return(unlist(nd.list))
}

AVGRatio <- function(mat.list, Selection_Strength, last.gen = T, num.cores = 1, generations = 1:10000 + 20000){
    if (num.cores > 1) {
        library(doMC)
        library(foreach)
        registerDoMC(num.cores)
        parallel = TRUE
    }
    else{
        parallel = FALSE
    }
    n.traits = dim(mat.list[[1]])[1]
    module.1 = rep(c(1,0), each = n.traits/2)
    module.2 =  rep(c(0,1), each = n.traits/2)
    modularity.hipot = cbind(module.1, module.2)
    if(last.gen)
        AVGRatio <- ldply(mat.list[length(mat.list)], function(x) TestModularity(x, modularity.hipot, iterations=0), .parallel = parallel)
    else{
        AVGRatio <- ldply(mat.list, function(x) TestModularity(x, modularity.hipot, iterations=0), .parallel = parallel)
        AVGRatio['generation'] = rep(generations, each = 3)
    }
    AVGRatio['Selection_Strength'] = Selection_Strength
    return(AVGRatio)
}

AVGRatioPlot  <- function(pop.list, modules = FALSE, num.cores = 2){
    avg <- ldply(pop.list, function(x) AVGRatio(x$p.cor, x$selection.strength, num.cores = num.cores), .progress = 'text')
    names(avg)[6] = "Avg_Ratio"
    if(modules){
        m.avg = melt(avg[,-c(2, 3, 6)], id.vars = c('.id', 'Selection_Strength'))
        m.avg = m.avg[!((m.avg['.id'] != "Full Integration") & (m.avg['variable'] == "AVG-")),]
        m.avg = m.avg[!((m.avg['.id'] == "Full Integration") & (m.avg['variable'] == "AVG+")),]
        avg.plot = ggplot(m.avg, aes(Selection_Strength,
                                     value,
                                     group=interaction(variable, Selection_Strength, .id),
                                     colour=interaction(.id, variable))) +
                            layer(geom="boxplot") +
                            labs(x="Selection Strength",
                                 y="Average Correlation",
                                 color = "Module") +
                            scale_colour_discrete(labels=c("Within Module 1",
                                                           "Within Module 2",
                                                           "Between Modules")) + theme_bw()
    }
    else{
        avg.full = avg[avg['.id'] == "Full Integration",-3]
        avg.plot = ggplot(avg.full, aes(Selection_Strength,
                                        Avg_Ratio,
                                        group = Selection_Strength)) + layer(geom="boxplot") +
                            labs(x="Selection Strength", y="AVG Ratio") + theme_bw()
    }
    return(avg.plot)
}

CalcCorrOmega <- function(mat.list){
    n.traits = dim(mat.list[[1]])[1]
    omega = as.matrix(read.table ("input/omega.csv", header=F, sep=' '))[1:n.traits, 1:n.traits]
    omega = omega[upper.tri(omega)]
    corr.omega <- lapply(mat.list, function(x) cor(x[upper.tri(x)], omega))
    return(unlist(corr.omega))
}

ReadPattern <- function(pattern = "DivSel-Rep-*",
                        n.traits = 10,
                        sel.type = 'divergent',
                        direct.sel = T){
    folders  <- dir("output/", pattern)
    main.data = llply(folders, function(x) ReadFolder(x, n.traits, sel.type, direct.sel))
    names(main.data) = folders
    return(main.data)
}

StatMultiPlot <- function(pop.list, StatMap, y.axis, n.traits = 10){
    generation.vector = pop.list[[1]]$generation
    n.gen = length(generation.vector)
    n.pop = length(pop.list)
    data.avg = array(dim=c(n.gen*n.pop, 3))
    for (pop in 1:n.pop){
        stat <- StatMap((pop.list[[pop]]$p.cov))
        print(pop)
        lower = 1+((pop-1)*n.gen)
        upper = pop*n.gen
        label.vector = rep(as.numeric(pop.list[[pop]]$selection.strength), n.gen)
        data.avg[lower:upper,1] = generation.vector
        data.avg[lower:upper,2] = stat
        data.avg[lower:upper,3] = label.vector
    }
    data.avg = data.frame(as.numeric(data.avg[,1]), as.numeric(data.avg[,2]), data.avg[,3])
    names(data.avg) = c("generation", "stat", "Selection_Strength")
    time.series  <- ggplot(data.avg, aes(generation, stat, group = Selection_Strength, color=Selection_Strength)) +
                    layer(geom = "smooth") + scale_y_continuous(y.axis)
    return(time.series)
}

LastGenStatMultiPlot  <- function(pop.list, StatMap, y.axis, n.traits = 10){
    generation.vector = pop.list[[1]]$generation
    n.gen = length(generation.vector)
    n.pop = length(pop.list)
    data.avg = array(dim=c(n.pop, 2))
    for (pop in 1:n.pop){
        stat <- StatMap(list(pop.list[[pop]]$p.cov[[n.gen]]))
        print(pop)
        lower = pop
        label.vector = as.numeric(pop.list[[pop]]$selection.strength)
        data.avg[pop,1] = stat
        data.avg[pop,2] = label.vector
    }
    data.avg = data.frame(as.numeric(data.avg[,1]), as.numeric(data.avg[,2]))
    names(data.avg) = c("stat", "Selection_Strength")
    time.series  <- ggplot(data.avg, aes(Selection_Strength, stat, group = Selection_Strength)) +
                    layer(geom = "boxplot") + scale_y_continuous(y.axis) + scale_x_continuous("Selection Strength")
    return(time.series)
}

LastGenStatMultiPlotWithMean  <- function(pop.list, StatMap, y.axis, n.traits = 10){
    generation.vector = pop.list[[1]]$generation
    n.gen = length(generation.vector)
    n.pop = length(pop.list)
    data.avg = array(dim=c(n.pop, 3))
    for (pop in 1:n.pop){
        direct.stat <- CalcIsoStatMap(list(pop.list[[pop]]$p.cov[[n.gen]]), StatMap)
        mean.stat <- CalcMeanStatMap(list(pop.list[[pop]]$p.cov[[n.gen]]), StatMap)
        print(pop)
        lower = pop
        label.vector = as.numeric(pop.list[[pop]]$selection.strength)
        data.avg[pop,1] = direct.stat
        data.avg[pop,2] = mean.stat
        data.avg[pop,3] = label.vector
    }
    data.avg = data.frame(as.numeric(data.avg[,1]), as.numeric(data.avg[,2]), as.numeric(data.avg[,3]))
    names(data.avg) = c("Directional", "Mean", "Selection_Strength")
    data.avg = melt(data.avg, c("Selection_Strength"))
    time.series  <- ggplot(data.avg, aes(Selection_Strength, value, group=interaction(Selection_Strength, variable),color=variable)) +
                    layer(geom = "boxplot") + scale_y_continuous(y.axis) + scale_x_continuous("Selection Strength")
    return(time.series)
}

NoSelStatMultiPlot <- function(pop.list, StatMap, y.axis, n.traits = 10){
    data.avg <- laply(pop.list, function (x) StatMap(x$p.cov))
    data.avg <- adply(data.avg, 2, function(x) c(mean(x), quantile(x, 0.025), quantile(x, 0.975)))
    data.avg[,1] = as.numeric(levels(data.avg[,1]))[data.avg[,1]]
    names(data.avg) = c("generation", "stat_mean", "stat_lower", "stat_upper")
    time.series  <- ggplot(data.avg, aes(generation, stat_mean)) +
                    geom_smooth(aes(ymin = stat_lower, ymax = stat_upper), data=data.avg, stat="identity") +
                    scale_y_continuous(y.axis)  +
                    scale_x_continuous("Generation")
    return(time.series)
}

NoSelStatMultiPlotMultiPop <- function(drift.list, stab.list, StatMap, y.axis, n.traits = 10){
    data.drift <- laply(drift.list, function (x) StatMap(x$p.cov))
    data.stab <- laply(stab.list, function (x) StatMap(x$p.cov))
    data.drift <- adply(data.drift, 2, function(x) c(mean(x), quantile(x, 0.025), quantile(x, 0.975)))
    data.stab <- adply(data.stab, 2, function(x) c(mean(x), quantile(x, 0.025), quantile(x, 0.975)))
    data.drift[,5] = rep("Drift", length(data.drift))
    data.stab[,5] = rep("Stabilizing", length(data.stab))
    data.avg = data.frame(rbind(data.drift, data.stab))
    data.avg[,1] = as.numeric(levels(data.avg[,1]))[data.avg[,1]]
    names(data.avg) = c("generation", "stat_mean", "stat_lower", "stat_upper", "Selection_scheme")
    time.series  <- ggplot(data.avg, aes(generation, stat_mean, color=Selection_scheme)) +
                    geom_smooth(aes(ymin = stat_lower, ymax = stat_upper, color=Selection_scheme), data=data.avg, stat="identity") +
                    scale_y_continuous(y.axis)  +
                    scale_x_continuous("Generation")
    return(time.series)
}

#main.data.div.sel = ReadPattern()
#save(main.data.div.sel, file="./rdatas/div.sel.Rdata")
#main.data.corridor = ReadPattern("Corridor", sel.type = "corridor")
#save(main.data.corridor, file='corridor.Rdata')
#main.data.stabilizing = ReadPattern("Stabilizing", sel.type = "Stabilizing", direct.sel = F)
#save(main.data.stabilizing, file='stabilizing.Rdata')
#main.data.drift = ReadPattern("Drift", sel.type = "drift", direct.sel = F)
#save(main.data.drift, file='./rdatas/drift.Rdata')

load("./rdatas/drift.Rdata")
load("./rdatas/corridor.Rdata")
load("./rdatas/div.sel.Rdata")
load("./rdatas/stabilizing.Rdata")
