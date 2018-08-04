library(edgeR)
library(gplots)

# Wczytanie tabeli zawierającej zliczenia

for (f in list.files("/home/ubuntu/lupinus-luteus-szkolenie/idxstats/")) {
  
  tmp <- read.table(paste("/home/ubuntu/lupinus-luteus-szkolenie/idxstats/", f, sep = ""))
  if (!exists("count_table")) {
    count_table <- tmp[, 3, drop = F]
    colnames(count_table) <- gsub(".txt", "", f)
    rownames(count_table) <- tmp$V1
    row_names <- tmp$V1
  } else {
    count_table[[gsub(".txt", "", f)]] <- tmp$V3
    cat("liczba wieszy w złej kolejności: ", sum(row_names != tmp$V1), "\n")
    row_names <- tmp$V1
  }
}

rm(f, tmp, row_names)


# Wczytanie tabeli zawierającej informacje o próbkach
sample_info <- read.table("/home/ubuntu/lupinus-luteus-szkolenie/fastq/sample-info.txt")

# Przygotowanie zmiennej przechowującej zliczenia oraz informacje o grupach eskperymentalnych
gr <- sample_info$V1
dgelist <- DGEList(counts = count_table, group = gr)

# Odfiltorwanie transkryptów o niskim poziomie ekspresji
keep <- rowSums(cpm(dgelist) > 1) >= 2
sum(keep)
dgelist <- dgelist[keep, , keep.lib.sizes=FALSE]

# Normalnizacja 
norm_data <- calcNormFactors(dgelist)

# Dopasowanie modelu
design <- model.matrix(~0+gr)
estim_disp_data <- estimateDisp(norm_data, design)
fit <- glmQLFit(estim_disp_data, design)

# Statystyla
stats <- glmQLFTest(fit, contrast = c(-1, 1))
stats_table <- topTags(stats, n = nrow(stats$table), sort.by = "none")$table

stats_table <- stats_table[match(rownames(count_table), rownames(stats_table)), ] # aby stats_table miało taki sam wymiar jak count_table

wh <- which(stats_table$PValue < 0.05)
length(wh)


plot_data <- count_table[wh, ]
plot_data <- as.matrix(plot_data)

heatmap.2(plot_data, 
          scale = "row",
          trace = "none", 
          distfun = function(x) {as.dist(1-cor(t(x)))},
          dendrogram = "row",
          col = bluered(50))

