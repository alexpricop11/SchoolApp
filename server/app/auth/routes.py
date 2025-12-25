from fastapi import APIRouter, Depends

from app.auth.repository import AuthRepository
from app.auth.schemas import UserLoginRequest, EmailCheckRequest, AuthResponse
from app.auth.services import AuthService
from config.database import get_db, AsyncSession

router = APIRouter(prefix="/auth", tags=["Auth"])


def get_auth_service(db: AsyncSession = Depends(get_db)) -> AuthService:
    repository = AuthRepository(db)
    return AuthService(repository)


@router.post("/check-email")
async def check_email(
        data: EmailCheckRequest,
        auth_service: AuthService = Depends(get_auth_service)
):
    return await auth_service.get_check_email(data.email)


@router.post("/login", response_model=AuthResponse)
async def login(
        data: UserLoginRequest,
        auth_service: AuthService = Depends(get_auth_service)
):
    return await auth_service.login(data)
