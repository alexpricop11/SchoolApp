import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr

from app.users import UserRole


class UserBase(BaseModel):
    id: Optional[uuid.UUID]
    username: str
    email: EmailStr
    role: UserRole
    is_activated: bool = False
    school_id: Optional[uuid.UUID] = None

    class Config:
        from_attributes = True


class UserCreate(BaseModel):
    username: str
    email: EmailStr
    role: UserRole
    is_activated: bool = False
    school_id: Optional[uuid.UUID] = None


class UserRead(BaseModel):
    id: uuid.UUID
    username: str
    email: EmailStr
    role: UserRole
    is_activated: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
