import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel

from app.homework.models import HomeworkStatus


class HomeworkBase(BaseModel):
    title: str
    description: Optional[str] = None
    due_date: datetime
    subject_id: uuid.UUID
    class_id: uuid.UUID
    teacher_id: uuid.UUID


class HomeworkCreate(HomeworkBase):
    pass


class HomeworkUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    due_date: Optional[datetime] = None
    status: Optional[HomeworkStatus] = None


class SubjectInfo(BaseModel):
    id: uuid.UUID
    name: str

    class Config:
        from_attributes = True


class HomeworkRead(HomeworkBase):
    id: uuid.UUID
    status: HomeworkStatus
    created_at: datetime
    subject: Optional[SubjectInfo] = None

    class Config:
        from_attributes = True
