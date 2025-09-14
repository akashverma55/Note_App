from fastapi import FastAPI, HTTPException          #For creating API endpoints and handling exceptions.
from pydantic import BaseModel                      #For defining data models using Pydantic.
from typing import List                             #For creating the list of notes given by API
from bson import ObjectId                           #To work with BSON objects (used to change the string into object ID).
from pymongo import MongoClient                     #For connecting to a MongoDB database.

Client = MongoClient("mongodb://localhost:27017/")
db = Client["notes_db"]
collection = db["notes"]

app = FastAPI()

class Note(BaseModel):
    title:str
    description:str

class NoteResponse(Note):
    id:str

def serialize_note(note):
    return{
        "id":str(note["_id"]),
        "title":note["title"],
        "description":note["description"]
    }

@app.get("/notes",response_model = List[NoteResponse])
def get_notes():
    notes = collection.find()
    return [serialize_note(note) for note in notes]

@app.post("/notes",response_model = NoteResponse)
def add_notes(note: Note):
    result = collection.insert_one(note.dict())
    saved_note = collection.find_one({"_id":result.inserted_id})
    return serialize_note(saved_note)

@app.put("/notes/{notes_id}",response_model = NoteResponse)
def update_notes(notes_id: str,note: Note):
    result = collection.update_one({"_id":ObjectId(notes_id)},{"$set":note.dict()})
    if result.matched_count==0:
        raise HTTPException(status_code=404,detail="Notes Not Found")
    updated_note = collection.find_one({"_id":ObjectId(notes_id)})
    return serialize_note(updated_note)

@app.delete("/notes/{notes_id}")
def delete_notes(notes_id :str):
    result = collection.delete_one({"_id":ObjectId(notes_id)})
    if result.deleted_count==0:
        raise HTTPException(status_code=404,detail="Notes Not Found")
    return{"Message":"Notes Deleted"}