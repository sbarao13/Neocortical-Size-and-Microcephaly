```{r init}
library(Matrix)
library(tidyverse)
library(biomaRt)
library(monocle3)
library(rgl)
library(tricycle)
library(SignacX)
library(princurve)
library(ggplot2)
library(Hmisc)
library(pheatmap)
library("ComplexHeatmap")
library(circlize)
library(dplyr)
library(ggrepel)
library(latex2exp)
library(scales)
```

```{r loadData}
cds<-readRDS("BRN1-2.rds")
fname <- 'Figure_S6'
```

```{r Pannel E}
genes <- c('Robo1','Robo2','Slit2','Plxna2','Plxna4','Plxnd1','Sema3c','Sema6d','Dcc','Unc5a','Epha3','Epha5','Epha7','Ephb1','Efnb1','Efnb2','Efnb3','Ncam1,'Nrp1','Nrp2',
           'Nrxn1','Draxin','Reln','Bsg','Gap43','Kif5c')
indx<-which(fData(cds)$gene_short_name %in% genes)
cdsP <- cds[indx,pData(cds)$celltype %in% c("Neuron")]

total <- rowSums(exprs(cdsP[,pData(cdsP)$age == 12.5]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age == 12.5]))
h12 <- data.frame(rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.control")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.control")])))/total 
rownames(h12) <- fData(cdsP)$gene_short_name
colnames(h12) <- c('Control')
h12$dKO <-rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.ko")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.ko")]))/total
h12[is.na(h12)] <- 0
h12 <- (h12-min(h12))/(max(h12)-min(h12))

total <- rowSums(exprs(cdsP[,pData(cdsP)$age == 14.5]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age == 14.5]))
h14 <- data.frame(rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.control")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.control")])))/total
rownames(h14) <- fData(cdsP)$gene_short_name
colnames(h14) <- c('Control')
h14$dKO <-rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.ko")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.ko")]))/total
h14[is.na(h14)] <- 0
h14 <- (h14-min(h14))/(max(h14)-min(h14))

expression12 <- reshape2::melt(as.matrix(h12),varnames = c('genes','condition'),value.name = 'mean')
percent12 <- data.frame(rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.control')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.control')]))[2])
rownames(percent12) <- fData(cdsP)$gene_short_name
colnames(percent12) <- c('Control')
percent12$dKO <- rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.ko')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.ko')]))[2]
percent12 <- reshape2::melt(as.matrix(percent12),varnames = c('genes','condition'),value.name = 'percent')

expression14 <- reshape2::melt(as.matrix(h14),varnames = c('genes','condition'),value.name = 'mean')
percent14 <- data.frame(rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.control')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.control')]))[2])
rownames(percent14) <- fData(cdsP)$gene_short_name
colnames(percent14) <- c('Control')
percent14$dKO <- rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.ko')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.ko')]))[2]
percent14 <- reshape2::melt(as.matrix(percent14),varnames = c('genes','condition'),value.name = 'percent')

pdf(paste0("plots/",fname,"_PannelE_Neuron.pdf"))

  ggplot(reshape::melt(as.matrix(h12)), aes(x = X2, y =X1 , fill = value))+ geom_tile(color = "white")+     
    scale_fill_gradientn(colors=viridis(16),guide="colorbar",limits = c(0,1))+ coord_fixed(ratio = 0.8) + 
    scale_y_discrete(limits = rev(genes)) + 
    labs(title = 'E12.5 Neuron', x = 'Condition',y = 'Genes')+ theme(panel.grid.major = element_blank(),   
                                                                 panel.grid.minor = element_blank(),
                                                                 panel.background = element_blank())
  
  ggplot(reshape::melt(as.matrix(h14)), aes(x = X2, y =X1 , fill = value))+ geom_tile(color = "white")+ 
    scale_fill_gradientn(colors=viridis(16),guide="colorbar",limits = c(0,1))+ coord_fixed(ratio = 0.8) + 
    scale_y_discrete(limits = rev(genes)) + 
    labs(title = 'E14.5 Neuron', x = 'Condition',y = 'Genes')+ theme(panel.grid.major = element_blank(),   
                                                                 panel.grid.minor = element_blank(),
                                                                 panel.background = element_blank())
  dot12 <- merge(expression12,percent12)
  ggplot(dot12,aes(x=condition, y = genes, color = mean, size = percent)) + 
    geom_point()  + scale_y_discrete(limits = rev(genes)) +
    scale_color_gradientn(colors = viridis(16),name = 'mean expression',limits = c(0,1))+
    scale_size(name = 'percentage per condition', range = c(0, 10))+ monocle3:::monocle_theme_opts() +
    labs(title = 'E12.5 Neuron')
  
  dot14 <- merge(expression14,percent14)
  ggplot(dot14,aes(x=condition, y = genes, color = mean, size = percent)) + 
    geom_point()  + scale_y_discrete(limits = rev(genes)) +
    scale_color_gradientn(colors = viridis(16),name = 'mean expression',limits = c(0,1))+
    scale_size(name = 'percentage per condition', range = c(0, 10))+ monocle3:::monocle_theme_opts() +
    labs(title = 'E14.5 Neuron')
  
dev.off()
```
```{r Figure S6 Pannel C}
GO <- read.csv('FigureS6_selected_GO.csv')

names(GO) <- make.names(names(GO))
GO$Term <- gsub("\\s*\\([^\\)]+\\)","",GO$Term)
GO$rank <- row.names(GO)

pdf(paste0("plots/",fname,"_PannelD.pdf"),width=12,height=10)
  ggplot(head(GO,15),aes(x = -log10(Adjusted.P.value), y = rank)) + 
    geom_bar(stat="identity")+
    scale_y_discrete(limits = head(GO,15)$rank) + 
    labs(title = 'GO Terms in E14.5 Neuron no tricycle', x = TeX(r"($-log_{10}$ Adjusted P-value)"),y = 'GO Terms') +
    geom_text(aes(0,label = Term),colour = "black",hjust = 0)+
    monocle3:::monocle_theme_opts()
dev.off()
```

```{r Pannel S7B}
fname <- 'FigureS7'
genes<-c('Ccnd2', 'Ccna2', 'Cdk1', 'Cdk2ap1', 'Cdkn2d', 'Cdkn2c', 'Cdk4', 'Cdk6', 'Cdc45', 'Kif11', 'Gmnn', 
           'Clspn', 'Cdc25a', 'Cdc25b', 'Top2b', 'Rrm1', 'Rrm2', 'Fau', 'Btg2', 'Ppp2r2b')
indx<-which(fData(cds)$gene_short_name %in% genes)
cdsP <- cds[indx,pData(cds)$celltype %in% c("BP")]

total <- rowSums(exprs(cdsP[,pData(cdsP)$age == 12.5]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age == 12.5]))
h12 <- data.frame(rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.control")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.control")])))/total 
rownames(h12) <- fData(cdsP)$gene_short_name
colnames(h12) <- c('Control')
h12$dKO <-rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.ko")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.ko")]))/total
h12[is.na(h12)] <- 0
h12 <- (h12-min(h12))/(max(h12)-min(h12))

total <- rowSums(exprs(cdsP[,pData(cdsP)$age == 14.5]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age == 14.5]))
h14 <- data.frame(rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.control")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.control")])))/total
rownames(h14) <- fData(cdsP)$gene_short_name
colnames(h14) <- c('Control')
h14$dKO <-rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.ko")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.ko")]))/total
h14[is.na(h14)] <- 0
h14 <- (h14-min(h14))/(max(h14)-min(h14))

expression12 <- reshape2::melt(as.matrix(h12),varnames = c('genes','condition'),value.name = 'mean')
percent12 <- data.frame(rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.control')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.control')]))[2])
rownames(percent12) <- fData(cdsP)$gene_short_name
colnames(percent12) <- c('Control')
percent12$dKO <- rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.ko')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.ko')]))[2]
percent12 <- reshape2::melt(as.matrix(percent12),varnames = c('genes','condition'),value.name = 'percent')

expression14 <- reshape2::melt(as.matrix(h14),varnames = c('genes','condition'),value.name = 'mean')
percent14 <- data.frame(rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.control')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.control')]))[2])
rownames(percent14) <- fData(cdsP)$gene_short_name
colnames(percent14) <- c('Control')
percent14$dKO <- rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.ko')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.ko')]))[2]
percent14 <- reshape2::melt(as.matrix(percent14),varnames = c('genes','condition'),value.name = 'percent')

pdf(paste0("plots/",fname,"_PannelB_BP.pdf"))

  ggplot(reshape::melt(as.matrix(h12)), aes(x = X2, y =X1 , fill = value))+ geom_tile(color = "white")+     
    scale_fill_gradientn(colors=viridis(16),guide="colorbar",limits = c(0,1))+ coord_fixed(ratio = 0.8) + 
    scale_y_discrete(limits = rev(genes)) + 
    labs(title = 'E12.5 BP', x = 'Condition',y = 'Genes')+ theme(panel.grid.major = element_blank(),   
                                                                 panel.grid.minor = element_blank(),
                                                                 panel.background = element_blank())
  
  ggplot(reshape::melt(as.matrix(h14)), aes(x = X2, y =X1 , fill = value))+ geom_tile(color = "white")+ 
    scale_fill_gradientn(colors=viridis(16),guide="colorbar",limits = c(0,1))+ coord_fixed(ratio = 0.8) + 
    scale_y_discrete(limits = rev(genes)) + 
    labs(title = 'E14.5 BP', x = 'Condition',y = 'Genes')+ theme(panel.grid.major = element_blank(),   
                                                                 panel.grid.minor = element_blank(),
                                                                 panel.background = element_blank())
  dot12 <- merge(expression12,percent12)
  ggplot(dot12,aes(x=condition, y = genes, color = mean, size = percent)) + 
    geom_point()  + scale_y_discrete(limits = rev(genes)) +
    scale_color_gradientn(colors = viridis(16),name = 'mean expression',limits = c(0,1))+
    scale_size(name = 'percentage per condition', range = c(0, 10))+ monocle3:::monocle_theme_opts() +
    labs(title = 'E12.5 BP')
  
  dot14 <- merge(expression14,percent14)
  ggplot(dot14,aes(x=condition, y = genes, color = mean, size = percent)) + 
    geom_point()  + scale_y_discrete(limits = rev(genes)) +
    scale_color_gradientn(colors = viridis(16),name = 'mean expression',limits = c(0,1))+
    scale_size(name = 'percentage per condition', range = c(0, 10))+ monocle3:::monocle_theme_opts() +
    labs(title = 'E14.5 BP')
  
dev.off()

genes <- c('Ccnd1','Ccnd2','Ccnd3','Ccne2','Ccna2','Cdk1','Cdk5rap3','Cdk2ap1', 'Cdkn2d', 'Cdk5r1',
           'Cdk5rap2','Cdk2ap2','Cdk4','Cdk12', 'Cdk6','Cdc20','Kif11','Cdc45','Gmnn', 'Prkca')
cdsP <- cds[indx,pData(cds)$celltype %in% c("AP")]

total <- rowSums(exprs(cdsP[,pData(cdsP)$age == 12.5]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age == 12.5]))
h12 <- data.frame(rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.control")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.control")])))/total 
rownames(h12) <- fData(cdsP)$gene_short_name
colnames(h12) <- c('Control')
h12$dKO <-rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.ko")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("12.5.ko")]))/total
h12[is.na(h12)] <- 0
h12 <- (h12-min(h12))/(max(h12)-min(h12))

total <- rowSums(exprs(cdsP[,pData(cdsP)$age == 14.5]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age == 14.5]))
h14 <- data.frame(rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.control")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.control")])))/total
rownames(h14) <- fData(cdsP)$gene_short_name
colnames(h14) <- c('Control')
h14$dKO <-rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.ko")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.ko")]))/total
h14[is.na(h14)] <- 0
h14 <- (h14-min(h14))/(max(h14)-min(h14))

expression12 <- reshape2::melt(as.matrix(h12),varnames = c('genes','condition'),value.name = 'mean')
percent12 <- data.frame(rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.control')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.control')]))[2])
rownames(percent12) <- fData(cdsP)$gene_short_name
colnames(percent12) <- c('Control')
percent12$dKO <- rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.ko')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('12.5.ko')]))[2]
percent12 <- reshape2::melt(as.matrix(percent12),varnames = c('genes','condition'),value.name = 'percent')

expression14 <- reshape2::melt(as.matrix(h14),varnames = c('genes','condition'),value.name = 'mean')
percent14 <- data.frame(rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.control')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.control')]))[2])
rownames(percent14) <- fData(cdsP)$gene_short_name
colnames(percent14) <- c('Control')
percent14$dKO <- rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.ko')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.ko')]))[2]
percent14 <- reshape2::melt(as.matrix(percent14),varnames = c('genes','condition'),value.name = 'percent')

pdf(paste0("plots/",fname,"_PannelB_AP.pdf"))

  ggplot(reshape::melt(as.matrix(h12)), aes(x = X2, y =X1 , fill = value))+ geom_tile(color = "white")+     
    scale_fill_gradientn(colors=viridis(16),guide="colorbar",limits = c(0,1))+ coord_fixed(ratio = 0.8) + 
    scale_y_discrete(limits = rev(genes)) + 
    labs(title = 'E12.5 AP', x = 'Condition',y = 'Genes')+ theme(panel.grid.major = element_blank(),   
                                                                 panel.grid.minor = element_blank(),
                                                                 panel.background = element_blank())
  
  ggplot(reshape::melt(as.matrix(h14)), aes(x = X2, y =X1 , fill = value))+ geom_tile(color = "white")+ 
    scale_fill_gradientn(colors=viridis(16),guide="colorbar",limits = c(0,1))+ coord_fixed(ratio = 0.8) + 
    scale_y_discrete(limits = rev(genes)) + 
    labs(title = 'E14.5 AP', x = 'Condition',y = 'Genes')+ theme(panel.grid.major = element_blank(),   
                                                                 panel.grid.minor = element_blank(),
                                                                 panel.background = element_blank())
  dot12 <- merge(expression12,percent12)
  ggplot(dot12,aes(x=condition, y = genes, color = mean, size = percent)) + 
    geom_point()  + scale_y_discrete(limits = rev(genes)) +
    scale_color_gradientn(colors = viridis(16),name = 'mean expression',limits = c(0,1))+
    scale_size(name = 'percentage per condition', range = c(0, 10))+ monocle3:::monocle_theme_opts() +
    labs(title = 'E12.5 AP')
  
  dot14 <- merge(expression14,percent14)
  ggplot(dot14,aes(x=condition, y = genes, color = mean, size = percent)) + 
    geom_point()  + scale_y_discrete(limits = rev(genes)) +
    scale_color_gradientn(colors = viridis(16),name = 'mean expression',limits = c(0,1))+
    scale_size(name = 'percentage per condition', range = c(0, 10))+ monocle3:::monocle_theme_opts() +
    labs(title = 'E14.5 AP')
  
dev.off()
```

```{r Pannel S6B, S7C and 8F}
fname <- 'FigureS6'
cdsP <- cds[,pData(cds)$celltype %in% c('Neuron')]

gene_fits <- fit_models(cdsP[,pData(cdsP)$age==14.5], model_formula_str = "~Batch+condition",cores = 10)
fit_coefs <- coefficient_table(gene_fits)
unique(coefficient_table(gene_fits)$term)

sig_terms <- DEcondition %>% filter (q_value < 0.001 & std_err > 0)
sig_genes <- sig_terms %>% pull(gene_short_name)

s2 <- sig_terms
s2 <- s2[s2$std_err < 0.15,]
s2$label <- s2$gene_short_name
s2$q_value[s2$q_value == 0] <- 1E-310

s2 <- s2[!grepl('Rpl',s2$gene_short_name),]
s2 <- s2[!grepl('Rps',s2$gene_short_name),]
s2 <- s2[!grepl('mt-',s2$gene_short_name),]

highlight <- c('') #fill in the gene names
pdf(paste0("plots/",fname,"_PannelB_Neuron.pdf"))
  ggplot(s2,aes(x=normalized_effect,y=-log10(q_value),label=label)) +
    geom_point(data = s2[!s2$gene_short_name %in%(highlight),],aes(x=normalized_effect,y=-log10(q_value),label=label), color = "black")+
    geom_point(data = s2[s2$gene_short_name %in%c(highlight),],aes(x=normalized_effect,y=-log10(q_value),label=label), color = "red")+
    geom_text_repel(data =s2[s2$gene_short_name %in%c(highlight),], max.overlaps = Inf,direction = 'y') +
    xlab(paste("Normalized effect size conditionko")) +
    geom_vline(xintercept = 0,linetype="dashed") +
    ylab(TeX(r"($-log_{10}$ q-value)")) +
    theme(legend.position = "none") + 
    monocle3:::monocle_theme_opts()
dev.off()

cdsP <- cds[,pData(cds)$celltype %in% c('AP')]

gene_fits <- fit_models(cdsP[,pData(cdsP)$age==14.5], model_formula_str = "~Batch+condition",cores = 10)
fit_coefs <- coefficient_table(gene_fits)
unique(coefficient_table(gene_fits)$term)

sig_terms <- DEcondition %>% filter (q_value < 0.001 & std_err > 0)
sig_genes <- sig_terms %>% pull(gene_short_name)

s2 <- sig_terms
s2 <- s2[s2$std_err < 0.15,]
s2$label <- s2$gene_short_name
s2$q_value[s2$q_value == 0] <- 1E-310

s2 <- s2[!grepl('Rpl',s2$gene_short_name),]
s2 <- s2[!grepl('Rps',s2$gene_short_name),]
s2 <- s2[!grepl('mt-',s2$gene_short_name),]

highlight <- c('') #fill in the gene names
pdf(paste0("plots/",fname,"_PannelC_AP.pdf"))
  ggplot(s2,aes(x=normalized_effect,y=-log10(q_value),label=label)) +
    geom_point(data = s2[!s2$gene_short_name %in%(highlight),],aes(x=normalized_effect,y=-log10(q_value),label=label), color = "black")+
    geom_point(data = s2[s2$gene_short_name %in%c(highlight),],aes(x=normalized_effect,y=-log10(q_value),label=label), color = "red")+
    geom_text_repel(data =s2[s2$gene_short_name %in%c(highlight),], max.overlaps = Inf,direction = 'y') +
    xlab(paste("Normalized effect size conditionko")) +
    geom_vline(xintercept = 0,linetype="dashed") +
    ylab(TeX(r"($-log_{10}$ q-value)")) +
    theme(legend.position = "none") + 
    monocle3:::monocle_theme_opts()
dev.off()

cdsP <- cds[,pData(cds)$celltype %in% c('BP')]

gene_fits <- fit_models(cdsP[,pData(cdsP)$age==14.5], model_formula_str = "~Batch+condition",cores = 10)
fit_coefs <- coefficient_table(gene_fits)
unique(coefficient_table(gene_fits)$term)

sig_terms <- DEcondition %>% filter (q_value < 0.001 & std_err > 0)
sig_genes <- sig_terms %>% pull(gene_short_name)

s2 <- sig_terms
s2 <- s2[s2$std_err < 0.15,]
s2$label <- s2$gene_short_name
s2$q_value[s2$q_value == 0] <- 1E-310

s2 <- s2[!grepl('Rpl',s2$gene_short_name),]
s2 <- s2[!grepl('Rps',s2$gene_short_name),]
s2 <- s2[!grepl('mt-',s2$gene_short_name),]

highlight <- c(' ') #fill in the gene names
pdf(paste0("plots/",fname,"_PannelC_BP.pdf"))
  ggplot(s2,aes(x=normalized_effect,y=-log10(q_value),label=label)) +
    geom_point(data = s2[!s2$gene_short_name %in%(highlight),],aes(x=normalized_effect,y=-log10(q_value),label=label), color = "black")+
    geom_point(data = s2[s2$gene_short_name %in%c(highlight),],aes(x=normalized_effect,y=-log10(q_value),label=label), color = "red")+
    geom_text_repel(data =s2[s2$gene_short_name %in%c(highlight),], max.overlaps = Inf,direction = 'y') +
    xlab(paste("Normalized effect size conditionko")) +
    geom_vline(xintercept = 0,linetype="dashed") +
    ylab(TeX(r"($-log_{10}$ q-value)")) +
    theme(legend.position = "none") + 
    monocle3:::monocle_theme_opts()
dev.off()
```

```{r Pannel S8 H'}
genes <- c('Robo2', 'Rorb', 'Cux2', 'Ptn', 'Sema6a', 'Rprm', 'Fezf2', 'Foxp2')
indx<-which(fData(cds)$gene_short_name %in% genes)
cdsP <- cds[indx,pData(cds)$celltype %in% c("BP")]

total <- rowSums(exprs(cdsP[,pData(cdsP)$age == 14.5]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age == 14.5]))
h14 <- data.frame(rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.control")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.control")])))/total
rownames(h14) <- fData(cdsP)$gene_short_name
colnames(h14) <- c('Control')
h14$dKO <-rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.ko")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.ko")]))/total
h14[is.na(h14)] <- 0
h14 <- (h14-min(h14))/(max(h14)-min(h14))

expression14 <- reshape2::melt(as.matrix(h14),varnames = c('genes','condition'),value.name = 'mean')
percent14 <- data.frame(rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.control')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.control')]))[2])
rownames(percent14) <- fData(cdsP)$gene_short_name
colnames(percent14) <- c('Control')
percent14$dKO <- rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.ko')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.ko')]))[2]
percent14 <- reshape2::melt(as.matrix(percent14),varnames = c('genes','condition'),value.name = 'percent')

pdf(paste0("plots/FigureS8_PannelF2.pdf"))

  ggplot(reshape::melt(as.matrix(h14)), aes(x = X2, y =X1 , fill = value))+ geom_tile(color = "white")+ 
    scale_fill_gradientn(colors=viridis(16),guide="colorbar",limits = c(0,1))+ coord_fixed(ratio = 0.8) + 
    scale_y_discrete(limits = rev(genes)) + 
    labs(title = 'E14.5 BP', x = 'Condition',y = 'Genes')+ theme(panel.grid.major = element_blank(),   
                                                                 panel.grid.minor = element_blank(),
                                                                 panel.background = element_blank())
  dot14 <- merge(expression14,percent14)
  ggplot(dot14,aes(x=condition, y = genes, color = mean, size = percent)) + 
    geom_point()  + scale_y_discrete(limits = rev(genes)) +
    scale_color_gradientn(colors = viridis(16),name = 'mean expression',limits = c(0,1))+
    scale_size(name = 'percentage per condition', range = c(0, 10))+ monocle3:::monocle_theme_opts() +
    labs(title = 'E14.5 BP')
  
dev.off()
```

```{r Pannel S10 I}
genes <- c('Pcnt', 'Akna', 'Cntrob', 'Ninl', 'Cep44', 'Cep295', 'Cep85l', 'Cep120', 'Plk1', 'Plk4', 'Cdk1', 'Ccnb1')
indx<-which(fData(cds)$gene_short_name %in% genes)
cdsP <- cds[indx,pData(cds)$celltype %in% c("AP","BP")]

total <- rowSums(exprs(cdsP[,pData(cdsP)$age == 14.5]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age == 14.5]))
h14 <- data.frame(rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.control")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.control")])))/total
rownames(h14) <- fData(cdsP)$gene_short_name
colnames(h14) <- c('Control')
h14$dKO <-rowSums(exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.ko")]))/rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c("14.5.ko")]))/total
h14[is.na(h14)] <- 0
h14 <- (h14-min(h14))/(max(h14)-min(h14))

expression14 <- reshape2::melt(as.matrix(h14),varnames = c('genes','condition'),value.name = 'mean')
percent14 <- data.frame(rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.control')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.control')]))[2])
rownames(percent14) <- fData(cdsP)$gene_short_name
colnames(percent14) <- c('Control')
percent14$dKO <- rowSums(!!exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.ko')]))/dim(exprs(cdsP[,pData(cdsP)$age.cond %in% c('14.5.ko')]))[2]
percent14 <- reshape2::melt(as.matrix(percent14),varnames = c('genes','condition'),value.name = 'percent')

pdf(paste0("plots/FigureS10_PannelI.pdf"))

  ggplot(reshape::melt(as.matrix(h14)), aes(x = X2, y =X1 , fill = value))+ geom_tile(color = "white")+ 
    scale_fill_gradientn(colors=viridis(16),guide="colorbar",limits = c(0,1))+ coord_fixed(ratio = 0.8) + 
    scale_y_discrete(limits = rev(genes)) + 
    labs(title = 'E14.5 AP', x = 'Condition',y = 'Genes')+ theme(panel.grid.major = element_blank(),   
                                                                 panel.grid.minor = element_blank(),
                                                                 panel.background = element_blank())
  dot14 <- merge(expression14,percent14)
  ggplot(dot14,aes(x=condition, y = genes, color = mean, size = percent)) + 
    geom_point()  + scale_y_discrete(limits = rev(genes)) +
    scale_color_gradientn(colors = viridis(16),name = 'mean expression',limits = c(0,1))+
    scale_size(name = 'percentage per condition', range = c(0, 10))+ monocle3:::monocle_theme_opts() +
    labs(title = 'E14.5 AP')
  
dev.off()
```
