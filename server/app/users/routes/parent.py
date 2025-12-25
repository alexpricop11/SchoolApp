from fastapi import APIRouter, Depends, status
from typing import List
import uuid

from app.users.schemas.parent import ParentRead, ParentCreate
from app.users.repositories.parent import ParentRepository
from app.users.services.parent import ParentService
from config.database import AsyncSession, get_db

router = APIRouter(prefix="/parents", tags=["Parents"])


async def get_parent_service(session: AsyncSession = Depends(get_db)) -> ParentService:
    repository = ParentRepository(session)
    return ParentService(repository)


@router.get("/", response_model=List[ParentRead], )
async def get_all_parents(service: ParentService = Depends(get_parent_service)):
    return await service.get_all_parents()


@router.get("/{parent_id}", response_model=ParentRead)
async def get_parent_by_id(
        parent_id: uuid.UUID, service: ParentService = Depends(get_parent_service)
):
    return await service.get_parent_by_id(parent_id)


@router.post("/", response_model=ParentRead, status_code=status.HTTP_201_CREATED)
async def create_parent(
        parent_data: ParentCreate, service: ParentService = Depends(get_parent_service)
):
    return await service.create_parent(parent_data)


@router.put("/{parent_id}", response_model=ParentRead)
async def update_parent(
        parent_id: uuid.UUID,
        parent_data: ParentCreate,
        service: ParentService = Depends(get_parent_service),
):
    return await service.update_parent(parent_id, parent_data)


@router.delete("/{parent_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_parent(
        parent_id: uuid.UUID, service: ParentService = Depends(get_parent_service)
):
    await service.delete_parent(parent_id)
    return {"message": f"Parent with id {parent_id} deleted successfully."}
