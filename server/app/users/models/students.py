import uuid
from datetime import datetime
from typing import TYPE_CHECKING, Optional

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql.functions import func

from config.database import Base

if TYPE_CHECKING:
    from app.users.models import User, Parent


class Student(Base):
    __tablename__ = "students"

    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    user: Mapped["User"] = relationship("User", back_populates="student", uselist=False)

    parent_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        ForeignKey("parents.id", ondelete="SET NULL"), nullable=True
    )
    parent: Mapped[Optional["Parent"]] = relationship("Parent", back_populates="students")

    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f"<Student(user_id={self.user_id})>"
