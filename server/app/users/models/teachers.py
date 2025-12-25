import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql.functions import func
from sqlalchemy.sql.sqltypes import String, Boolean, DateTime

from config.database import Base

if TYPE_CHECKING:
    from app.grade.models import GradeModel
    from app.users.models import User
    from app.classes.models import Class


class Teacher(Base):
    __tablename__ = "teachers"

    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )

    subject: Mapped[str | None] = mapped_column(String, nullable=True)

    is_homeroom: Mapped[bool] = mapped_column(Boolean(), default=False, nullable=False)
    is_director: Mapped[bool] = mapped_column(Boolean(), default=False, nullable=False)

    created_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.now(), onupdate=func.now()
    )

    classes: Mapped[list["Class"]] = relationship(
        "Class", back_populates="teacher", cascade="all, delete-orphan"
    )
    user: Mapped["User"] = relationship("User", back_populates="teacher", uselist=False)
