import uuid
from typing import List, Optional
from sqlalchemy import select
from sqlalchemy.orm import joinedload

from app.grade.models import GradeModel
from app.grade.schemas import GradeCreate, GradeUpdate
from config.database import AsyncSession


class GradeRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, grade_data: GradeCreate) -> GradeModel:
        grade = GradeModel(**grade_data.model_dump())
        self.session.add(grade)
        await self.session.commit()
        await self.session.refresh(grade)
        return grade

    async def get_by_id(self, grade_id: uuid.UUID) -> Optional[GradeModel]:
        result = await self.session.execute(
            select(GradeModel)
            .options(joinedload(GradeModel.subject))
            .where(GradeModel.id == grade_id)
        )
        return result.scalar_one_or_none()

    async def get_all(self) -> List[GradeModel]:
        result = await self.session.execute(
            select(GradeModel).options(joinedload(GradeModel.subject))
        )
        return list(result.scalars().all())

    async def get_by_student(self, student_id: uuid.UUID) -> List[GradeModel]:
        result = await self.session.execute(
            select(GradeModel)
            .options(joinedload(GradeModel.subject))
            .where(GradeModel.student_id == student_id)
            .order_by(GradeModel.created_at.desc())
        )
        return list(result.scalars().all())

    async def get_by_teacher(self, teacher_id: uuid.UUID) -> List[GradeModel]:
        result = await self.session.execute(
            select(GradeModel)
            .options(joinedload(GradeModel.subject))
            .where(GradeModel.teacher_id == teacher_id)
            .order_by(GradeModel.created_at.desc())
        )
        return list(result.scalars().all())

    async def get_by_subject(self, subject_id: uuid.UUID) -> List[GradeModel]:
        result = await self.session.execute(
            select(GradeModel)
            .options(joinedload(GradeModel.subject))
            .where(GradeModel.subject_id == subject_id)
            .order_by(GradeModel.created_at.desc())
        )
        return list(result.scalars().all())

    async def update(self, grade_id: uuid.UUID, grade_data: GradeUpdate) -> Optional[GradeModel]:
        grade = await self.get_by_id(grade_id)
        if not grade:
            return None

        update_data = grade_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(grade, field, value)

        await self.session.commit()
        await self.session.refresh(grade)
        return grade

    async def delete(self, grade_id: uuid.UUID) -> bool:
        grade = await self.get_by_id(grade_id)
        if not grade:
            return False

        await self.session.delete(grade)
        await self.session.commit()
        return True