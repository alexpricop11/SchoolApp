import uuid
from fastapi import HTTPException
from typing import List, Any, Coroutine
from sqlalchemy.future import select

from app.school import SchoolRead, School, SchoolUpdate, SchoolCreate
from config.database import AsyncSession


class SchoolRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_all(self) -> List[SchoolRead]:
        result = await self.session.execute(select(School))
        schools = result.scalars().all()
        return [SchoolRead.model_validate(school) for school in schools]

    async def get_by_id(self, id: uuid.UUID) -> SchoolRead | None:
        result = await self.session.execute(select(School).where(School.id == id))
        school = result.scalars().first()
        if not school:
            return None
        return SchoolRead.model_validate(school)

    async def create(self, school_create: SchoolCreate) -> SchoolRead:
        school = School(
            name=school_create.name,
            location=school_create.location,
            phone=school_create.phone,
            email=school_create.email
        )
        self.session.add(school)
        await self.session.commit()
        await self.session.refresh(school)
        return SchoolRead.model_validate(school)

    async def update(self, id: uuid.UUID, school_update: SchoolUpdate) -> SchoolRead:
        result = await self.session.execute(select(School).where(School.id == id))
        school = result.scalars().first()
        if not school:
            raise HTTPException(status_code=404, detail="School not found")
        update_data = school_update.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(school, key, value)
        await self.session.commit()
        await self.session.refresh(school)
        return SchoolRead.model_validate(school)

    async def delete(self, id: uuid.UUID) -> bool:
        result = await self.session.execute(select(School).where(School.id == id))
        school = result.scalars().first()
        if not school:
            raise HTTPException(status_code=404, detail="School not found")
        await self.session.delete(school)
        await self.session.commit()
        return True
