#!/bin/bash

# Gabriela Martínez Andrade, mayo 2020


# Script para obtener el archivo .biom de muestras de suelo rizosférico recolectados en sitios de bosque nativo (N) y mixto (M) de Quercus (Q) y de Juniperus. Cada muestra tenemos un archivo fastq con las secuencias forward (R1) y otro con las secuencias reverse (R2). Los datos son de ITS2 (hongos) generados por Illumina MiSeq


# Pre-procesamiento de archivos FASTQ. En este primer paso se ensamblan los reads forward (R1) y reverse (R2), se eliminan los primers y secuencias cortas.
amptk illumina -i ../metagenomica/fastq -o amptk/ -f GTGARTCATCRARTYTTTG -r CCTSCSCTTANTDATATGC -l 200 --min_len 200 --full_length --cleanup

# Clustering del 97% de similitud con UPARSE. En este segundo paso, se realiza un filtro de calidad (incluso las quimeras) y se agrupan las secuencias en OTUs.
amptk cluster -i amptk.demux.fq.gz -o cluster -m 2 --uchime_ref ITS

# Filtrado de la tabla de OTUS´s (index bleed). El tercer paso, consiste en los Index bleed. Se tratan de reads asignados a la muestra incorrecta durante el proceso de secuenciación de Illumina. Esto es frecuente y además con un grado variable entre varios runs. También es en este paso , que se puede usar un control positivo (mock) artificial, para medir el grado de index bleed dentro de un run. Si el run no incluyó un mock artificial, este umbral se puede definir manualmente (en general se usa 0,005%).
amptk filter -i cluster.otu_table.txt -o filter -f cluster.cluster.otus.fa -p 0.005 --min_reads_otu 2

# Asignación de la taxonomía a cada OTU. AMPtk utiliza la base de datos UNITE, ésto para asignar la taxonomía de los OTUs. Usamos UNITE porque es una base de datos curada.
amptk taxonomy -i filter.final.txt -o taxonomy -f filter.filtered.otus.fa -m ../metagenomica/amptk.mapping_file.txt -d ITS2 --tax_filter Fungi

# Bajar el archivo taxonomy200.biom del cluster de CONABIO, en la computadora local.
scp -P 45789 cirio@200.12.166.164:/persistence/cirio/metagenomica/taxonomy200.biom .

# El archivo lo guardé en mi computatora local en la ruta: /Users/gaby/Desktop/BioinfinvRepro/Unidad8/metagenomica/data
