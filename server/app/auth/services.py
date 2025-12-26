from app.auth.repository import AuthRepository
from pydantic import EmailStr
from fastapi import HTTPException, status

from app.auth.schemas import EmailCheckResponse, AccountStatus, UserLoginRequest, AuthResponse
from app.password.utils import pwd_context
from config.security import create_access_token, create_refresh_token


class AuthService:
    def __init__(self, repository: AuthRepository):
        self.repository = repository

    async def get_check_email(self, email: EmailStr) -> EmailCheckResponse:
        user = await self.repository.get_by_email(email)
        if not user:
            return EmailCheckResponse()
        return EmailCheckResponse(
            exists=True,
            is_active=user.is_activated,
            status=(
                AccountStatus.ACTIVE
                if user.is_activated
                else AccountStatus.INACTIVE
            ),
            role=user.role,
        )

    async def login(self, data: UserLoginRequest) -> AuthResponse:
        user = await self.repository.get_by_email(data.email)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        if not user.is_activated:
            if not data.password:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Account not activated. Please set your password."
                )

            password_hash = pwd_context.hash(data.password)
            await self.repository.activate_user(user, password_hash)
            access_token = create_access_token({
                "sub": str(user.id),
                "role": user.role
            })

            refresh_token = create_refresh_token({
                "sub": str(user.id)
            })

            return AuthResponse(
                id=user.id,
                username=user.username,
                email=user.email,
                role=user.role,
                is_activated=True,
                access_token=access_token,
                refresh_token=refresh_token,
            )

        if not data.password or not pwd_context.verify(data.password, user.password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect password"
            )

        access_token = create_access_token({
            "sub": str(user.id),
            "role": user.role
        })

        refresh_token = create_refresh_token({
            "sub": str(user.id)
        })

        return AuthResponse(
            id=user.id,
            username=user.username,
            email=user.email,
            role=user.role,
            is_activated=True,
            access_token=access_token,
            refresh_token=refresh_token
        )
