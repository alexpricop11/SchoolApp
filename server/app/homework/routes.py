import uuid
from typing import List
from fastapi import APIRouter, Depends, status

from app.homework.repository import HomeworkRepository
from app.homework.schemas import HomeworkCreate, HomeworkRead, HomeworkUpdate
from app.homework.service import HomeworkService
from config.database import AsyncSession, get_db
from config.dependences import get_current_user

router = APIRouter(prefix="/homework", tags=["Homework"])


async def get_homework_service(session: AsyncSession = Depends(get_db)) -> HomeworkService:
    repository = HomeworkRepository(session)
    return HomeworkService(repository)


@router.post("/", response_model=HomeworkRead, status_code=status.HTTP_201_CREATED)
async def create_homework(
    homework_data: HomeworkCreate,
    current_user: dict = Depends(get_current_user),
    service: HomeworkService = Depends(get_homework_service)
):
    return await service.create_homework(homework_data)


@router.get("/class/{class_id}", response_model=List[HomeworkRead])
async def get_class_homework(
    class_id: uuid.UUID,
    current_user: dict = Depends(get_current_user),
    service: HomeworkService = Depends(get_homework_service)
):
    return await service.get_class_homework(class_id)


@router.get("/{homework_id}", response_model=HomeworkRead)
async def get_homework(
    homework_id: uuid.UUID,
    current_user: dict = Depends(get_current_user),
    service: HomeworkService = Depends(get_homework_service)
):
    return await service.get_homework(homework_id)


@router.put("/{homework_id}", response_model=HomeworkRead)
async def update_homework(
    homework_id: uuid.UUID,
    homework_data: HomeworkUpdate,
    current_user: dict = Depends(get_current_user),
    service: HomeworkService = Depends(get_homework_service)
):
    return await service.update_homework(homework_id, homework_data)


@router.delete("/{homework_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_homework(
    homework_id: uuid.UUID,
    current_user: dict = Depends(get_current_user),
    service: HomeworkService = Depends(get_homework_service)
):
    await service.delete_homework(homework_id)