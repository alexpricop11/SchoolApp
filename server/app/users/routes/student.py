from fastapi import APIRouter, Depends, status, HTTPException
from typing import List
import uuid

from app.users.repositories import StudentRepository
from app.users.schemas.student import StudentRead, StudentCreate
from app.users.services import StudentService
from config.database import AsyncSession, get_db
from config.dependences import get_current_user

router = APIRouter(prefix="/students", tags=["Students"])


async def get_student_service(session: AsyncSession = Depends(get_db)) -> StudentService:
    repository = StudentRepository(session)
    return StudentService(repository)


@router.get("/", response_model=List[StudentRead])
async def get_all_students(service: StudentService = Depends(get_student_service)):
    return await service.get_all_students()


@router.get("/me", response_model=StudentRead)
async def get_current_student(
        current_user: dict = Depends(get_current_user),
        service: StudentService = Depends(get_student_service)
):
    try:
        user_uuid = uuid.UUID(current_user["id"])
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid user ID in token")

    return await service.get_student_by_id(user_uuid)


@router.get("/{student_id}", response_model=StudentRead)
async def get_student_by_id(student_id: uuid.UUID, service: StudentService = Depends(get_student_service)):
    return await service.get_student_by_id(student_id)


@router.post("/", response_model=StudentRead, status_code=status.HTTP_201_CREATED)
async def create_student(
        student_data: StudentCreate, service: StudentService = Depends(get_student_service)
):
    return await service.create_student(student_data)


@router.put("/{student_id}", response_model=StudentRead)
async def update_student(
        student_id: uuid.UUID,
        student_data: StudentCreate,
        service: StudentService = Depends(get_student_service),
):
    return await service.update_student(student_id, student_data)


@router.delete("/{student_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_student(
        student_id: uuid.UUID, service: StudentService = Depends(get_student_service)
):
    await service.delete_student(student_id)
    return {"message": f"Student with id {student_id} deleted successfully."}
