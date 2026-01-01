import uuid
from typing import List
from fastapi import HTTPException, status

from app.homework.models import Homework
from app.homework.repository import HomeworkRepository
from app.homework.schemas import HomeworkCreate, HomeworkUpdate


class HomeworkService:
    def __init__(self, repository: HomeworkRepository):
        self.repository = repository

    async def create_homework(self, homework_data: HomeworkCreate) -> Homework:
        return await self.repository.create(homework_data)

    async def get_homework(self, homework_id: uuid.UUID) -> Homework:
        homework = await self.repository.get_by_id(homework_id)
        if not homework:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Homework with id {homework_id} not found"
            )
        return homework

    async def get_class_homework(self, class_id: uuid.UUID) -> List[Homework]:
        return await self.repository.get_by_class(class_id)

    async def update_homework(self, homework_id: uuid.UUID, homework_data: HomeworkUpdate) -> Homework:
        homework = await self.repository.update(homework_id, homework_data)
        if not homework:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Homework with id {homework_id} not found"
            )
        return homework

    async def delete_homework(self, homework_id: uuid.UUID) -> None:
        success = await self.repository.delete(homework_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Homework with id {homework_id} not found"
            )