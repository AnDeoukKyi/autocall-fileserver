
import os
import json
import torch
from fastapi import FastAPI
from transformers import ElectraForSequenceClassification, AutoTokenizer
import torch.nn.functional as F
import time

from pydantic import BaseModel

app = FastAPI()

# 설정
max_seq_length = 128
DEVICE = torch.device("cpu")

with open("config.json", "r", encoding='utf-8') as f:
	config = json.load(f)

model_name = config['model_name']
model_version = config['model_version']

model_full_name = f"model/{config['model_name']}_v{config['model_version']}"
# 모델 및 토크나이저 로드
tokenizer = AutoTokenizer.from_pretrained(model_full_name)
model = ElectraForSequenceClassification.from_pretrained(model_full_name)
model.to(DEVICE)
model.eval()

with open(f"{model_full_name}/dataset_config.json", "r", encoding='utf-8') as f:
	dataset_config = json.load(f)

CLASSES = dataset_config['classes']

def predict(text: str) -> dict:
	try:
		encoding = tokenizer(
			text,
			truncation=True,
			padding="max_length",
			max_length=128,
			return_tensors="pt"
		).to(DEVICE)

		with torch.no_grad():
			output = model(**encoding)
			probs = F.softmax(output.logits, dim=1)
			pred = torch.argmax(probs, dim=1).item()
			score = probs[0][pred].item()
			return {
				"text": text,
				"label": CLASSES[pred],
				"score": round(score, 4)
			}

	except Exception as e:
		return {
			"text": text,
			"label": "에러",
			"score": 0.0,
			"probs": [0.0] * len(CLASSES),
			"error": str(e)
		}

# 요청 body를 위한 Pydantic 모델 정의
class PredictRequest(BaseModel):
	text: str

@app.post("/predict")
async def predict_api(data: PredictRequest):
	start_time = time.time()
	result = predict(data.text)
	end_time = time.time()
	result["elapsed"] = round(end_time - start_time, 3)
	return result
