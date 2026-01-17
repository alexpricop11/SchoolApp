import uuid
from typing import List
from fastapi import APIRouter, Depends, Query, status

from app.grade.repository import GradeRepository
from app.grade.schemas import GradeCreate, GradeRead, GradeUpdate
from app.grade.service import GradeService
from config.database import AsyncSession, get_db
from config.dependences import get_current_user, admin_required
from config.pagination import PaginationParams

router = APIRouter(prefix="/grades", tags=["Grades"])


async def get_grade_service(session: AsyncSession = Depends(get_db)) -> GradeService:
    repository = GradeRepository(session)
    return GradeService(repository)


@router.post("/", response_model=GradeRead, status_code=status.HTTP_201_CREATED)
async def create_grade(
    grade_data: GradeCreate,
    current_user: dict = Depends(get_current_user),
    service: GradeService = Depends(get_grade_service)
):
    """Create a new grade (Teacher or Admin only)"""
    return await service.create_grade(grade_data)


@router.get("/", dependencies=[Depends(admin_required)])
async def get_all_grades(
    pagination: PaginationParams = Depends(),
    service: GradeService = Depends(get_grade_service)
):
    """Get all grades with pagination (Admin only)"""
    return await service.get_all_grades(pagination.skip, pagination.limit)


@router.get("/my-grades", response_model=List[GradeRead])
async def get_my_grades(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=200),
    current_user: dict = Depends(get_current_user),
    service: GradeService = Depends(get_grade_service)
):
    """Get grades for the current student with pagination"""
    user_id = uuid.UUID(current_user["id"])
    items, total = await service.get_student_grades(user_id, skip, limit)
    return items  # Return items directly for backward compatibility


@router.get("/student/{student_id}", response_model=List[GradeRead])
async def get_student_grades(
    student_id: uuid.UUID,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=200),
    current_user: dict = Depends(get_current_user),
    service: GradeService = Depends(get_grade_service)
):
    """Get grades for a specific student with pagination"""
    items, total = await service.get_student_grades(student_id, skip, limit)
    return items


@router.get("/teacher/{teacher_id}", response_model=List[GradeRead])
async def get_teacher_grades(
    teacher_id: uuid.UUID,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=200),
    current_user: dict = Depends(get_current_user),
    service: GradeService = Depends(get_grade_service)
):
    """Get all grades given by a specific teacher with pagination"""
    items, total = await service.get_teacher_grades(teacher_id, skip, limit)
    return items


@router.get("/subject/{subject_id}", response_model=List[GradeRead])
async def get_subject_grades(
    subject_id: uuid.UUID,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=200),
    current_user: dict = Depends(get_current_user),
    service: GradeService = Depends(get_grade_service)
):
    """Get all grades for a specific subject with pagination"""
    items, total = await service.get_subject_grades(subject_id, skip, limit)
    return items


@router.get("/{grade_id}", response_model=GradeRead)
async def get_grade(
    grade_id: uuid.UUID,
    current_user: dict = Depends(get_current_user),
    service: GradeService = Depends(get_grade_service)
):
    """Get a specific grade by ID"""
    return await service.get_grade(grade_id)


@router.put("/{grade_id}", response_model=GradeRead)
async def update_grade(
    grade_id: uuid.UUID,
    grade_data: GradeUpdate,
    current_user: dict = Depends(get_current_user),
    service: GradeService = Depends(get_grade_service)
):
    """Update a grade (Teacher or Admin only)"""
    return await service.update_grade(grade_id, grade_data)


@router.delete("/{grade_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_grade(
    grade_id: uuid.UUID,
    current_user: dict = Depends(get_current_user),
    service: GradeService = Depends(get_grade_service)
):
    """Delete a grade (Admin only)"""
    await service.delete_grade(grade_id)
