import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr

from app.users.schemas.user_base import UserRead


class StudentBase(BaseModel):
    id: Optional[uuid.UUID]
    user_id: uuid.UUID
    parent_id: Optional[uuid.UUID]

    class Config:
        from_attributes = True


class StudentCreate(BaseModel):
    username: str
    email: EmailStr
    parent_id: Optional[uuid.UUID] = None
    class_id: uuid.UUID
    school_id: uuid.UUID


class StudentUpdate(StudentCreate):
    pass


class StudentRead(BaseModel):
    user_id: uuid.UUID
    user: Optional[UserRead]
    parent_id: Optional[uuid.UUID] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
