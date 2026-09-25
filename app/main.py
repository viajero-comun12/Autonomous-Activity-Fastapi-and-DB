from contextlib import asynccontextmanager
from fastapi import FastAPI
from sqlmodel import SQLModel
from app.database import engine
from app.routers import users, books
from app import models 

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_and_tables()
    yield

app = FastAPI(
    title="API con FastAPI, EC2 y RDS",
    description="API para gestionar usuarios y libros",
    version="1.0.0",
    lifespan=lifespan
)

app.include_router(users.router)
app.include_router(books.router)

@app.get("/")
def root():
    return {"message": "Bienvenido a la API. Visita /docs para probar los endpoints."}
