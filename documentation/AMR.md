i# AMR.md – Antibiotikaresistensanalys

## Bakgrund

Antibiotikaresistens är en av vår tids största globala hälsoutmaningar. Enligt WHO är resistens mot antibiotika ett av de tio största hoten mot global folkhälsa. För infektioner med exempelvis *Klebsiella pneumoniae* kan patienten avlida inom 12 dagar efter inläggning – vilket gör tidig, korrekt diagnostik livsavgörande [EClinicalMedicine, 2021].

Traditionella metoder som VITEK2 eller MALDI-TOF MS används idag i klinik, men dessa är kostsamma och kan ta upp till flera dygn att ge resistensprofiler. Genombaserad AMR-diagnostik (med t.ex. Illumina eller Oxford Nanopore) erbjuder ett snabbare och bredare alternativ, och möjliggör dessutom identifiering av plasmidburna resistensgener som ofta förblir oupptäckta med konventionella metoder [Nature Communications, 2024].

## Analys i detta projekt

En pipeline har byggts i Nextflow med stöd för analys av både Illumina- och Nanopore-data. På grund av begränsade resurser har enbart Nanopore-datan analyserats hittills.



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




 
