import asyncio
import sys
from pathlib import Path

# Ensure project root (server/) is on sys.path
PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from sqlalchemy import select, func

# Import all models first to ensure SQLAlchemy mapper registry is complete
import app.models  # noqa: F401

from config.database import AsyncSession
from app.users.models.users import User


EMAIL = "prof@example.com"
NEW_PASSWORD = "prof123"


async def main() -> None:
    async with AsyncSession() as session:
        res = await session.execute(select(User).where(func.lower(User.email) == EMAIL.lower()))
        user = res.scalars().first()
        if not user:
            raise SystemExit(f"User not found: {EMAIL}")

        user.set_password(NEW_PASSWORD)
        await session.commit()
        print(f"OK: password updated for {EMAIL}")


if __name__ == "__main__":
    asyncio.run(main())
