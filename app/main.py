import json
import torch
from torch import nn
from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse
from transformers import ElectraForSequenceClassification, AutoTokenizer

app = FastAPI()

# 설정
max_seq_length = 128
classes = ['Neg', 'Pos']
device = torch.device("cpu")

# 모델 및 토크나이저 로드
tokenizer = AutoTokenizer.from_pretrained("daekeun-ml/koelectra-small-v3-nsmc")
model = ElectraForSequenceClassification.from_pretrained("daekeun-ml/koelectra-small-v3-nsmc")
model.to(device)
model.eval()

# HTML UI
html_template = """
<!DOCTYPE html>
<html>
    <head>
        <title>KoELECTRA 감성분류</title>
    </head>
    <body>
        <h2>한국어 감성분류 데모</h2>
        <form method="post">
            <input type="text" name="text" placeholder="문장을 입력하세요" style="width:300px"/>
            <button type="submit">분류하기</button>
        </form>
        <div>
            <h3>결과:</h3>
            <p>{}</p>
        </div>
    </body>
</html>
"""

# 루트 페이지 - 입력창 보여줌
@app.get("/", response_class=HTMLResponse)
async def form_get():
    return html_template.format("")

# POST 요청 - 결과 출력
@app.post("/", response_class=HTMLResponse)
async def form_post(text: str = Form(...)):
    encoded = tokenizer.encode_plus(
        text,
        max_length=max_seq_length,
        add_special_tokens=True,
        return_token_type_ids=False,
        padding="max_length",
        return_attention_mask=True,
        return_tensors="pt",
        truncation=True,
    ).to(device)

    with torch.no_grad():
        output = model(**encoded)
        softmax_fn = nn.Softmax(dim=1)
        softmax_output = softmax_fn(output.logits)
        _, prediction = torch.max(softmax_output, dim=1)

        predicted_class_idx = prediction.item()
        predicted_class = classes[predicted_class_idx]
        score = softmax_output[0][predicted_class_idx].item()

    result = f"예측 라벨: <b>{predicted_class}</b> (score: {score:.4f})"
    return html_template.format(result)