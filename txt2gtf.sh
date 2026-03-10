gunzip -c refGene.txt.gz | awk 'BEGIN{OFS="\t"; print "##gtf-version 2.2"} 
{
  # Saltar la línea de cabecera si existe (depende del archivo)
  if (NR==1 && $0~/^#/ || NR==1 && $1=="bin") next;
  
  # Asignar columnas (basado en la estructura de refGene.txt)
  chrom = $3;
  source = "UCSC_RefSeq";
  strand = $4;
  txStart = $5;
  txEnd = $6;
  cdsStart = $7;
  cdsEnd = $8;
  exonCount = $9;
  exonStarts = $10;
  exonEnds = $11;
  geneName = $13;  # nombre del gen
  transcriptId = $2;  # nombre del transcripto (ej. NM_...)
  
  # Eliminar caracteres problemáticos (como comas en exonStarts/exonEnds)
  gsub(/,/, " ", exonStarts);
  gsub(/,/, " ", exonEnds);
  split(exonStarts, startsArray);
  split(exonEnds, endsArray);
  
  # Atributos comunes para todas las features de este transcripto
  attributes = "gene_id \"" geneName "\"; transcript_id \"" transcriptId "\";";
  
  # 1. Feature "transcript" (opcional, pero útil)
  print chrom, source, "transcript", txStart+1, txEnd, ".", strand, ".", attributes;
  
  # 2. Feature "exon" para cada exón
  for (i = 1; i <= exonCount; i++) {
    exonStart = startsArray[i] + 1;  # UCSC usa 0-based, GTF usa 1-based
    exonEnd = endsArray[i];
    exonAttributes = attributes " exon_number \"" i "\";";
    print chrom, source, "exon", exonStart, exonEnd, ".", strand, ".", exonAttributes;
  }
  
  # 3. Feature "CDS" si existe (región codificante)
  if (cdsStart < cdsEnd) {
    # CDS puede abarcar varios exones, pero simplificamos como una sola región
    # Para una representación exacta, habría que intersectar con exones
    print chrom, source, "CDS", cdsStart+1, cdsEnd, ".", strand, ".", attributes;
  }
}' > hg38_refseq.gtf