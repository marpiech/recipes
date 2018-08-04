# Opis danych
W katalogu domowym znajduje się folder lupinus-luteus-szkolenie, zawierający wszystkie potrzebne dane do przeprowadzenia analizy. 

Aby wyświetlić jego zawartość należy użyć polecenia ls.
``` sh
ls lupinus-luteus-szkolenie
```

W katalogu fastq znajdują się pliki fastq dla wybranych sześciu próbek. Odczyty zostały odpowiednio przygotowane, aby możliwe było przeprowadzenie przykładowej analizy w stosunkowo krótkim czasie.

W katalogu annotation znajdują się odpowiednio przygotowane pliki fasta, które zostaną omówione w dalszej części.

Poleceniem cd możemy przejść do katalogu lupinus-luteus-szkolenie.

``` sh
cd lupinus-luteus-szkolenie
```

W celu zachowania porządku, wyniki kolejnych analiz będziemy przechowywać w odpowiednio nazwanych katalogach (nazwy powinny wskazywać na to, co znajduje się wewnątrz).

# Analiza jakości odczytów
Analizę jakości odczytów można przeprowadzić przy pomocy narzędzia FastQC.
Najpierw poleceniem mkdir utworzymy katalog fastqc, w którym znajdą się wyniki analizy.
``` sh
mkdir fastqc
```
Następnie uruchamiamy narzędzie FastQC na wybranej próbce i zapisujemy wyniki w katalogu fastqc.
``` sh
fastqc fastq/P1_N_1.fq -o fastqc
```
Gdzie: 
* -o - określa folder, w którym zostaną zapisane wyniki

Powyższą analizę powtarzamy dla każdej próbki.
Aby usprawnić pracę, można użyć pętli for, która dla każdego pliku z katalogu fastq uruchomi analizę jakości odczytów i zapisze jej wyniki do katalogu fastqc.
``` sh
for sample in fastq/*.fq.gz
    do
        fastqc $sample -o fastqc
    done
```
# Składanie odczytów w transkryptom referencyjny
Narzędzie Trinity umożliwia sprawne złożenie odczytów w sekwencje referencyjne.
Tworzymy katalog, w którym znajdą się wyniki analizy.
``` sh 
mkdir trinity
```
Uruchamiamy program Trinity.
``` sh
Trinity --seqType fq --samples_file fastq/sample-info.txt --SS_lib_type FR --output trinity --max_memory 10G
```
Gdzie:
* --seqType - oznacza format pliku, w którym przechowywane są odczyty (fa - fasta lub fq - fastq)
* --samples_file - plik zawierający spis wszyskich plików fastq
* --ss_lib_type - rodzaj biblioteki (sparowana, niesparowana)
* --output - folder, w którym znajdą się wyniki analizy
* --max_memory - maksymalna ilość RAMu przeznaczona dla tego uruchomienia programu

Plik sample-info.txt znajdujący się w folderze fastq został wcześniej przygotowany aby ułatwić analizę. Zawiera on 4 kolumny i taką ilość wierszy ile jest próbek (w tym przypadku 6). Wartości w pierwszej kolumnie informują o przynależności do grupy eksperymentalnej, w drugiej znajduje się nazwa próbki (unikatowa) a w trzeciej i czwartej ścieżka do plików fastq dla danej próbki. 

Wyniki analizy czyli plik fasta ze złożonymi sekwencjami widnieje pod nazwą Trinity.fasta.

# Zannotowanie utworzonych sekwencji 
Utworzone sekwencje można zannotować znanymi białkami i transkryptami. W tym celu użyjemy narzędzia Blast i sekwencji białek z bazy UniPort oraz sekwencji transkryptów z bazy Blast.

#### Przygotowanie plików fasta z sekwencjami białek i transkryptów
Aby przygotować obie bazy do analizy, należy pobrać pliki fasta, a następnie zaindeksować je narzędziem makeblastdb. Ze względu na dużą liczbę sekwencji w bazach oraz długi proces annotacji, pliki fasta, na których przeprowadzimy analizę zostały wcześniej zawężone do wybranych sekwencji i zaindeksowane. 
Znajdują się one w katalogach:
* annotation/nucleotide-collection-nt-data/nt.fasta - sekwencje transkrypów
* annotation/uniprot-data/uniprot_sprot.fasta - sekwencje białek

Poniżej podajemy instrukcje, jak samemu przygotować bazy sekwencji do analizy:
Plik fasta z sekwencjami białek z bazy UniProt:
```sh
wget -c ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nt.gz
gunzip nt.gz
makeblastdb -in nt -dbtype nucl
```
Plik fasta z sekwencjami transkryptów z bazy Blast:
```sh
wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gunzip uniprot_sprot.fasta.gz
makeblastdb -in uniprot_sprot.fasta -dbtype prot
```

#### Zannotowanie sekwencji
Przejdźmy to katalogu annotation, w którym będą przechowywane wyniki analizy.
```
cd annotation/
```
Następnie uruchamiamy programy blastx oraz blastn. Wcześniej jednak poleceniem echo tworzymy plik, w którym będą znajdowały się nazwy kolumn annotacji.
```
echo -e 'qseqid\tsseqid\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tscore\tlength\tpident\tnident\tmismatch\tgapopen\tgaps\tstitle' > transcript-annotation.txt

blastn -query ../trinity/Trinity.fasta \
    -db nucleotide-collection-nt-data/nt.fasta \
    -out blastn.outfmt6 \
    -max_target_seqs 4 \
    -outfmt '6 qseqid sseqid qstart qend sstart send evalue bitscore score length pident nident mismatch gapopen gaps stitle'
    
cat blastn.outfmt6 >> transcript-annotation.txt
rm blastn.outfmt6
```
```
echo -e 'qseqid\tsseqid\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tscore\tlength\tpident\tnident\tmismatch\tgapopen\tgaps\tstitle' > protein-annotation.txt

blastx -query ../trinity/Trinity.fasta \
    -db uniprot-data/uniprot_sprot.fasta \
    -out blastx.outfmt6 \
    -max_target_seqs 4 \
    -outfmt '6 qseqid sseqid qstart qend sstart send evalue bitscore score length pident nident mismatch gapopen gaps stitle'
    
cat blastx.outfmt6 >> protein-annotation.txt
rm blastx.outfmt6
```
Gdzie:
* -query - nazwa pliku fasta zawierającego sekwencje, które mają zostać zannotowane
* -db - baza danych, na podstawie której sekwencje zostaną zannotowane
* -out - nazwa pliku wynikowego
* -max_target_seqs - określa maksymalną liczbę dopasowanych sekwencji jakie będą raportowane
* -outfmt '6 qseqid sseqid qstart qend sstart send evalue bitscore score length pident nident mismatch gapopen gaps stitle' - definiuje format pliku wynikowego - 6 oznacza, że wynikiem ma być tabela, pozostałe parametry określają jakie kolumny mają się w niej znaleźć. Więcej informacji można uzyskać w opisie programu wpisując w konsoli:
```sh 
blastx -help
```
lub 
```sh
blastn -help
```

# Uliniowienie odczytów do utworzonego transkryptomu
Tą część analizy przeprowadzimy przy użyciu narzędzia bowtie2.
W pierwszym kroku należy zaindeksować utworzone sekwencje przy pomocy poniższego polecenia:
``` sh
cd trinity/
bowtie2-build Trinity.fasta Trinity
```
Przejdźmy do głównego katalogu, w którym znajdują się wyniki analiz i utwórzmy folder, w którym umieścimy uliniowione pliki.
``` sh
cd ../trinity/
mkdir bowtie2
```
Polecenie do mapowania odczytów wygląda następująco:
``` sh
bowtie2 -x trinity/Trinity -1 fastq/P1_N_1.fq.gz -2 fastq/P1_N_2.fq.gz -S bowtie2/P1_N.sam
```
Gdzie: 
* -x - ścieżka do genomu referencyjnego (bez podawania rozszerzenia fasta)
* -1 oraz -2 - pliki fastq
* -S - nazwa wynikowego pliku sam

Oczywiście proces ten należy powtórzyć dla każdej próbki. W celu usprawnienia pracy można to zrobić przy pomocy pętli for:

``` sh
for sample in P1_N P2_N P3_N P4_N P5_N P7_N
    do
        bowtie2 -x trinity/Trinity -1 fastq/$sample"_1.fq.gz" -2 fastq/$sample"_2.fq.gz" -S bowtie2/$sample.sam
    done
```
Pliki z uliniowionymi odczytami przesortujemy według pozycji oraz przekonwertujemy na format bam. W tym celu posłużymy się narzędziem samtools sort.
```
samtools sort -O BAM -o bowtie2/P1_N.bam bowtie2/P1_N.sam
```
A ponieważ operację tę należy powróżyć tyle razy ile jest próbek, możemy znów zastosować pętlę.

``` sh
for sample in P1_N P2_N P3_N P4_N P5_N P7_N
    do
        samtools sort -O BAM -o bowtie2/$sample.bam bowtie2/$sample.sam 
    done
```

# Obliczenie poziomu ekspresji 
Do obliczenia poziomu ekspresji transkryptów użyjemy narzędzia samtools idxstats.
W pierwszej kolejności konieczne jest utworzenie indeksów plików bam.
``` sh
for sample in P1_N P2_N P3_N P4_N P5_N P7_N
    do
        samtools index bowtie2/$sample.bam 
    done
```
Tworzymy folder, w którym znajdą się wyniki analizy.
```
mkdir idxstats
```
A następnie uruchamiamy narzędzie samtools idxstats.
``` sh
for sample in P1_N P2_N P3_N P4_N P5_N P7_N
    do
        samtools idxstats bowtie2/$sample.bam > idxstats/$sample.txt
    done
```






