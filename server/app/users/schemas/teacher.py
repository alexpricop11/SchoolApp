import uuid
from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel, EmailStr

from .user_base import UserRead
from ...classes import Class


class TeacherBase(BaseModel):
    user_id: uuid.UUID
    subject: Optional[str]
    is_director: Optional[bool] = False

    class Config:
        from_attributes = True


class TeacherCreate(BaseModel):
    username: str
    email: EmailStr
    subject: Optional[str]
    is_homeroom: Optional[bool] = False
    is_director: Optional[bool] = False
    school_id: Optional[uuid.UUID] = None


class TeacherUpdate(TeacherCreate):
    pass


class TeacherRead(TeacherBase):
    user_id: uuid.UUID
    user: UserRead
    subject: Optional[str]
    classes: Optional[List[uuid.UUID]] = []
    created_at: datetime
    updated_at: datetime
