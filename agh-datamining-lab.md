## Laboratoria data mining - (AGH IET) Marcin Piechota, PhD

## Spis treści
1. [Lab 1](#lab1) 10.11.2017
2. [Lab 2](#lab2) 17.11.2017

## Lab1
Celem zadania jest identyfikacja populacji komórek w korze mózgowej na podstawie profilu ekspresji genów (patrz wykład) oraz wybranie genów markerowych dla każdej populacji. Na zadanie będą poświęcone trzy laboratoria.

1. Feature selection, redukcja wymiarowości
2. Hierachiczna klasteryzacja, identyfikacja markerów
3. Wizualizacja i omówienie wyników

Należy poklasyfikować komórki według i wzorca ekspresji. Zbiór danych dotyczy >1800 komórek nerwowych i ich trankryptomów (> 20000 genów każdy).

Dane znajdują się pod adresem https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE71585.
Należy skorzystać z pliku GSE71585_RefSeq_RPKM.csv.gz.
Publikacja znajduje się pod adresem https://www.ncbi.nlm.nih.gov/pubmed/26727548.

### 1
```
otworzyć rstudio i utworzyć nowy projekt
```

### 2
```
pobrać plik
```

### 3
```
podejrzeć plik
```

Można wykorzystać `cat`, `head`, `cut`, `gzip -d`, `gunzip`

### 4
```
wczytać plik
```

R. Funkcja `read.csv`

### 5
```
policzyć średnią z każdego wiersza
```

Wykorzystać `apply` zamiast `for`. W domu przeczytać dlaczego w R korzystamy z `apply`.

### 6
```
policzyć decyle, średnią, medianę, kwartyle z każdego wiersza
```

Można wykorzystać funckję `summary` dla wektorów liczbowych oraz funckję `quantile`

### 7
```
obejrzec rozkłady średnich, median, różnic między kwartylami
```

Wykorzystać funckję `hist`. Rozkłady skośne można oglądać wykorzystując transformację `log2(1 + x)`

### 8
```
wykonać redukcję wymiarów przy pomocy PCA dla pierwszych 300 genów
```

Wykorzystać funkcję `prcomp`

### 9
```
przedstawić na wykresie typu scatterplot rozłożenie próbek na dwóch pierwszych osiach PCA1 i PCA2
```

Funckja `plot`

### 10
```
przefiltrować features na podstawie rozkładu i powtórzyć kroki 8 i 9 aż do uzyskania rozdzielonych "chmurek"
```

Można wykorzystać funcję `which`

## Lab2
Kod do Lab 1
```
url <- "http://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE71585&format=file&file=GSE71585%5FRefSeq%5FRPKM%2Ecsv%2Egz"
file <- "rpkm.csv.gz"
download.file(url,file)
data <- read.csv(
  gzfile(file),
  sep=",",
  header=TRUE,
  stringsAsFactors=FALSE,
  row.names=1)

colnames(data) <- 1:ncol(data)
which.columns <- 1:ncol(data)

selected.data <- data[,which.columns]
selected.desc <- data.frame(t(apply(selected.data, 1, summary)),
                   t(apply(selected.data, 1, quantile, prob = seq(0, 1, length = 11))))
which.rows <- which(selected.desc$Min < 0.5 & selected.desc$Max < 500 & selected.desc$X20. < 1 & selected.desc$X80. > 30)
pca <- prcomp(t(selected.data[which.rows,]))
plot(pca$x[,"PC1"], pca$x[,"PC2"])
```
### 1
```
Utworzyć macierz odległości euklidesowych pomiędzy "komórkami" w przestrzeni rozpiętej na osiach PCA1 i PCA2
```
Wykorzystać funkcję `dist`

### 2
```
Wykonać hierarchiczną klasteryzację na utworzonej macierzy odległości. Wykorzystać metodę składania 'average'
```
Funckja `hclust`

### 3
```
Wykonać dendrogram 
```
Funckja `as.dendrogram`

### 4
```
Narysować dendrogram
```

### 5
```
Przedstawić macierz odległości za pomocą mapy cieplnej. Do mapy cieplnej wykorzystać utworzony dendrogram.
```
Funckja `heatmap`

### 6
```
Wykonać kroki 2 do 5 (bez 4) na innych metodach składania. Wnioski?
```

### 7
```
Podzielić drzewo na dwie gałęzie odchodzące od korzenia.
```
Funkcja `cutree`

### 8
```
Na wszystkich genach poszukać najlepszego markera rozdzielającego dwie gałęzie.
```
Czy istnieje pojedynczy marker rozdzielający elementy z czułością i specyficznością większą od 98%. Jaka jest nazwa tego genu? Czy istnieje marker mniej licznej gałęzi? Czy istnieje marker bardziej licznej gałęzi?

### 8.1
```
Narysować krzywą ROC dla predyktora
```
pakiet `pROC`. Funkcja `roc`

### 9
```
Usunąć komórki źle sklasyfikowane przez marker - można przypisać im klasę "0". Pozostałym przypisać klasy "1" i "2". Można także nazwać je od markera.
```

### 10
```
Na wydzielonych klasach powtórzyć iteracyjnie procedurę, aż do momentu, w którym nie da się znaleźc markera dla żadnej z gałęzi.
```
Opisać komórki klasami
