load("./rdatas/non.cor.corridor.Rdata")

devtools::install_github('Evomod-R', 'diogro')

detach("package:EvomodR", unload=TRUE)
library(EvomodR)
library(ggplot2)
library(reshape2)
library(gridExtra)

modules.corridor = AVGRatioPlot(non.cor.corridor, TRUE)
modules.corridor = modules.corridor + theme_bw() +
  theme(legend.position = c(0, 1),
        legend.justification = c(0, 1),
        legend.background = element_rect(fill="transparent"))
ggsave("~/lg_avg_corridor.tiff", width= 15, height = 12, units =  "cm", dpi = 600)

load("./rdatas/non.cor.div.sel.Rdata")

modules.div = AVGRatioPlot(non.cor.div.sel, TRUE)
modules.div = modules.div + theme_bw() +
  theme(legend.position = c(0, 0),
        legend.justification = c(0, 0),
        legend.background = element_rect(fill="transparent"))
ggsave("~/lg_avg_div.png", width= 18, height = 9, units =  "cm", dpi = 600)

auto = LastGenStatMultiPlotWithMean(non.cor.div.sel, Autonomy, "Autonomy")
auto = auto + theme_bw() +
theme(axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = c(1, 0),
      legend.justification = c(1, 0),
      legend.background = element_rect(fill="transparent"),
      legend.title = element_text("")) +
scale_colour_discrete(name = "")
ggsave("~/lg_auto.png", width= 15, height = 15, units =  "cm", dpi = 600)

avg.ratio = AVGRatioPlot(non.cor.div.sel)
avg.ratio = avg.ratio  + theme_bw() +
theme(legend.position = "bottom", axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme(legend.position = c(1, 0),
        legend.justification = c(1, 0),
        legend.background = element_rect(colour = "black"))
ggsave("~/lg_avgratio.png", width= 15, height = 15, units =  "cm", dpi = 600)

eigen.var = LastGenMultiStatMultiPlot(non.cor.div.sel, function(x) 100*EigenVar(x, 10), "Eigenvalues (% variation)")
eigen.var= eigen.var + theme_bw() +
theme(legend.position = "none", axis.text.x = element_text(angle = 45, hjust = 1))
  #theme(legend.position = c(1, 0),
        #legend.justification = c(1, 0),
        #legend.background = element_rect(colour = "black"))
ggsave("~/lg_eigen_var.png", width= 15, height = 15, units =  "cm", dpi = 600)

tiff("~/divergent_plot.tiff", height = 10, width = 25.4, units="cm", res = 600)
divergent_plot = grid.arrange(avg.ratio, eigen.var, auto, ncol = 3)
dev.off()

corr.omega = LastGenStatMultiPlot(non.cor.div.sel, CalcCorrOmega, "Fitness Surface Correlation (Mantel)")
corr.omega = corr.omega + theme_bw() +
theme(legend.position = "bottom", axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme(legend.position = c(1, 0),
        legend.justification = c(1, 0),
        legend.background = element_rect(colour = "black"))
ggsave("~/lg_corr_omega.png", width= 8.7, height = 10, units =  "cm", dpi = 600)

corr.omega.RS = LastGenStatMultiPlot(non.cor.div.sel, CalcCorrOmegaRS, "Fitness Surface Correlation (RS)")
corr.omega.RS= corr.omega.RS + theme_bw() +
theme(legend.position = "bottom", axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme(legend.position = c(1, 0),
        legend.justification = c(1, 0),
        legend.background = element_rect(colour = "black"))
ggsave("~/lg_corr_omega_RS.png", width= 8.7, height = 10, units =  "cm", dpi = 600)

corr.omega.Krz = LastGenStatMultiPlot(non.cor.div.sel, CalcCorrOmegaKrz, "Krznowski Correlation for 2 PC")
corr.omega.Krz= corr.omega.Krz + theme_bw() +
theme(legend.position = "bottom", axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme(legend.position = c(1, 0),
        legend.justification = c(1, 0),
        legend.background = element_rect(colour = "black"))
ggsave("~/lg_corr_omega_Krz.png", width= 8.7, height = 10, units =  "cm", dpi = 600)

corr.omega.eigenvector = LastGenMultiStatMultiPlot(non.cor.div.sel, CalcCorrOmegaEigenVector, "Eigenvector Correlation")
corr.omega.eigenvector= corr.omega.eigenvector + theme_bw() +
theme(legend.position = "bottom", axis.text.x = element_text(angle = 45, hjust = 1)) +
scale_colour_discrete(name = "Eigenvector") +
geom_hline(aes(yintercept = 0.7), color = "black") +
  theme(legend.position = c(1, 0),
        legend.justification = c(1, 0),
        legend.background = element_rect(colour = "transparent"))
ggsave("~/lg_corr_omega_evecs.png", width= 8.7, height = 10, units =  "cm", dpi = 600)

png("~/comparison_plot.png", height = 17, width = 14, units="cm", res = 600)
comparison_plot = grid.arrange(corr.omega, corr.omega.RS, corr.omega.Krz, corr.omega.eigenvector, ncol = 2)
dev.off()

png("~/small_comparison_plot.png", height = 9, width = 18, units="cm", res = 600)
comparison_plot = grid.arrange(corr.omega.Krz, corr.omega.eigenvector, ncol = 2)
dev.off()

png("~/subspace_plot.png", height = 7, width = 10, units="cm", res = 600)
subspace_plot = grid.arrange(corr.omega.Krz, corr.omega.eigenvector, ncol = 2)
dev.off()


#r2 = StatMultiPlot(main.data.div.sel, MapCalcR2, "Mean Squared Correlations") + theme_bw()
#ggsave("~/ts.r2.png")
#flex = StatMultiPlot(main.data.div.sel, CalcIsoFlex, "Directional Flexibility") + theme_bw()
#ggsave("~/ts.flex.png")
#evol = StatMultiPlot(main.data.div.sel, CalcIsoEvol, "Directional Evolvability") + theme_bw()
#ggsave("~/ts.evol.png")
#auto = StatMultiPlot(main.data.div.sel, CalcIsoAuto, "Directional Autonomy") + theme_bw()
#ggsave("~/ts.auto.png")
#avg.ratio = StatMultiPlot(main.data.div.sel, CalcAVGRatio, "AVGRatio") + theme_bw()
#ggsave("~/ts.avgratio.png")
#corr.omega = StatMultiPlot(main.data.div.sel, CalcCorrOmega, "Fitness Surface Correlation") + theme_bw()
#ggsave("~/ts.corr.omega.png")

load("./rdatas/non.cor.stabilizing.Rdata")
#stab.corr.omega = NoSelStatMultiPlot(main.data.stabilizing, CalcCorrOmega, "Fitness Surface Correlation") + theme_bw()
#ggsave("~.pngs/ts.stab.corr.omega.png")
#stab.r2 = NoSelStatMultiPlot(main.data.stabilizing, MapCalcR2, "Mean Squared Correlations") + theme_bw()
#ggsave("~.pngs/ts.stab.r2.png")
#stab.flex = NoSelStatMultiPlot(main.data.stabilizing, function(mat.list) CalcIsoStat(mat.list, Flexibility), "Directional Flexibility") + theme_bw()
#ggsave("~.pngs/ts.stab.flex.png")
#stab.evol = NoSelStatMultiPlot(main.data.stabilizing, function(mat.list) CalcIsoStat(mat.list, Evolvability), "Directional Evolvability") + theme_bw()
#ggsave("~.pngs/ts.stab.evol.png")
#stab.auto = NoSelStatMultiPlot(main.data.stabilizing, function(mat.list) CalcIsoStat(mat.list, Autonomy), "Directional Autonomy") + theme_bw()
#ggsave("~.pngs/ts.stab.auto.png")
#stab.avg.ratio = NoSelStatMultiPlot(main.data.stabilizing, CalcAVGRatio, "AVGRatio") + theme_bw()
#ggsave("~.pngs/ts.stab.avgratio.png")

load("./rdatas/non.cor.drift.Rdata")
#drift.corr.omega = NoSelStatMultiPlot(main.data.drift, CalcCorrOmega, "Fitness Surface Correlation") + theme_bw()
#ggsave("~.pngs/ts.drift.corr.omega.png")
#drift.r2 = NoSelStatMultiPlot(main.data.drift, MapCalcR2, "Mean Squared Correlations") + theme_bw()
#ggsave("~.pngs/ts.drift.r2.png")
#drift.flex = NoSelStatMultiPlot(main.data.drift, function(mat.list) CalcIsoStat(mat.list, Flexibility), "Directional Flexibility") + theme_bw()
#ggsave("~.pngs/ts.drift.flex.png")
#drift.evol = NoSelStatMultiPlot(main.data.drift, function(mat.list) CalcIsoStat(mat.list, Evolvability), "Directional Evolvability") + theme_bw()
#ggsave("~.pngs/ts.drift.evol.png")
#drift.auto = NoSelStatMultiPlot(main.data.drift, function(mat.list) CalcIsoStat(mat.list, Autonomy), "Directional Autonomy") + theme_bw()
#ggsave("~.pngs/ts.drift.auto.png")
#drift.avg.ratio = NoSelStatMultiPlot(main.data.drift, CalcAVGRatio, "AVGRatio") + theme_bw()
#ggsave("~.pngs/ts.drift.avgratio.png")

#drift.stab.corr.omega = NoSelStatMultiPlotMultiPop(main.data.drift, main.data.stabilizing , CalcCorrOmega, "Fitness Surface Correlation") + theme_bw()
#ggsave("~.pngs/ts.drift.stab.corr.omega.png")
#drift.stab.r2 = NoSelStatMultiPlotMultiPop(main.data.drift, main.data.stabilizing, MapCalcR2, "Mean Squared Correlations") + theme_bw()
#ggsave("~.pngs/ts.drift.stab.r2.png")
#drift.stab.flex = NoSelStatMultiPlotMultiPop(main.data.drift, main.data.stabilizing, function(mat.list) CalcIsoStat(mat.list, Flexibility), "Directional Flexibility") + theme_bw()
#ggsave("~.pngs/ts.drift.stab.flex.png")
#drift.stab.evol = NoSelStatMultiPlotMultiPop(main.data.drift, main.data.stabilizing, function(mat.list) CalcIsoStat(mat.list, Evolvability), "Directional Evolvability") + theme_bw()
#ggsave("~.pngs/ts.drift.stab.evol.png")
#drift.stab.auto = NoSelStatMultiPlotMultiPop(main.data.drift, main.data.stabilizing, function(mat.list) CalcIsoStat(mat.list, Autonomy), "Directional Autonomy") + theme_bw()
#ggsave("~.pngs/ts.drift.stab.auto.png")

drift.stab.avg.ratio = NoSelStatMultiPlotMultiPop(non.cor.drift, non.cor.stabilizing, AVGRatioSimple, "AVGRatio")
drift.stab.avg.ratio.plot = drift.stab.avg.ratio + theme_bw() +
scale_colour_discrete(name = "Selective regime",
                      labels = c("Drift","Correlated Stabilizing Selection")) +
  theme(legend.position = c(0, 1),
        legend.justification = c(0, 0.85),
        legend.background = element_rect(fill="transparent"))
ggsave("~/ts_drift_stab_avgratio.png", width= 18, height = 9, units =  "cm", dpi = 600)

burn.in.pop = ReadFolder("burn_in", sel.type = "burn.in", direct.sel=F)
burn.in.avg = PlotCorrs(burn.in.pop$p.cor)
burn.in.plot = burn.in.avg + theme_bw() +
  annotate("text", x = 10000,
                y = 0.09, label = "Uncorrelated Stabilizing\n Selection", angle=0, size=3,
                colour='black', face="bold") +
  geom_segment(aes(x = 10000, y = 0.1, xend = 10000, yend = 0.13), colour='black', size=0.5, arrow = arrow(length = unit(0.5, "cm"))) +
  theme(legend.position = c(1, 1),
        legend.justification = c(1, 1),
        legend.background = element_rect(fill="transparent"))
ggsave("~/burnin_p_avg_corr.png", width= 18, height = 9, units =  "cm", dpi = 600)

burn.in.omega.1 = ReadFolder("burn_in_omega_1", sel.type = "burn.in", direct.sel=F)
burn.in.omega.10 = ReadFolder("burn_in", sel.type = "burn.in", direct.sel=F)
burn.in.omega.100 = ReadFolder("burn_in_omega_100", sel.type = "burn.in", direct.sel=F)
gvar_omega1 = ldply(burn.in.omega.1$h.var)
gvar_omega10 = ldply(burn.in.omega.10$h.var)
gvar_omega100 = ldply(burn.in.omega.100$h.var)
m.gvar_omega1 = melt(gvar_omega1)
m.gvar_omega1$omega = 1
m.gvar_omega10 = melt(gvar_omega10)
m.gvar_omega10$omega = 10
m.gvar_omega100 = melt(gvar_omega100)
m.gvar_omega100$omega = 100
gvar_omega = rbind(m.gvar_omega1, m.gvar_omega10, m.gvar_omega100)
gvar_omega$omega = as.factor(gvar_omega$omega)
burn.in.avg = ggplot(gvar_omega, aes(as.numeric(.id), value, group = omega, color = omega)) + geom_point()
burn.in.plot = burn.in.avg + theme_bw() +
  annotate("text", x = 10000,
                y = 0.09, label = "Uncorrelated Stabilizing\n Selection", angle=0, size=3,
                colour='black', face="bold") +
    labs(x = 'Generations', y = 'Heritabilities') +
    scale_colour_discrete(name = expression(paste(V[omega]))) +
 geom_vline(aes(xintercept = 10000), color = "black") +_
  theme(legend.position = c(0, 1),
        legend.justification = c(0, 1),
        legend.background = element_rect(fill="transparent"))
ggsave("~/burnin_h_var.png", width= 18, height = 9, units =  "cm", dpi = 600)

selected_number = read.csv("../py/notebooks/diff_selection.csv")
names(selected_number)[1] = 'omega_var'
selected_number$omega_var = selected_number$omega_var + 1
m_selected = melt(selected_number, id.var = 'omega_var')
names(m_selected)
num_selected = ggplot(m_selected, aes(omega_var, value, group = omega_var)) + geom_boxplot() +
geom_vline(aes(xintercept = 10), color = "black") + theme_bw() + labs(y = "Number of reproducing individuals", x = expression(paste(V[omega])))
ggsave("~/num_ind_surv.png", width= 20, height = 15, units =  "cm", dpi = 600)

fitness_variance = read.csv("../py/notebooks/diff_selection_var.csv")
m_fit = melt(fitness_variance)
m_fit$omega_var = rep(1:100, each = 10)
var_fitness = ggplot(filter(m_fit, omega_var != 1), aes(omega_var, value, group = omega_var)) + geom_boxplot() +
geom_vline(aes(xintercept = 10), color = "black") + theme_bw() + labs(y = "Variance of individual fitness", x = expression(paste(V[omega])))
ggsave("~/var_ind_fitness.png", width= 20, height = 15, units =  "cm", dpi = 600)

png("~/fitness_omega_scan.png", height = 15, width = 30, units="cm", res = 600)
comparison_plot = grid.arrange(num_selected, var_fitness, ncol = 2)
dev.off()

library(mvtnorm)
library(cpcbp)
omega = as.matrix(read.table("~/projects/evomod/c-gsl/input/omega.csv"))
P = non.cor.div.sel[[198]]$p.cov[[10000]]
write.csv2(rbind(omega, P),"~/Desktop/cpc-mats.csv"  )
Ppop = rmvnorm(20, sigma = P)
Omegapop = rmvnorm(20, sigma = omega)
pop = rbind(Ppop, Omegapop)
f = rep(c("p", "o"), e = 20)
out = phillips.cpc(pop, f)

if(!require(gridExtra)){install.packages('gridExtra'); library(gridExtra)}
if(!require(ellipse)){install.packages('ellipse'); library(ellipse)}

library(xtable)
xtable(cbind(eigen(omega)$vectors[,1:2], eigen(P)$vectors[,1:2]))

omega[omega == 0] <- 0.000001
eigen_omega = eigen(omega)

cov_mat_1 = non.cor.div.sel[[198]]$p.cov[[1]]
pop_mat_omega_1 = t(eigen_omega$vectors) %*% cov_mat_1 %*% eigen_omega$vectors

cov_mat_2 = non.cor.div.sel[[198]]$p.cov[[10000]]
pop_mat_omega_2= t(eigen_omega$vectors) %*% cov_mat_2 %*% eigen_omega$vectors

plot(ellipse((pop_mat_omega_2[1:2, 1:2])), col = 'red')
points(ellipse((pop_mat_omega_1[1:2, 1:2])))


