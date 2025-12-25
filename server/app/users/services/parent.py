import uuid
from typing import List
from fastapi import HTTPException, status
from app.users.repositories.parent import ParentRepository
from app.users.schemas.parent import ParentCreate, ParentRead


class ParentService:
    def __init__(self, repository: ParentRepository):
        self.repository = repository

    async def get_all_parents(self) -> List[ParentRead]:
        parents = await self.repository.get_all()
        return parents or []

    async def get_parent_by_id(self, parent_id: uuid.UUID) -> ParentRead:
        parent = await self.repository.get_by_id(parent_id)
        if not parent:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Parent with id {parent_id} not found",
            )
        return parent

    async def create_parent(self, parent_create: ParentCreate) -> ParentRead:
        return await self.repository.create(parent_create)

    async def update_parent(self, parent_id: uuid.UUID, parent_data: ParentCreate) -> ParentRead:
        updated = await self.repository.update(parent_id, parent_data)
        if not updated:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Parent with id {parent_id} not found",
            )
        return updated

    async def delete_parent(self, parent_id: uuid.UUID) -> None:
        deleted = await self.repository.delete(parent_id)
        if not deleted:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Parent with id {parent_id} not found",
            )
