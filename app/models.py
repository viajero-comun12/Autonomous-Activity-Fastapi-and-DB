from typing import List, Optional
from sqlmodel import Field, SQLModel, Relationship

class UserBase(SQLModel):
    name: str
    email: str = Field(unique=True, index=True)
    is_active: bool = True

class User(UserBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    books: List["Book"] = Relationship(back_populates="owner")

class UserCreate(UserBase):
    pass

class UserRead(UserBase):
    id: int

class UserUpdate(SQLModel):
    name: Optional[str] = None
    email: Optional[str] = None
    is_active: Optional[bool] = None

class BookBase(SQLModel):
    title: str
    description: Optional[str] = None
    owner_id: Optional[int] = Field(default=None, foreign_key="user.id")

class Book(BookBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    owner: Optional[User] = Relationship(back_populates="books")

class BookCreate(BookBase):
    pass

class BookRead(BookBase):
    id: int

class BookUpdate(SQLModel):
    title: Optional[str] = None
    description: Optional[str] = None
    owner_id: Optional[int] = None
