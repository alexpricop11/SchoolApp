from fastapi import APIRouter, Depends, status
from typing import List
import uuid
from app.users.schemas.user_base import UserCreate, UserRead
from app.users.repositories.user import UserRepository
from app.users.services.user import UserService
from config.database import AsyncSession, get_db
from config.dependences import admin_required

router = APIRouter(prefix="/users", tags=["Users"])


async def get_user_service(session: AsyncSession = Depends(get_db)) -> UserService:
    repository = UserRepository(session)
    return UserService(repository)


@router.get("/", response_model=List[UserRead], dependencies=[Depends(admin_required)])
async def get_all_users(service: UserService = Depends(get_user_service)):
    return await service.get_all_users()


@router.get("/{user_id}", response_model=UserRead)
async def get_user_by_id(user_id: uuid.UUID, service: UserService = Depends(get_user_service)):
    return await service.get_user_by_id(user_id)


@router.post("/",
             response_model=UserRead,
             status_code=status.HTTP_201_CREATED,
             dependencies=[Depends(admin_required)],
             )
async def create_user(user_data: UserCreate, service: UserService = Depends(get_user_service)):
    return await service.create_user(user_data)


@router.put("/{user_id}", response_model=UserRead, dependencies=[Depends(admin_required)])
async def update_user(
        user_id: uuid.UUID, user_data: UserCreate, service: UserService = Depends(get_user_service)
):
    return await service.update_user(user_id, user_data)


@router.delete("/{user_id}", status_code=status.HTTP_200_OK, dependencies=[Depends(admin_required)])
async def delete_user(user_id: uuid.UUID, service: UserService = Depends(get_user_service)):
    await service.delete_user(user_id)
    return {"message": f"User with id {user_id} deleted successfully."}
