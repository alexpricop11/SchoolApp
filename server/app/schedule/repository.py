import uuid
from typing import List, Optional
from sqlalchemy import select
from sqlalchemy.orm import joinedload

from app.schedule.models import Schedule
from app.schedule.schemas import ScheduleCreate, ScheduleUpdate
from config.database import AsyncSession


class ScheduleRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, schedule_data: ScheduleCreate) -> Schedule:
        schedule = Schedule(**schedule_data.model_dump())
        self.session.add(schedule)
        await self.session.commit()
        await self.session.refresh(schedule)
        return schedule

    async def get_by_id(self, schedule_id: uuid.UUID) -> Optional[Schedule]:
        result = await self.session.execute(
            select(Schedule)
            .options(joinedload(Schedule.subject))
            .where(Schedule.id == schedule_id)
        )
        return result.scalar_one_or_none()

    async def get_by_class(self, class_id: uuid.UUID) -> List[Schedule]:
        result = await self.session.execute(
            select(Schedule)
            .options(joinedload(Schedule.subject))
            .where(Schedule.class_id == class_id)
            .order_by(Schedule.day_of_week, Schedule.period_number)
        )
        return list(result.scalars().all())

    async def get_by_teacher(self, teacher_id: uuid.UUID) -> List[Schedule]:
        result = await self.session.execute(
            select(Schedule)
            .options(joinedload(Schedule.subject), joinedload(Schedule.class_))
            .where(Schedule.teacher_id == teacher_id)
            .order_by(Schedule.day_of_week, Schedule.period_number)
        )
        return list(result.scalars().all())

    async def update(self, schedule_id: uuid.UUID, schedule_data: ScheduleUpdate) -> Optional[Schedule]:
        schedule = await self.get_by_id(schedule_id)
        if not schedule:
            return None

        update_data = schedule_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(schedule, field, value)

        await self.session.commit()
        await self.session.refresh(schedule)
        return schedule

    async def delete(self, schedule_id: uuid.UUID) -> bool:
        schedule = await self.get_by_id(schedule_id)
        if not schedule:
            return False

        await self.session.delete(schedule)
        await self.session.commit()
        return True
