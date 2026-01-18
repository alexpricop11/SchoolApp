import uuid
from typing import List, Optional

from fastapi import APIRouter, Depends, status, HTTPException
from fastapi.responses import JSONResponse
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
async def get_all_teachers(skip: int = 0, limit: int = 100, q: Optional[str] = None, service: TeacherService = Depends(get_teacher_service)):
    return await service.get_all_teachers(skip=skip, limit=limit, q=q)


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

    # Serialize Class ORM objects to plain dicts so JSON can be returned
    serialized_classes = []
    for c in classes:
        serialized = {
            'id': str(c.id) if getattr(c, 'id', None) else None,
            'name': c.name,
            'school_id': str(c.school_id) if getattr(c, 'school_id', None) else None,
            'created_at': c.created_at.isoformat() if getattr(c, 'created_at', None) else None,
            'updated_at': c.updated_at.isoformat() if getattr(c, 'updated_at', None) else None,
            'teacher_id': str(c.teacher_id) if getattr(c, 'teacher_id', None) else None,
            # serialize students list
            'students': []
        }
        for s in getattr(c, 'students', []):
            # each student has a user attribute loaded
            user_obj = getattr(s, 'user', None)
            serialized_user_obj = {
                'id': str(s.user_id) if getattr(s, 'user_id', None) else None,
                'username': getattr(user_obj, 'username', '') if user_obj else '',
                'name': getattr(user_obj, 'username', '') if user_obj else '',
                'email': getattr(user_obj, 'email', '') if user_obj else '',
                'class_id': str(c.id) if getattr(c, 'id', None) else None,
                'school_id': str(c.school_id) if getattr(c, 'school_id', None) else None,
            }

            serialized_student = {
                'user_id': str(s.user_id) if getattr(s, 'user_id', None) else None,
                'class_id': str(c.id) if getattr(c, 'id', None) else None,
                'parent_id': str(getattr(s, 'parent_id', '')) if getattr(s, 'parent_id', None) else None,
                # provide nested user object to match client expectations
                'user': serialized_user_obj,
                # backward-compatible top-level fields
                'username': serialized_user_obj.get('username'),
                'email': serialized_user_obj.get('email'),
            }
            serialized['students'].append(serialized_student)
        serialized_classes.append(serialized)

    # Serialize teacher.user to plain dict instead of passing ORM object
    serialized_user = {}
    if getattr(teacher, 'user', None):
        u = teacher.user
        serialized_user = {
            'id': str(getattr(u, 'id', None)) if getattr(u, 'id', None) else None,
            'username': getattr(u, 'username', '') or '',
            'email': getattr(u, 'email', '') or '',
            'avatar_url': getattr(u, 'avatar_url', None),
            'school_id': str(getattr(u, 'school_id', None)) if getattr(u, 'school_id', None) else None,
        }

    # Debug log to help client debugging - shows what server will return
    try:
        print('DEBUG teacher.serialized_user=', serialized_user)
        print('DEBUG teacher.serialized_classes_count=', len(serialized_classes))
        if len(serialized_classes) > 0:
            print('DEBUG first class students count=', len(serialized_classes[0].get('students', [])))
    except Exception:
        pass

    # Build explicit payload with strings for UUIDs and ISO datetimes
    teacher_payload = {
        'user_id': str(teacher.user_id) if getattr(teacher, 'user_id', None) else None,
        'subject': teacher.subject,
        'is_homeroom': teacher.is_homeroom,
        'is_director': teacher.is_director,
        'class_id': str(teacher.class_id) if getattr(teacher, 'class_id', None) else None,
        'school_id': str(teacher.user.school_id) if getattr(teacher, 'user', None) and getattr(teacher.user, 'school_id', None) else None,
        'user': serialized_user,
        'classes': serialized_classes,
        'created_at': teacher.created_at.isoformat() if getattr(teacher, 'created_at', None) else None,
        'updated_at': teacher.updated_at.isoformat() if getattr(teacher, 'updated_at', None) else None,
    }

    return JSONResponse(content=teacher_payload)


@router.get("/{teacher_id}", response_model=TeacherRead)
async def get_teacher_by_id(
        teacher_id: uuid.UUID, service: TeacherService = Depends(get_teacher_service)
):
    return await service.get_teacher_by_id(teacher_id)


@router.get("/{teacher_id}/students", response_model=List[dict])
async def get_teacher_students(teacher_id: uuid.UUID, service: TeacherService = Depends(get_teacher_service)):
    return await service.get_students_for_teacher(teacher_id)


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
