from fastapi import FastAPI

app = FastAPI()


@app.get("/health")
def get_health():
    return "OK"
