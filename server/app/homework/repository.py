import uuid
from typing import List, Optional
from sqlalchemy import select
from sqlalchemy.orm import joinedload

from app.homework.models import Homework
from app.homework.schemas import HomeworkCreate, HomeworkUpdate
from config.database import AsyncSession


class HomeworkRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, homework_data: HomeworkCreate) -> Homework:
        homework = Homework(**homework_data.model_dump())
        self.session.add(homework)
        await self.session.commit()
        await self.session.refresh(homework)
        return homework

    async def get_by_id(self, homework_id: uuid.UUID) -> Optional[Homework]:
        result = await self.session.execute(
            select(Homework)
            .options(joinedload(Homework.subject))
            .where(Homework.id == homework_id)
        )
        return result.scalar_one_or_none()

    async def get_by_class(self, class_id: uuid.UUID) -> List[Homework]:
        result = await self.session.execute(
            select(Homework)
            .options(joinedload(Homework.subject))
            .where(Homework.class_id == class_id)
            .order_by(Homework.due_date.asc())
        )
        return list(result.scalars().all())

    async def update(self, homework_id: uuid.UUID, homework_data: HomeworkUpdate) -> Optional[Homework]:
        homework = await self.get_by_id(homework_id)
        if not homework:
            return None

        update_data = homework_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(homework, field, value)

        await self.session.commit()
        await self.session.refresh(homework)
        return homework

    async def delete(self, homework_id: uuid.UUID) -> bool:
        homework = await self.get_by_id(homework_id)
        if not homework:
            return False

        await self.session.delete(homework)
        await self.session.commit()
        return True