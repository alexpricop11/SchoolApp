from fastapi import FastAPI

from app.auth.routes import router as auth_router
from app.school.routes import router as school_router
from app.password.routes import router as password_router
from app.classes.routes import router as classes_router
from app.users.routes.parent import router as parent_router
from app.users.routes.teacher import router as teacher_router
from app.users.routes.student import router as student_router
from app.users.routes.user import router as user_router
from middleware import setup_cors

app = FastAPI()

setup_cors(app)

app.include_router(auth_router)
app.include_router(school_router)
app.include_router(parent_router)
app.include_router(teacher_router)
app.include_router(user_router)
app.include_router(student_router)
app.include_router(classes_router)
app.include_router(password_router)
