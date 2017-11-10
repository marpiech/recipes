### Lab 1
Celem zadania jest identyfikacja populacji komórek w korze mózgowej na podstawie profilu ekspresji genów (patrz wykład) oraz wybranie genów markerowych dla każdej populacji. 

Należy poklasyfikować komórki według i wzorca ekspresji. Zbiór danych dotyczy >1800 komórek nerwowych i ich trankryptomów (> 20000 genów każdy).

Dane znajdują się pod adresem https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE71585.
Należy skorzystać z pliku GSE71585_RefSeq_RPKM.csv.gz.
Publikacja znajduje się pod adresem https://www.ncbi.nlm.nih.gov/pubmed/26727548.

## 1
`otworzyć rstudio`

# 2
`pobrać plik`

# 3
`podejrzeć plik`

W pierwszym kroku należy zredukować ilość wymiarów (ktorych początkowo jest tyle ile jest genów) przy pomocy analizy komponentów głównych. W kolejnym kroku odlożyć komórki według opisu na pierwszych dwóch osiach PCA. Można wybrać klastry komórek i dalej je różnicować. Ostatecznie powinno powstać 20-60 populacji komórek. Należy je nazwać i zwizualizować oraz poklastrować. Można używać także hierarchicznej klasteryzacji lub k-means.
