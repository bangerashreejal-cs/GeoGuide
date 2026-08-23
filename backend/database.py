import os
from dotenv import load_dotenv, find_dotenv
from pymongo import MongoClient

# Force python to search for the .env file explicitly
dotenv_path = find_dotenv()
print("FOUND .ENV PATH:", dotenv_path)

load_dotenv(dotenv_path)
MONGODB_URI = os.getenv("MONGODB_URI")

print("LOADED URI:", MONGODB_URI[:20] if MONGODB_URI else "None!")

client = MongoClient(MONGODB_URI)
print("DEBUG HOST:", client.address)

db = client["GeoGuide"]
print("CONNECTED TO DATABASE:", db.name)
print("COLLECTIONS:", db.list_collection_names())