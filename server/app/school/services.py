import uuid

from typing import List
from app.school import SchoolRepository, SchoolCreate, SchoolUpdate, SchoolRead


class SchoolService:
    def __init__(self, repository: SchoolRepository):
        self.repository = repository

    async def get_all(self) -> List[SchoolRead]:
        return await self.repository.get_all()

    async def get_by_id(self, id: uuid.UUID) -> SchoolRead:
        return await self.repository.get_by_id(id)

    async def create(self, school_create: SchoolCreate) -> SchoolRead:
        school_create.name = school_create.name.strip().title()
        if school_create.phone:
            school_create.phone = school_create.phone.strip()
        existing_schools = await self.repository.get_all()
        if any(s.name.lower() == school_create.name.lower() for s in existing_schools):
            raise ValueError("School with this name already exists")
        return await self.repository.create(school_create)

    async def update(self, id: uuid.UUID, school_update: SchoolUpdate) -> SchoolRead:
        if school_update.name:
            school_update.name = school_update.name.strip().title()
        if school_update.phone:
            school_update.phone = school_update.phone.strip()

        all_schools = await self.repository.get_all()
        if school_update.name and any(s.name.lower() == school_update.name.lower() and s.id != id for s in all_schools):
            raise ValueError("Another school with this name already exists")

        return await self.repository.update(id, school_update)

    async def delete(self, id: uuid.UUID) -> bool:
        school = await self.repository.get_by_id(id)
        if getattr(school, "classes", None) and len(school.classes) > 0:
            raise ValueError("Cannot delete a school with associated classes")
        if getattr(school, "users", None) and len(school.users) > 0:
            raise ValueError("Cannot delete a school with associated users")
        return await self.repository.delete(id)
