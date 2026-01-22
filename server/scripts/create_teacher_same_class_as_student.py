r"""Create a Teacher assigned to the same class as the student 'Pricop Alexandru'.

What it does:
- connects directly to the DB using the existing SQLAlchemy async engine from config.database
- finds the student by user.username (case-insensitive) containing both words: 'pricop' and 'alexandru'
- reads student's class_id
- creates (or reuses) a Teacher user + teacher row
- assigns the teacher to that class by setting:
    - Teacher.class_id
    - Class.teacher_id

Defaults:
- email: prof@mail.com
- password: prof123

Usage (PowerShell):
  D:\SchoolApp\server\.venv\Scripts\python.exe D:\SchoolApp\server\scripts\create_teacher_same_class_as_student.py

Notes:
- You MUST run with the same interpreter/environment as the backend (the project's .venv), otherwise asyncpg may be missing.
- Requires DB env vars set (DB_USER, DB_PASS, DB_HOST, DB_PORT, DB_NAME) or a .env file in server/.
"""

import asyncio
import os
import sys
import uuid
from pathlib import Path

# Ensure project root (server/) is on sys.path so `config.*` and `app.*` imports work
PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from sqlalchemy import select, func

from config.database import AsyncSession
from app.users.models.users import User
from app.users.models.teachers import Teacher
from app.users.models.students import Student
from app.users.enums import UserRole
from app.classes.models import Class


TARGET_WORDS = ["pricop", "alexandru"]

# You can override these via environment variables
NEW_TEACHER_EMAIL = os.environ.get("NEW_TEACHER_EMAIL", "prof@mail.com")
NEW_TEACHER_USERNAME = os.environ.get("NEW_TEACHER_USERNAME", "prof")
NEW_TEACHER_SUBJECT = os.environ.get("NEW_TEACHER_SUBJECT", "Test")
NEW_TEACHER_PASSWORD = os.environ.get("NEW_TEACHER_PASSWORD", "prof123")


async def main() -> None:
    print(f"Running with python: {sys.executable}")

    async with AsyncSession() as session:
        # 1) Find student by matching username
        q = (
            select(Student)
            .join(User, User.id == Student.user_id)
            .where(
                func.lower(User.username).like(f"%{TARGET_WORDS[0]}%"),
                func.lower(User.username).like(f"%{TARGET_WORDS[1]}%"),
            )
        )
        res = await session.execute(q)
        student = res.scalars().first()

        if not student:
            raise SystemExit(
                "Nu am găsit elevul după username. "
                "Verifică în DB dacă User.username conține 'Pricop' și 'Alexandru'."
            )

        if not student.class_id:
            raise SystemExit("Elevul găsit nu are class_id setat.")

        class_id = student.class_id

        # 2) Load the class
        class_res = await session.execute(select(Class).where(Class.id == class_id))
        class_obj = class_res.scalars().first()
        if not class_obj:
            raise SystemExit(f"Clasa cu id={class_id} nu există.")

        # 3) Check if teacher user already exists (by email)
        existing_user_res = await session.execute(
            select(User).where(func.lower(User.email) == NEW_TEACHER_EMAIL.lower())
        )
        existing_user = existing_user_res.scalars().first()

        if existing_user:
            # Ensure user is TEACHER and activated; reset password for test
            existing_user.role = UserRole.TEACHER
            existing_user.is_activated = True
            existing_user.set_password(NEW_TEACHER_PASSWORD)

            # ensure teacher row exists
            t_res = await session.execute(select(Teacher).where(Teacher.user_id == existing_user.id))
            teacher_row = t_res.scalars().first()

            if not teacher_row:
                teacher_row = Teacher(
                    user_id=existing_user.id,
                    subject=NEW_TEACHER_SUBJECT,
                    is_homeroom=False,
                    is_director=False,
                    class_id=class_id,
                )
                session.add(teacher_row)
            else:
                teacher_row.subject = NEW_TEACHER_SUBJECT
                teacher_row.class_id = class_id

            # assign class teacher_id
            class_obj.teacher_id = existing_user.id
            await session.commit()

            # Verify
            verify_user = (await session.execute(select(User).where(User.id == existing_user.id))).scalars().first()
            verify_teacher = (await session.execute(select(Teacher).where(Teacher.user_id == existing_user.id))).scalars().first()

            print("OK: user exista; setat ca profesor, parola resetata, clasa reasociata.")
            print(f" teacher_email={NEW_TEACHER_EMAIL}")
            print(f" teacher_password={NEW_TEACHER_PASSWORD}")
            print(f" teacher_user_id={existing_user.id}")
            print(f" class_id={class_id} name={class_obj.name}")
            print(f" verify_user_found={verify_user is not None} verify_teacher_found={verify_teacher is not None}")
            return

        # 4) Create teacher user + teacher row
        teacher_user_id = uuid.uuid4()
        user = User(
            id=teacher_user_id,
            username=NEW_TEACHER_USERNAME,
            email=NEW_TEACHER_EMAIL,
            role=UserRole.TEACHER,
            is_activated=True,
            school_id=class_obj.school_id,
        )
        user.set_password(NEW_TEACHER_PASSWORD)

        teacher = Teacher(
            user_id=teacher_user_id,
            subject=NEW_TEACHER_SUBJECT,
            is_homeroom=False,
            is_director=False,
            class_id=class_id,
        )

        session.add(user)
        session.add(teacher)

        # assign this teacher as class teacher
        class_obj.teacher_id = teacher_user_id

        await session.commit()

        # Verify immediately after commit
        verify_user = (await session.execute(select(User).where(func.lower(User.email) == NEW_TEACHER_EMAIL.lower()))).scalars().first()
        verify_teacher = None
        if verify_user:
            verify_teacher = (await session.execute(select(Teacher).where(Teacher.user_id == verify_user.id))).scalars().first()

        print("OK: profesor creat si asignat la aceeasi clasa ca Pricop Alexandru")
        print(f" teacher_email={NEW_TEACHER_EMAIL}")
        print(f" teacher_password={NEW_TEACHER_PASSWORD}")
        print(f" teacher_user_id={teacher_user_id}")
        print(f" class_id={class_id} name={class_obj.name}")
        print(f" verify_user_found={verify_user is not None} verify_teacher_found={verify_teacher is not None}")


if __name__ == "__main__":
    asyncio.run(main())
