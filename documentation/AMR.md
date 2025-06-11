i# AMR.md – Antibiotikaresistensanalys

## Bakgrund

Antibiotikaresistens är en av vår tids största globala hälsoutmaningar. Enligt WHO är resistens mot antibiotika ett av de tio största hoten mot global folkhälsa. För infektioner med exempelvis *Klebsiella pneumoniae* kan patienten avlida inom 12 dagar efter inläggning – vilket gör tidig, korrekt diagnostik livsavgörande [EClinicalMedicine, 2021].

Traditionella metoder som VITEK2 eller MALDI-TOF MS används idag i klinik, men dessa är kostsamma och kan ta upp till flera dygn att ge resistensprofiler. Genombaserad AMR-diagnostik (med t.ex. Illumina eller Oxford Nanopore) erbjuder ett snabbare och bredare alternativ, och möjliggör dessutom identifiering av plasmidburna resistensgener som ofta förblir oupptäckta med konventionella metoder [Nature Communications, 2024].

## Bakterie-kulturen vi sekvenserat

SAMEA3357140 (INF201) är en klinisk Klebsiella pneumoniae-isolat från urin hos en sjukhuspatient i Melbourne, oktober 2013, och ingår i BioProject PRJNA646837. Isolatet har använts i flera publikationer inom genomisk övervakning och antibiotikaresistens, där både Illumina- och Oxford Nanopore-sekvenser använts.

Klebsiella pneumoniae är en opportunistisk patogen som kan orsaka vårdrelaterade infektioner såsom urinvägsinfektion, lunginflammation, sepsis och sårinfektioner, särskilt hos immunsvaga patienter eller personer med katetrar. Bakterien är en av de mest framträdande inom gruppen ESBL-producerande gramnegativa bakterier, och det är vanligt att hitta resistens mot flera antibiotikaklasser, inklusive:

* β-laktamer (särskilt via ESBL-gener som bla_CTX-M, bla_SHV)
* Aminoglykosider
* Fluorokinoloner
* Trimetoprim-sulfa
* I vissa fall även karbapenemer, genom förvärv av karbapenemaser som bla_KPC, bla_NDM eller bla_OXA-48.

Flera studier som använt SAMEA3357140 har fokuserat på sjukhusförvärvade infektioner och den genomiska mångfalden hos K. pneumoniae. I Gorrie et al. (2022, Nat Commun) visades att ESBL-positiva stammar, som INF201, har en högre tendens till sjukhusspridning jämfört med ESBL-negativa. Foster-Nyarko et al. (2023, Microb Genom) använde provet som en del av en utvärdering av Nanopore-sekvensering för resistensövervakning, och kunde visa att även utan Illumina-data gick det att identifiera resistensgener och typer med hög noggrannhet. Andra arbeten, såsom Hawkey et al. (2022, Genome Med), har använt stammen för att kartlägga plasmidburna ESBL-gener och deras roll i att driva infektioner inom vårdmiljöer.


## Analys i detta projekt

En pipeline har byggts i Nextflow med stöd för analys av både Illumina- och Nanopore-data. 

Illumina assembly med unicycler blev 170 delar, langsta 1,237,597 bp, och N50 pa 436,601
Nanopore assemly blev 2 delar, genomet (5,282,715 bp) och en plasmid (169,696 bp)



Resistensgener identifierades med AMRFinderPlus och CARD-databasen. Bland annat:

| Gen       | Antibiotikaklass     | Tolkning |
|-----------|----------------------|----------|
| blaTEM    | Betalaktamer         | Vanlig hos E. coli – resistens mot penicilliner |
| sul1      | Sulfonamider         | Associerad med mobila genetiska element |
| tet(A)    | Tetracykliner         | Effluxpump – plasmidburen |

## Illumina vs Nanopore – en jämförelse

| Plattform  | Fördelar                                                                 | Begränsningar                                  |
|------------|--------------------------------------------------------------------------|------------------------------------------------|
| Illumina   | Hög noggrannhet, standardiserat, bra för AMR-genidentifiering           | Kort läslängd → sämre sammanhang (t.ex. plasmider) |
| Nanopore   | Snabb analys (<5h), realtidsdata, bra för struktur och plasmidkarta     | Högre felprocent, kräver avancerad QC         |

> En studie av 69 *Salmonella* serotyper visade att korrekt serotypning och AMR-prediktion kunde uppnås inom ~5 timmar med Nanopore vid 30× täckning [Frontiers in Microbiology, 2022].

## Framtid och utveckling

Genombaserade metoder möjliggör mer högupplösta och snabba AMR-analyser än tidigare. Exempelvis har kombinationen av Illumina och Nanopore använts för att analysera *C. difficile*-isolat med goda resultat [BMC Genomics, 2025].

Samtidigt sker en snabb teknikutveckling:
- **Bättre mjukvara**: Verktyg som Abricate, AMRFinder och RGI förbättras kontinuerligt
- **AI/ML-algoritmer**: Nya verktyg kan ersätta BLAST-liknande sökningar med strukturell, funktionell klassificering
  - Ex: En mutation i en resistensgen påverkar inte alltid funktionen – AI kan ta hänsyn till position, proteinstruktur, och kontext
- **Realtidsanalys**: MinION möjliggör flera patientprover per dygn, vilket öppnar för dynamisk antibiotikabehandling

## Kritisk reflektion

AMR-diagnostik kräver mer än att bara hitta "rätt gener". För att verkligen bedöma resistens behövs:
- Kontexter: Är genen plasmidburen? Associerad med mobilitet?
- Varianter: Är det en funktionell mutation, eller en neutral variant?
- Samspel: Kombinationer av resistensmekanismer måste analyseras integrerat

ML-baserade metoder visar stor potential att lösa dessa frågor mer träffsäkert än tidigare cutoffs eller percent identity-sökningar. I takt med att datakvalitet och referensdatabaser förbättras, kommer detta område snabbt utvecklas till kliniskt beslutsstöd.

## Källor




- Frontiers in Microbiology, 2022 – https://www.frontiersin.org/articles/10.3389/fmicb.2022.1073057/full  
- Nature Communications, 2024 – https://www.nature.com/articles/s41467-024-49851-4  
- BMC Genomics, 2025 – https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-025-11267-9  
- WHO / EClinicalMedicine – https://doi.org/10.1016/j.eclinm.2021.101221
- Nature Communications, 2022 – https://www.nature.com/articles/s41467-022-30703-1
- Microbial Genomics, 2023 – https://www.microbiologyresearch.org/content/journal/mgen/10.1099/mgen.0.000871
- Genome Medicine, 2022 – https://genomemedicine.biomedcentral.com/articles/10.1186/s13073-022-01064-7
- Clinical Infectious Diseases, 2018 – https://doi.org/10.1093/cid/ciy034



 
