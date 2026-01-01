import uuid
from typing import List
from fastapi import APIRouter, Depends, status

from app.notification.repository import NotificationRepository
from app.notification.schemas import NotificationCreate, NotificationRead
from app.notification.service import NotificationService
from config.database import AsyncSession, get_db
from config.dependences import get_current_user

router = APIRouter(prefix="/notifications", tags=["Notifications"])


async def get_notification_service(session: AsyncSession = Depends(get_db)) -> NotificationService:
    repository = NotificationRepository(session)
    return NotificationService(repository)


@router.post("/", response_model=NotificationRead, status_code=status.HTTP_201_CREATED)
async def create_notification(
    notification_data: NotificationCreate,
    current_user: dict = Depends(get_current_user),
    service: NotificationService = Depends(get_notification_service)
):
    return await service.create_notification(notification_data)


@router.get("/my-notifications", response_model=List[NotificationRead])
async def get_my_notifications(
    current_user: dict = Depends(get_current_user),
    service: NotificationService = Depends(get_notification_service)
):
    user_id = uuid.UUID(current_user["id"])
    return await service.get_user_notifications(user_id)


@router.put("/{notification_id}/read", response_model=NotificationRead)
async def mark_notification_as_read(
    notification_id: uuid.UUID,
    current_user: dict = Depends(get_current_user),
    service: NotificationService = Depends(get_notification_service)
):
    return await service.mark_as_read(notification_id)


@router.delete("/{notification_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_notification(
    notification_id: uuid.UUID,
    current_user: dict = Depends(get_current_user),
    service: NotificationService = Depends(get_notification_service)
):
    await service.delete_notification(notification_id)