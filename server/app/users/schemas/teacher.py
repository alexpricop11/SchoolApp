import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr


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
    # Use a relaxed dict type for user to accept serialized dicts from ORM without strict validation
    user: dict
    # Use a generic dict list to avoid circular schema references (ClassOut -> TeacherRead -> StudentRead)
    classes: list[dict] = []
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
