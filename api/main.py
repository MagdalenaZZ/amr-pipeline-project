from fastapi import FastAPI
from pydantic import BaseModel
from typing import List

app = FastAPI()

class AMRRecord(BaseModel):
    sample_id: str
    organism: str
    resistance_gene: str
    platform: str
    identity: float

# Mock data
fake_results = [
    {"sample_id": "S1", "organism": "E. coli", "resistance_gene": "blaCTX-M", "platform": "Illumina", "identity": 99.1},
    {"sample_id": "S2", "organism": "E. coli", "resistance_gene": "aac(6')-Ib", "platform": "Nanopore", "identity": 95.3},
]

@app.get("/api/amr-summary", response_model=List[AMRRecord])
def get_amr_summary():
    return fake_results


