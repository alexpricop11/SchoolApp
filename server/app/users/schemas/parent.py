import uuid
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel

from .user_base import UserRead


class ParentBase(BaseModel):
    id: Optional[uuid.UUID]
    user_id: uuid.UUID

    class Config:
        from_attributes = True


class ParentCreate(BaseModel):
    user_id: uuid.UUID


class ParentRead(ParentBase):
    user: Optional[UserRead]
    children_ids: Optional[List[uuid.UUID]] = []
    created_at: datetime
    updated_at: datetime
