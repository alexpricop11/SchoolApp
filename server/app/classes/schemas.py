from datetime import datetime
from typing import Optional
from uuid import UUID
from pydantic import BaseModel


class ClassBase(BaseModel):
    name: str
    school_id: UUID
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
