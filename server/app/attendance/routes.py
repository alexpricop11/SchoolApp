import uuid
from typing import List
from fastapi import APIRouter, Depends, status

from app.attendance.repository import AttendanceRepository
from app.attendance.schemas import AttendanceCreate, AttendanceRead, AttendanceUpdate
from app.attendance.service import AttendanceService
from config.database import AsyncSession, get_db
from config.dependences import get_current_user

router = APIRouter(prefix="/attendance", tags=["Attendance"])


async def get_attendance_service(session: AsyncSession = Depends(get_db)) -> AttendanceService:
    repository = AttendanceRepository(session)
    return AttendanceService(repository)


@router.post("/", response_model=AttendanceRead, status_code=status.HTTP_201_CREATED)
async def create_attendance(
    attendance_data: AttendanceCreate,
    current_user: dict = Depends(get_current_user),
    service: AttendanceService = Depends(get_attendance_service)
):
    return await service.create_attendance(attendance_data)


@router.get("/student/{student_id}", response_model=List[AttendanceRead])
async def get_student_attendance(
    student_id: uuid.UUID,
    current_user: dict = Depends(get_current_user),
    service: AttendanceService = Depends(get_attendance_service)
):
    return await service.get_student_attendance(student_id)


@router.get("/{attendance_id}", response_model=AttendanceRead)
async def get_attendance(
    attendance_id: uuid.UUID,
    current_user: dict = Depends(get_current_user),
    service: AttendanceService = Depends(get_attendance_service)
):
    return await service.get_attendance(attendance_id)


@router.put("/{attendance_id}", response_model=AttendanceRead)
async def update_attendance(
    attendance_id: uuid.UUID,
    attendance_data: AttendanceUpdate,
    current_user: dict = Depends(get_current_user),
    service: AttendanceService = Depends(get_attendance_service)
):
    return await service.update_attendance(attendance_id, attendance_data)


@router.delete("/{attendance_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_attendance(
    attendance_id: uuid.UUID,
    current_user: dict = Depends(get_current_user),
    service: AttendanceService = Depends(get_attendance_service)
):
    await service.delete_attendance(attendance_id)