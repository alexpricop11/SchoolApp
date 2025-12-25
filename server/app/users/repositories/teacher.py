import uuid
from datetime import datetime

from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.users.models import Teacher, User, UserRole
from app.users.schemas.teacher import TeacherCreate, TeacherRead, TeacherUpdate
from config.database import AsyncSession


class TeacherRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_all(self) -> list[TeacherRead]:
        result = await self.session.execute(
            select(Teacher).options(
                selectinload(Teacher.user),
                selectinload(Teacher.classes),
            )
        )

        teachers = result.scalars().all()
        return [TeacherRead.model_validate(teacher) for teacher in teachers]

    async def get_by_id(self, id: uuid.UUID) -> TeacherRead | None:
        result = await self.session.execute(select(Teacher).where(Teacher.user_id == id))
        teacher = result.scalars().first()
        return TeacherRead.model_validate(teacher) if teacher else None

    async def create(self, teacher_create: TeacherCreate) -> TeacherRead:
        async with self.session.begin():
            user = User(
                id=uuid.uuid4(),
                username=teacher_create.username,
                email=str(teacher_create.email),
                role=UserRole.TEACHER,
                school_id=teacher_create.school_id,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow(),
            )
            self.session.add(user)
            await self.session.flush()

            teacher = Teacher(
                user_id=user.id,
                subject=teacher_create.subject,
                is_homeroom=teacher_create.is_homeroom or False,
                is_director=teacher_create.is_director or False,
            )
            self.session.add(teacher)

        result = await self.session.execute(
            select(Teacher)
            .options(
                selectinload(Teacher.user),
                selectinload(Teacher.classes),
            )
            .where(Teacher.user_id == teacher.user_id)
        )
        teacher = result.scalars().first()
        return TeacherRead.model_validate(teacher)

    async def update(self, id: uuid.UUID, data: TeacherUpdate) -> TeacherRead | None:
        async with self.session.begin():
            result = await self.session.execute(
                select(Teacher)
                .options(
                    selectinload(Teacher.user),
                    selectinload(Teacher.classes),
                )
                .where(Teacher.user_id == id)
            )
            teacher = result.scalars().first()
            if not teacher:
                return None

            if data.subject is not None:
                teacher.subject = data.subject
            if data.is_director is not None:
                teacher.is_director = data.is_director
            if data.is_homeroom is not None:
                teacher.is_homeroom = data.is_homeroom
            if hasattr(data, "username") and data.username:
                teacher.user.username = data.username
            if hasattr(data, "email") and data.email:
                teacher.user.email = str(data.email)

            await self.session.flush()

        await self.session.refresh(teacher)
        return TeacherRead.model_validate(teacher)

    async def delete(self, id: uuid.UUID) -> bool:
        result = await self.session.execute(select(User).where(User.id == id))
        user = result.scalars().first()
        if not user:
            return False

        await self.session.delete(user)
        await self.session.commit()
        return True
