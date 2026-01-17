import uuid
from typing import List

from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.classes.models import Class
from app.users.models import Teacher
from app.users.models.students import Student
from app.users.repositories.teacher import TeacherRepository
from app.users.repositories.user import UserRepository
from app.users.schemas.teacher import TeacherRead, TeacherCreate, TeacherUpdate
from app.users.services.teacher import TeacherService
from config.database import AsyncSession, get_db
from config.dependences import admin_required, get_current_user

router = APIRouter(prefix="/teachers", tags=["Teachers"])


async def get_teacher_service(session: AsyncSession = Depends(get_db)) -> TeacherService:
    teacher_repository = TeacherRepository(session)
    user_repository = UserRepository(session)
    return TeacherService(repository=teacher_repository, user_repository=user_repository)


@router.get("/", response_model=List[TeacherRead], dependencies=[Depends(admin_required)])
async def get_all_teachers(service: TeacherService = Depends(get_teacher_service)):
    return await service.get_all_teachers()


@router.get("/me", response_model=TeacherRead)
async def get_current_teacher(
        current_user: dict = Depends(get_current_user),
        service: TeacherService = Depends(get_teacher_service),
        session: AsyncSession = Depends(get_db),
):
    try:
        user_uuid = uuid.UUID(current_user["id"])
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid user ID in token",
        )

    teacher = await service.repository.get_by_user_id(user_uuid)

    if not teacher:
        new_teacher = Teacher(
            user_id=user_uuid,
        )
        session.add(new_teacher)
        await session.commit()
        await session.refresh(new_teacher)
        teacher = await service.repository.get_by_user_id(user_uuid)

    await session.refresh(teacher, attribute_names=["user"])

    classes_query = select(Class).where(Class.teacher_id == user_uuid).options(
        selectinload(Class.students).selectinload(Student.user)
    )
    result = await session.execute(classes_query)
    classes = list(result.scalars().all())
    teacher_data = TeacherRead(
        user_id=teacher.user_id,
        subject=teacher.subject,
        is_homeroom=teacher.is_homeroom,
        is_director=teacher.is_director,
        class_id=teacher.class_id,
        school_id=teacher.user.school_id if teacher.user else None,
        user=teacher.user,
        classes=classes,
        created_at=teacher.created_at,
        updated_at=teacher.updated_at,
    )

    return teacher_data


@router.get("/{teacher_id}", response_model=TeacherRead)
async def get_teacher_by_id(
        teacher_id: uuid.UUID, service: TeacherService = Depends(get_teacher_service)
):
    return await service.get_teacher_by_id(teacher_id)


@router.post("/", response_model=TeacherRead, status_code=status.HTTP_201_CREATED,
             dependencies=[Depends(admin_required)])
async def create_teacher(
        teacher_data: TeacherCreate, service: TeacherService = Depends(get_teacher_service)
):
    return await service.create_teacher(teacher_data)


@router.put("/{teacher_id}", response_model=TeacherRead, dependencies=[Depends(admin_required)])
async def update_teacher(
        teacher_id: uuid.UUID,
        teacher_data: TeacherUpdate,
        service: TeacherService = Depends(get_teacher_service),
):
    return await service.update_teacher(teacher_id, teacher_data)


@router.delete("/{teacher_id}", status_code=status.HTTP_200_OK, dependencies=[Depends(admin_required)])
async def delete_teacher(
        teacher_id: uuid.UUID, service: TeacherService = Depends(get_teacher_service)
):
    await service.delete_teacher(teacher_id)
    return {"message": f"Teacher with id {teacher_id} deleted successfully."}
