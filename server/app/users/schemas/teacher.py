import uuid
from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel, EmailStr

from .user_base import UserRead
from ...classes import Class
from ...classes.schemas import ClassBase


class TeacherBase(BaseModel):
    user_id: uuid.UUID
    subject: Optional[str]
    is_director: Optional[bool] = False
    is_homeroom: Optional[bool] = False
    class_id: Optional[uuid.UUID] = None
    school_id: Optional[uuid.UUID] = None

    class Config:
        from_attributes = True


class TeacherCreate(TeacherBase):
    username: str
    email: EmailStr


class TeacherUpdate(TeacherCreate):
    pass


class TeacherRead(TeacherBase):
    user: UserRead
    classes: list[ClassBase] = []
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
