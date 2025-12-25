from fastapi import APIRouter, Depends, status, Header, HTTPException
from typing import List, Optional
import uuid

from app.users.repositories.teacher import TeacherRepository
from app.users.schemas.teacher import TeacherRead, TeacherCreate
from app.users.services.teacher import TeacherService
from config.database import AsyncSession, get_db

router = APIRouter(prefix="/teachers", tags=["Teachers"])


async def get_teacher_service(session: AsyncSession = Depends(get_db)) -> TeacherService:
    repository = TeacherRepository(session)
    return TeacherService(repository)


@router.get("/", response_model=List[TeacherRead])
async def get_all_teachers(service: TeacherService = Depends(get_teacher_service)):
    return await service.get_all_teachers()


@router.get("/{teacher_id}", response_model=TeacherRead)
async def get_teacher_by_id(
        teacher_id: uuid.UUID, service: TeacherService = Depends(get_teacher_service)
):
    return await service.get_teacher_by_id(teacher_id)


@router.post("/", response_model=TeacherRead, status_code=status.HTTP_201_CREATED)
async def create_teacher(
        teacher_data: TeacherCreate, service: TeacherService = Depends(get_teacher_service)
):
    return await service.create_teacher(teacher_data)


@router.put("/{teacher_id}", response_model=TeacherRead)
async def update_teacher(
        teacher_id: uuid.UUID,
        teacher_data: TeacherCreate,
        service: TeacherService = Depends(get_teacher_service),
):
    return await service.update_teacher(teacher_id, teacher_data)


@router.delete("/{teacher_id}", status_code=status.HTTP_200_OK)
async def delete_teacher(
        teacher_id: uuid.UUID, service: TeacherService = Depends(get_teacher_service)
):
    await service.delete_teacher(teacher_id)
    return {"message": f"Teacher with id {teacher_id} deleted successfully."}
