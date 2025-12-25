import uuid
from typing import List
from fastapi import HTTPException, status

from app.users.repositories.teacher import TeacherRepository
from app.users.schemas.teacher import TeacherCreate, TeacherRead


class TeacherService:
    def __init__(self, repository: TeacherRepository):
        self.repository = repository

    async def get_all_teachers(self) -> List[TeacherRead]:
        teachers = await self.repository.get_all()
        if not teachers:
            return []
        return teachers

    async def get_teacher_by_id(self, teacher_id: uuid.UUID) -> TeacherRead:
        teacher = await self.repository.get_by_id(teacher_id)
        if not teacher:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Teacher with id {teacher_id} not found",
            )
        return teacher

    async def get_teacher_by_user_id(self, user_id: uuid.UUID) -> TeacherRead:
        teacher = await self.repository.get_by_id(user_id)
        if not teacher:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Teacher for user_id {user_id} not found",
            )
        return teacher

    async def create_teacher(self, teacher_create: TeacherCreate) -> TeacherRead:
        return await self.repository.create(teacher_create)

    async def update_teacher(
            self, teacher_id: uuid.UUID, teacher_data: TeacherCreate
    ) -> TeacherRead:
        updated = await self.repository.update(teacher_id, teacher_data)
        if not updated:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Teacher with id {teacher_id} not found",
            )
        return updated

    async def delete_teacher(self, teacher_id: uuid.UUID) -> None:
        deleted = await self.repository.delete(teacher_id)
        if not deleted:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Teacher with id {teacher_id} not found",
            )
