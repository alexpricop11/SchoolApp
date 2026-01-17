from __future__ import annotations

from datetime import datetime
from typing import Optional, List, TYPE_CHECKING
from uuid import UUID
from pydantic import BaseModel

if TYPE_CHECKING:
    from app.users.schemas import TeacherRead, StudentRead


class ClassBase(BaseModel):
    name: str
    school_id: UUID
    teachers: Optional[List[TeacherRead]] = None
    students: Optional[List[StudentRead]] = None

    model_config = {"from_attributes": True}


class ClassCreate(ClassBase):
    pass


class ClassUpdate(BaseModel):
    name: Optional[str] = None
    school_id: Optional[UUID] = None


class ClassOut(ClassBase):
    id: UUID
    created_at: datetime
    updated_at: datetime

    model_config = {
        "from_attributes": True
    }
