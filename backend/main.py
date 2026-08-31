from fastapi import FastAPI
from database import db
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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

@app.get("/places/nearby")
def get_nearby_places(
    lat: float, 
    lng: float, 
    maxDistance: int = 20000, 
    limit: int = 5, 
    category: str = None
):
    print(f"--> RECEIVED FROM FLUTTER: lat={lat}, lng={lng}, maxDistance={maxDistance}")
    pipeline = [
        {
            "$geoNear": {
                "near": {
                    "type": "Point",
                    "coordinates": [lng, lat]
                },
                "distanceField": "distance_km",
                "distanceMultiplier": 0.001,
                "maxDistance": maxDistance,
                "spherical": True
            }
        },
        {
            "$sort": {"distance_km": 1}
        }
    ]

    # Only filter if a valid category is provided and isn't "all"
    if category and category.lower() not in ["all", "null", ""]:
        pipeline.append({"$match": {"category": category}})
        
    pipeline.append({"$limit": limit})

    results = list(db.Places.aggregate(pipeline))
    
    # Safely convert ObjectIds to strings so FastAPI serializes them without crashing
    for doc in results:
        if "_id" in doc:
            doc["_id"] = str(doc["_id"])
            
    return results
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)