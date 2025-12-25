from datetime import datetime

from typing import Optional, List
from pydantic import BaseModel, Field, EmailStr
import uuid


# Schema de bază
class SchoolBase(BaseModel):
    name: str = Field(..., min_length=3)
    location: str = Field(..., min_length=3)
    phone: Optional[str] = Field(None, min_length=9)
    email: Optional[EmailStr] = None


class SchoolCreate(SchoolBase):
    pass


class SchoolUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=3)
    location: Optional[str] = Field(None, min_length=3)
    phone: Optional[str] = Field(None, min_length=9)
    email: Optional[EmailStr] = None

    class Config:
        from_attributes = True


class SchoolRead(SchoolBase):
    id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
