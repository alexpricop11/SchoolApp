import uuid
from datetime import datetime
from typing import List, Optional

from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from sqlalchemy.exc import SQLAlchemyError

from app.users.models import Student, User, UserRole
from app.users.schemas.student import StudentCreate, StudentRead
from config.database import AsyncSession


class StudentRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_all(self) -> List[StudentRead]:
        result = await self.session.execute(select(Student).options(selectinload(Student.user)))
        students = result.scalars().all()
        return [StudentRead.model_validate(student) for student in students]

    async def get_by_id(self, student_id: uuid.UUID) -> Optional[StudentRead]:
        result = await self.session.execute(
            select(Student).options(selectinload(Student.user)).where(Student.user_id == student_id)
        )
        student = result.scalars().first()
        return StudentRead.model_validate(student) if student else None

    async def create(self, student_create: StudentCreate) -> Optional[StudentRead]:
        try:
            async with self.session.begin():
                user = User(
                    id=uuid.uuid4(),
                    username=student_create.username,
                    email=str(student_create.email),
                    role=UserRole.STUDENT,
                    school_id=student_create.school_id,
                    class_id=student_create.class_id,
                    created_at=datetime.utcnow(),
                    updated_at=datetime.utcnow(),
                )
                self.session.add(user)
                await self.session.flush()
                student = Student(
                    user_id=user.id,
                    parent_id=student_create.parent_id,
                )
                self.session.add(student)
            await self.session.refresh(student)
            return StudentRead.model_validate(student)
        except SQLAlchemyError:
            await self.session.rollback()
            return None

    async def update(self, student_id: uuid.UUID, student_data: StudentCreate) -> Optional[StudentRead]:
        try:
            async with self.session.begin():
                result = await self.session.execute(
                    select(Student).options(selectinload(Student.user)).where(Student.user_id == student_id)
                )
                student = result.scalars().first()
                if not student:
                    return None

                if student_data.username:
                    student.user.username = student_data.username
                if student_data.email:
                    student.user.email = str(student_data.email)
                if student_data.parent_id is not None:
                    student.parent_id = student_data.parent_id
                if student_data.class_id is not None:
                    student.class_id = student_data.class_id
            await self.session.refresh(student)
            return StudentRead.model_validate(student)
        except SQLAlchemyError:
            await self.session.rollback()
            return None

    async def delete(self, student_id: uuid.UUID) -> bool:
        try:
            async with self.session.begin():
                result = await self.session.execute(select(Student).where(Student.user_id == student_id))
                student = result.scalars().first()
                if not student:
                    return False
                await self.session.delete(student)
            return True
        except SQLAlchemyError:
            await self.session.rollback()
            return False
