# AMR.md – Antibiotikaresistensanalys

## Bakgrund

Antibiotikaresistens är en av vår tids största globala hälsoutmaningar. Enligt WHO är resistens mot antibiotika ett av de tio största hoten mot global folkhälsa. För infektioner med exempelvis *Klebsiella pneumoniae* kan patienten avlida inom 12 dagar efter inläggning – vilket gör tidig, korrekt diagnostik livsavgörande \[Editorial EClinicalMedicine, 2021].

Traditionella metoder som VITEK2 eller MALDI-TOF MS används idag i klinik, men dessa är kostsamma och kan ta upp till flera dygn att ge resistensprofiler. Genombaserad AMR-diagnostik (med t.ex. Illumina eller Oxford Nanopore) erbjuder ett snabbare och kanske mer kostnadseffektivt alternativ, och möjliggör dessutom identifiering av plasmidburna resistensgener som ofta förblir oupptäckta med konventionella metoder, samt realtidsmonitorering av antibiotikaresistens \[Sauerborn 2024].

## Bakteriekulturen vi sekvenserat

SAMEA3357140 (INF201) är ett kliniskt *Klebsiella pneumoniae*-isolat från urin hos en avliden sjukhuspatient i Melbourne, oktober 2013, och ingår i BioProject PRJNA646837. Isolatet har använts i flera publikationer inom genomisk övervakning och antibiotikaresistens, där både Illumina- och Oxford Nanopore-sekvenser använts.

*Klebsiella pneumoniae* är en opportunistisk patogen som kan orsaka vårdrelaterade infektioner såsom urinvägsinfektion, lunginflammation, sepsis och sårinfektioner, särskilt hos immunsvaga patienter eller personer med katetrar. Bakterien är en av de mest framträdande inom gruppen ESBL-producerande gramnegativa bakterier, och det är vanligt att hitta resistens mot flera antibiotikaklasser, inklusive:

* β-laktamer (särskilt via ESBL-gener som *bla\_CTX-M*, *bla\_SHV*)
* Aminoglykosider
* Fluorokinoloner
* Trimetoprim-sulfa
* I vissa fall även karbapenemer, genom förvärv av karbapenemaser som *bla\_KPC*, *bla\_NDM* eller *bla\_OXA-48*

Flera studier som använt SAMEA3357140 har fokuserat på sjukhusförvärvade infektioner och den genomiska mångfalden hos *K. pneumoniae*. I Gorrie et al. (2022, *Nature Communications*) visades att ESBL-positiva stammar, som INF201, har en högre tendens till sjukhusspridning jämfört med ESBL-negativa. Foster-Nyarko et al. (2023, *Microbial Genomics*) använde provet som en del av en utvärdering av Nanopore-sekvensering för resistensövervakning, och kunde visa att även utan Illumina-data gick det att identifiera resistensgener och typer med hög noggrannhet. Andra arbeten, såsom Hawkey et al. (2022, *Genome Medicine*), har använt stammen för att kartlägga plasmidburna ESBL-gener och deras roll i att driva infektioner inom vårdmiljöer.

## Analys i detta projekt

En pipeline har byggts i Nextflow med stöd för analys av både Illumina- och Nanopore-data.

* Illumina assembly med Unicycler: 170 kontigs, längsta 1,237,597 bp, N50 = 436,601
* Nanopore assembly: 2 kontigs – kromosom (5,282,715 bp) och plasmid (169,696 bp)

Resistensgener identifierades med AMRFinderPlus.

### 🧬 Vad har vi hittat?

Både Illumina- och Nanopore-data visar exakt samma fyra resistensgener med 100 % täckning och identitet mot referenssekvenserna, vilket tyder på hög kvalitet i båda dataset:

| Gen      | Funktion                                        | Resistens mot                 |
| -------- | ----------------------------------------------- | ----------------------------- |
| blaSHV-1 | Klass A β-laktamas (bredspektrum)               | β-laktamantibiotika (ej ESBL) |
| oqxA11   | OqxAB-effluxpump, periplasmisk komponent        | Fluorokinoloner & fenikoler   |
| oqxB19   | OqxAB-effluxpump, membranbunden permease        | Fluorokinoloner & fenikoler   |
| fosA     | Glutation-transferas som inaktiverar fosfomycin | Fosfomycin                    |

💡 **Noterbart:**

* *blaSHV-1* är inte i sig en ESBL-gen, men nära besläktade varianter (*blaSHV-2/12/28*) kan vara det.
* *oqxAB*-effluxpumpen är ofta kromosomalt kodad och ger låggradig resistens.
* *fosA* är vanlig i *K. pneumoniae* och ger fosfomycinresistens.

### 🔍 Skillnader mellan Illumina och Nanopore-resultaten

| Aspekt                | Illumina-data       | Nanopore-data       |
| --------------------- | ------------------- | ------------------- |
| Antal gener hittade   | 4                   | 4                   |
| Samma gener?          | Ja                  | Ja                  |
| Identitet & täckning  | 100 % på alla gener | 100 % på alla gener |
| Eventuella avvikelser | Ingen               | Ingen               |

🟢 Detta visar att båda teknologierna ger konsekvent resistensprediktion i detta fall.

## Skillnader mellan Illumina och Nanopore-sekvensering

| Plattform | Fördelar                                                            | Begränsningar                                      |
| --------- | ------------------------------------------------------------------- | -------------------------------------------------- |
| Illumina  | Hög noggrannhet, standardiserat, bra för AMR-genidentifiering       | Kort läslängd → sämre sammanhang (t.ex. plasmider) |
| Nanopore  | Snabb analys (<5h), realtidsdata, bra för struktur och plasmidkarta | Högre felprocent, kräver avancerad QC              |

> En studie av 69 *Salmonella*-serotyper visade att korrekt serotypning och AMR-prediktion kunde uppnås inom \~5 timmar med Nanopore vid 30× täckning \[Wu 2022].

## Framtid och utveckling

Genombaserade metoder möjliggör mer högupplösta och snabba AMR-analyser än tidigare. Exempelvis har kombinationen av Illumina och Nanopore använts för att analysera *C. difficile*-isolat med goda resultat \[BMC Genomics, 2025].

Samtidigt sker en snabb teknikutveckling:

* **Bättre mjukvara**: Verktyg som Abricate, AMRFinder och RGI förbättras kontinuerligt
* **AI/ML-algoritmer**: Kan ersätta BLAST-liknande sökningar med strukturell, funktionell klassificering
* **Realtidsanalys**: MinION möjliggör flera patientprover per dygn

## Kritisk reflektion

AMR-diagnostik kräver mer än att bara hitta "rätt gener". För att verkligen bedöma resistens behövs:

* Kontexter: Är genen plasmidburen? Associerad med mobilitet?
* Varianter: Är det en funktionell mutation, eller en neutral variant?
* Samspel: Kombinationer av resistensmekanismer måste analyseras integrerat

ML-baserade metoder visar stor potential att lösa dessa frågor mer träffsäkert än tidigare cutoffs eller percent identity-sökningar. I takt med att datakvalitet och referensdatabaser förbättras, kommer detta område snabbt utvecklas till snabbare kliniskt beslutsstöd i realtid – och förhoppningsvis till fler patienter som överlever.

## Källor

* Wu X et al. *Evaluation of multiplex nanopore sequencing for Salmonella serotype prediction and antimicrobial resistance gene and virulence gene detection*. Frontiers in Microbiology (2022). DOI: [https://doi.org/10.3389/fmicb.2022.1073057](https://doi.org/10.3389/fmicb.2022.1073057)
* Sauerborn E et al. *Detection of hidden antibiotic resistance through real-time genomics*. Nature Communications (2024). DOI: [https://doi.org/10.1038/s41467-024-49851-4](https://doi.org/10.1038/s41467-024-49851-4)
* Bejaoui S et al. *Comparison of Illumina and Oxford Nanopore sequencing data quality for Clostridioides difficile genome analysis and their application for epidemiological surveillance*. BMC Genomics (2025). DOI: [https://doi.org/10.1186/s12864-025-11267-9](https://doi.org/10.1186/s12864-025-11267-9)
* Editorial. *Antimicrobial resistance: a top ten global public health threat*. EClinicalMedicine (2021). DOI: [https://doi.org/10.1016/j.eclinm.2021.101221](https://doi.org/10.1016/j.eclinm.2021.101221)
* Wu X et al. *Evaluation of multiplex nanopore sequencing for Salmonella serotype prediction and antimicrobial resistance gene and virulence gene detection*. Microbial Genomics (2023). DOI: [https://doi.org/10.1099/mgen.0.000871](https://doi.org/10.1099/mgen.0.000871)
* Waddington C et al. *Exploiting genomics to mitigate the public health impact of antimicrobial resistance*. Genome Medicine (2022). DOI: [https://doi.org/10.1186/s13073-022-01064-7](https://doi.org/10.1186/s13073-022-01064-7)
* Pletz MW et al. *A nosocomial foodborne outbreak of a VIM carbapenemase-expressing Citrobacter freundii*. Clinical Infectious Diseases (2018). DOI: [https://doi.org/10.1093/cid/ciy034](https://doi.org/10.1093/cid/ciy034)


