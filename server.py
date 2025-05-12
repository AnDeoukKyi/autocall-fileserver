from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
APP_DIR = os.path.join(BASE_DIR, "app")
FILE_DIR = os.path.join(BASE_DIR, "file")
SCRIPT_DIR = os.path.join(BASE_DIR, "script")
UPLOAD_DIR = os.path.join(BASE_DIR, "upload")

os.makedirs(UPLOAD_DIR, exist_ok=True)

app = FastAPI()

# 업로드
@app.post("/upload")
async def upload(file: UploadFile = File(...)):
    dest = os.path.join(UPLOAD_DIR, file.filename)
    with open(dest, "wb") as f:
        f.write(await file.read())
    return {"filename": file.filename, "message": "업로드 완료!"}

# 정적 파일 다운로드
app.mount("/files/app", StaticFiles(directory=APP_DIR), name="app")
app.mount("/files/script", StaticFiles(directory=SCRIPT_DIR), name="script")
app.mount("/files/file", StaticFiles(directory=FILE_DIR), name="file")
app.mount("/files/upload", StaticFiles(directory=UPLOAD_DIR), name="upload")


#uvicorn server:app --host 0.0.0.0 --port 7211
#14.36.12.133:7211