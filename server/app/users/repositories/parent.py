import uuid
from sqlalchemy.future import select
from app.users.models import Parent
from app.users.schemas.parent import ParentCreate, ParentRead
from config.database import AsyncSession


class ParentRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_all(self) -> list[ParentRead]:
        result = await self.session.execute(select(Parent))
        parents = result.scalars().all()
        return [ParentRead.model_validate(parent) for parent in parents]

    async def get_by_id(self, id: uuid.UUID) -> ParentRead | None:
        result = await self.session.execute(select(Parent).where(Parent.id == id))
        parent = result.scalars().first()
        return ParentRead.model_validate(parent) if parent else None

    async def create(self, parent_create: ParentCreate) -> ParentRead:
        parent = Parent(
            id=uuid.uuid4()
        )
        self.session.add(parent)
        await self.session.commit()
        await self.session.refresh(parent)
        return ParentRead.model_validate(parent)

    async def update(self, id: uuid.UUID, data: ParentCreate) -> ParentRead | None:
        result = await self.session.execute(select(Parent).where(Parent.id == id))
        parent = result.scalars().first()
        if not parent:
            return None
        # Aici poți actualiza câmpurile parent-ului dacă ai mai multe
        await self.session.commit()
        await self.session.refresh(parent)
        return ParentRead.model_validate(parent)

    async def delete(self, id: uuid.UUID) -> bool:
        result = await self.session.execute(select(Parent).where(Parent.id == id))
        parent = result.scalars().first()
        if not parent:
            return False
        await self.session.delete(parent)
        await self.session.commit()
        return True
