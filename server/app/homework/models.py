import enum
import uuid
from datetime import datetime
from typing import TYPE_CHECKING, Optional

from sqlalchemy import ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql.functions import func

from config.database import Base

if TYPE_CHECKING:
    from app.users.models import Teacher, Student
    from app.subject.models import Subject
    from app.classes.models import Class


class HomeworkStatus(str, enum.Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    OVERDUE = "overdue"


class Homework(Base):
    __tablename__ = "homeworks"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, unique=True, index=True
    )

    title: Mapped[str] = mapped_column(nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    due_date: Mapped[datetime] = mapped_column(nullable=False)
    status: Mapped[HomeworkStatus] = mapped_column(default=HomeworkStatus.PENDING)

    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(server_default=func.now(), onupdate=func.now())

    # Foreign keys
    subject_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("subjects.id", ondelete="CASCADE"),
        nullable=False
    )
    class_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("classes.id", ondelete="CASCADE"),
        nullable=False
    )
    teacher_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("teachers.user_id", ondelete="CASCADE"),
        nullable=False
    )

    # Relationships
    subject: Mapped["Subject"] = relationship("Subject", back_populates="homeworks")
    class_: Mapped["Class"] = relationship("Class", back_populates="homeworks")
    teacher: Mapped["Teacher"] = relationship("Teacher", back_populates="homeworks")

    def __repr__(self):
        return f"<Homework(title={self.title}, due_date={self.due_date})>"