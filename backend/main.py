from fastapi import FastAPI
from database import db

app = FastAPI()

@app.get("/")
def home():
    return {"message": "GeoGuide backend is running!"}


@app.get("/places")
def get_places(category: str = None):
    if category:
        places = db["Places"].find({"category": category})
    else:
        places = db["Places"].find()

    result = []

    for place in places:
        place["_id"] = str(place["_id"])
        result.append(place)

    return result


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)