from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from app.auth.routes import router as auth_router
from app.school.routes import router as school_router
from app.password.routes import router as password_router
from app.classes.routes import router as classes_router
from app.users.routes.teacher import router as teacher_router
from app.users.routes.student import router as student_router
from app.users.routes.user import router as user_router
from middleware import setup_cors

app = FastAPI()

setup_cors(app)

app.include_router(auth_router)
app.include_router(school_router)
app.include_router(teacher_router)
app.include_router(user_router)
app.include_router(student_router)
app.include_router(classes_router)
app.include_router(password_router)


@app.get("/", response_class=HTMLResponse)
def start_page():
    return """
       <!DOCTYPE html>
       <html>
           <head>
               <title>Home</title>
           </head>
           <body style="text-align:center; margin-top:50px;">
               <h1>Welcome</h1>
               <button onclick="window.location.href='/docs'">
                   Go to API Docs
               </button>
           </body>
       </html>
       """
