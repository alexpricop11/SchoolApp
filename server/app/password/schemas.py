from pydantic import BaseModel, EmailStr


class ResetPasswordSchema(BaseModel):
    email: EmailStr
    code: int
    password: str


class SendResetCodeSchema(BaseModel):
    email: EmailStr
